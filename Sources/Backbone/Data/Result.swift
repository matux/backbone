import Swift

/// Result-type constructor, where ?? cons Optionals, ??? cons Result
infix operator ??? : NilCoalescingPrecedence

/// Performs a nil-coalescing operation, returning a `Result` instance with
/// either the wrapped value of the given `Optional` instance as its `success`
/// case or the specified `Error` as its `failure` case.
///
/// - Parameters:
///   - optional: An optional value.
///   - error: An instance of a Swift.Error type describing the failure.
/// - Returns: A Result with the value wrapped in the optional or an error.
@_transparent
public func ??? <Success, Failure: Swift.Error>(
  optional: Success?,
  fail: @autoclosure () throws -> Failure
) -> Result<Success, Failure> {
  return .init(catching: try optional.unwrap(or: fail()))
}

/// Performs a nil-coalescing operation, returning a `Result` instance with
/// either the wrapped value of the given `Optional` instance as its `success`
/// case or the specified `Error` as its `failure` case.
///
/// - Parameters:
///   - optional: An optional value.
///   - error: An instance of a Swift.Error type describing the failure.
/// - Returns: A Result with the value wrapped in the optional or an error.
@_transparent
public func ??? <Success, NewSuccess, Failure: Swift.Error>(
  transform: @escaping (Success) -> NewSuccess?,
  fail: @escaping @autoclosure () -> Failure
) -> (Success) -> Result<NewSuccess, Failure> {
  return { success in transform(success) ??? fail() }
}

// MARK: - Initialization

extension Result {

  @_transparent
  public init(success: Success) {
    self = .success(success)
  }

  @_transparent
  public init(failure: Failure) {
    self = .failure(failure)
  }

  /// Creates a `Result` instance with the unwrapped value of the given
  /// `Optional` or a failure if the `Optional` is `nil`.
  @inlinable
  public init(_ success: Success?, or failure: @autoclosure () -> Failure) {
    switch success {
    case let .some(success):
      self = .success(success)
    case .none:
      self = .failure(failure())
    }
  }

  /// Creates a `Result` instance of failure with the unwrapped `Error` of the
  /// given `Optional`, or a success if the `Optional` error is `nil`.
  ///
  /// An error-biased initialization contingent on the abscence of error,
  /// complementing the standard success-biased initialization. Where one
  /// states `"if there is no success, there is an error."`, the other does so
  /// by reversing the grammar of the condition: `"unless there is an error,
  /// there is success."`
  ///
  /// - Note: Useful on contexts where API errors may be reported inside the
  ///   same structure supposed to carry data associated with success.
  @inlinable
  public init(_ success: @autoclosure () -> Success, unless failure: Failure?) {
    switch failure {
    case let .some(error):
      self = .failure(error)
    case .none:
      self = .success(success())
    }
  }

  /// Creates a new `Result` instance using the given throwing function
  /// and producing a `Failure` `Result` if throws.
  @inlinable
  public init(catching body: @autoclosure () throws -> Success) {
    do {
      self = .success(try body())
    } catch var error {
      if Failure.self == AnyError.self {
        error = AnyError(error)
      }
      self = .failure(Type.castǃ(error))
    }
  }
}

extension Result where Success == () {

  // MARK: ╶╼• where Success is ()

  @inlinable
  public static var success: Self {
    return .success(())
  }

  @inlinable
  init() {
    self = .success
  }

  @inlinable
  init(_ error: Failure?) {
    switch error {
    case .none:
      self = .success
    case .some(let error):
      self = .failure(error)
    }
  }
}

extension Result where Failure == Swift.Error {

  // MARK: ╶╼• where Failure is Swift.Error

  /// Creates a new result by evaluating a throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A throwing closure to evaluate.
  @_transparent
  public init(catching success: () throws -> Success) {
    do {
      self = .success(try success())
    } catch {
      self = .failure(error)
    }
  }
}

extension Result where Failure == AnyError {

  // MARK: ╶╼• where Failure is AnyError

  /// Creates a new `Result` instance from a throwing closure, failing with
  /// `Failure` on throw.
  @inlinable
  public init(_ success: @autoclosure () throws -> Success) {
    do {
      self = .success(try success())
    } catch {
      self = .failure(.init(error))
    }
  }

  /// Creates a new `Result` instance from a throwing closure, failing with
  /// `AnyError` on throw.
  @inlinable
  public init(catching success: () throws -> Success) {
    do {
      self = .success(try success())
    } catch {
      self = .failure(.init(error))
    }
  }
}

// MARK: - Conformances

extension Result: Comparable where Success: Comparable, Failure: Comparable {

  // MARK: ╶╼• Comparable

  @inlinable
  public static func < (lhs: Result, rhs: Result) -> Bool {
    if case let (l?, r?) = (lhs.success, rhs.success) {
      return l < r
    } else if case let (l?, r?) = (lhs.failure, rhs.failure) {
      return l < r
    } else {
      return false
    }
  }
}

extension Result: Decodable where Success: Decodable, Failure: Decodable {

  // MARK: ╶╼• Decodable

  @inlinable
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    self = try container.decode(Success.self)
           ??? container.decode(Failure.self)
  }
}

extension Result: Encodable where Success: Encodable, Failure: Encodable {

  // MARK: ╶╼• Encodable

  @inlinable
  public func encode(to encoder: Encoder) throws {
    var encoder = encoder.unkeyedContainer()
    try forᵀ(
      success: { try encoder.encode($0) },
      failure: { try encoder.encode($0) })
  }
}

// MARK: - Combinators

/// Result extension for higher-order functions.
extension Result {

  // MARK: ╶╼• Functor: Applicative: Monad

  /// Returns a new result, mapping any success value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Result`
  /// instance when it represents a success. The following example transforms
  /// the integer success value of a result into a string:
  ///
  ///     func getNextInteger() -> Result<Int, Error> { /* ... */ }
  ///
  ///     let integerResult = getNextInteger()
  ///     // integerResult == .success(5)
  ///     let stringResult = integerResult.map({ String($0) })
  ///     // stringResult == .success("5")
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  @inlinable
  public func fmap<NewSuccess>(
    _ transform: (Success) -> NewSuccess
  ) -> Result<NewSuccess, Failure> {
    return map(transform)
  }

  /// Returns a new result, mapping any failure value using the given
  /// transformation.
  ///
  /// Use this method when you need to transform the value of a `Result`
  /// instance when it represents a failure. The following example transforms
  /// the error value of a result by wrapping it in a custom `Error` type:
  ///
  ///     struct DatedError: Error {
  ///         var error: Error
  ///         var date: Date
  ///
  ///         init(_ error: Error) {
  ///             self.error = error
  ///             self.date = Date()
  ///         }
  ///     }
  ///
  ///     let result: Result<Int, Error> = // ...
  ///     // result == .failure(<error value>)
  ///     let resultWithDatedError = result.mapError({ e in DatedError(e) })
  ///     // result == .failure(DatedError(error: <error value>, date: <date>))
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  @inlinable
  public func fmapError<NewFailure: Error>(
    _ transform: (Failure) -> NewFailure
  ) -> Result<Success, NewFailure> {
    return mapError(transform)
  }

  /// Evaluates the given closure when it is not a `failure` and this `Result`
  /// instance is not `failure` either, passing the `success` value as a
  /// parameter.
  ///
  /// - Note: An Applicative. This is an ad-hoc applicative implementation
  ///   defined in monadic terms.
  /// - Parameter transform: An optional closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If the given closure or this
  ///   instance are `nil`, returns `nil`.
  @inlinable
  public func apply<NewSuccess>(
    _ transform: Result<(Success) -> NewSuccess, Failure>
  ) -> Result<NewSuccess, Failure> {
    return transform.bind(fmap)
  }

  /// Returns a new result, mapping any success value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the success value of the
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  public func bind<NewSuccess>(
    _ transform: (Success) -> Result<NewSuccess, Failure>
  ) -> Result<NewSuccess, Failure> {
    return flatMap(transform)
  }

  /// Returns a new result, mapping any failure value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `Result` instance, either from the closure or the previous
  ///   `.success`.
  public func bindError<NewFailure>(
    _ transform: (Failure) -> Result<Success, NewFailure>
  ) -> Result<Success, NewFailure> {
    return flatMapError(transform)
  }

  // MARK: ╶╼• Combinators

  /// (`|||`) Returns the result of mapping either value homogenously.
  ///
  /// Performs a functional case analysis transformation over _either_
  /// `success` _or_ `failure`, depending on which one this instance
  /// holds, with each function returning the same type
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  @inlinable
  public func either<U>(
    _ success: (Success) -> U,
    or failure: (Failure) -> U
  ) -> U {
    switch self {
    case let .success(x): return success(x)
    case let .failure(e): return failure(e)
    }
  }

  /// Bifunctor map
  @inlinable
  public func bimap<Successʼ, Failureʼ: Swift.Error>(
    success: (Success) -> Successʼ,
    failure: (Failure) -> Failureʼ
  ) -> Result<Successʼ, Failureʼ> {
    switch self {
    case .success(let x): return .success(success(x))
    case .failure(let e): return .failure(failure(e))
    }
  }

  /// Return this instance of `Result` after running either a side effect on
  /// the unwrapped value for the success case, or another side-effect on the
  /// unwrapped error for the failure case of this `Result` instance.
  @inlinable
  public func tap(
    _ sink: (Success) -> ()
  ) -> Result {
    const(self)(when(success: sink))
  }

  /// Either run a side effect on the unwrapped value for the success case, or
  /// another side-effect on the unwrapped error for the failure case of this
  /// `Result` instance.
  @inlinable
  public func when(
    success: (Success) -> (),
    failure: (Failure) -> () = discard
  ) -> () {
    switch self {
    case .success(let x): success(x)
    case .failure(let e): failure(e)
    }
  }

  /// Returns the given `Result` instance on the left-hand side paired with
  /// the `Result` instance _iff_ both instances represent `Success`.
  /// Otherwise, the `Failure` error from the left-hand side Result
//  @inlinable
//  public func zip<AdjunctSuccess>(
//    _ other: @autoclosure () -> Result<AdjunctSuccess, Failure>
//  ) -> Result<(Success, AdjunctSuccess), Failure> {
//    DB.zip(self, other())
//    //return flatMap { l in other().map { r in (l, r) } }
//  }
}

extension Result where Failure: ErrorConvertible {

  // MARK: ╶╼• where Failure is ErrorConvertible

  @inlinable
  public func get<NewSuccess>(
    with transform: (Success) throws -> NewSuccess
  ) -> Result<NewSuccess, Failure> {
    flatMap { success in
      do { return .success(try transform(success)) }
      catch { return .failure(.from(error)) }
    }
  }
}

extension Result where Success == () {

  // MARK: ╶╼• where Success is ()

//  /// Either run a side effect on the unwrapped value for the success case, or
//  /// another side-effect on the unwrapped error for the failure case of this
//  /// `Result` instance.
//  @inlinable
//  public func when(
//    success: () -> (),
//    failure: (Failure) -> () = discard
//  ) -> () {
//    switch self {
//    case .success: success()
//    case .failure(let e): failure(e)
//    }
//  }

  /// Returns the result of mapping either value with an homogenous result.
  ///
  /// Performs a functional case analysis transformation over _either_
  /// `success` _or_ `failure`, depending on which one this instance
  /// holds, with each function returning the same type
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  @inlinable
  public func either<U>(
    _ success: @autoclosure () -> U,
    or failure: (Failure) -> U
  ) -> U {
    switch self {
    case .success: return success()
    case .failure(let e): return failure(e)
    }
  }
}

// MARK: -
// MARK: - Static thunks

infix operator <*> : MultiplicationPrecedence

extension Result {

  /// Returns a new result, mapping any success value using the given
  /// transformation.
  ///
  /// - Parameter transform: A closure that takes the success value of this
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  @inlinable
  public static func fmap<NewSuccess>(
    _ transform: @escaping (Success) -> NewSuccess
  ) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
    { $0.map(transform) }
  }

  /// Returns a new result, mapping any failure value using the given
  /// transformation.
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  @inlinable
  public static func fmapError<NewFailure: Swift.Error>(
    _ transform: @escaping (Failure) -> NewFailure
  ) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
    { $0.mapError(transform) }
  }

  /// Evaluates the given closure when it is not a `failure` and this `Result`
  /// instance is not `failure` either, passing the `success` value as a
  /// parameter.
  ///
  /// - Parameter transform: An optional closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If the given closure or this
  ///   instance are `nil`, returns `nil`.
  @_transparent
  public static func <*> <NewSuccess>(
    transform: Result<(Success) -> NewSuccess, Failure>,
    result: Result<Success, Failure>
  ) -> Result<NewSuccess, Failure> {
    result.apply(transform)
  }

  /// Evaluates the given closure when it is not a `failure` and this `Result`
  /// instance is not `failure` either, passing the `success` value as a
  /// parameter.
  ///
  /// - Parameter transform: An optional closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If the given closure or this
  ///   instance are `nil`, returns `nil`.
  @inlinable
  public static func apply<NewSuccess>(
    _ transform: Result<(Success) -> NewSuccess, Failure>
  ) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
    { $0.apply(transform) }
  }

  /// Returns a new result, mapping any success value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the success value of the
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  @inlinable
  public static func flatMap<NewSuccess>(
    _ transform: @escaping (Success) -> Result<NewSuccess, Failure>
  ) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
    { $0.flatMap(transform) }
  }

  /// Returns a new result, mapping any failure value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `Result` instance, either from the closure or the previous
  ///   `.success`.
  @inlinable
  public static func flatMapError<NewFailure: Swift.Error>(
    _ transform: @escaping (Failure) -> Result<Success, NewFailure>
  ) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
    { $0.flatMapError(transform) }
  }

  /// Returns a new result, mapping any success value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the success value of the
  ///   instance.
  /// - Returns: A `Result` instance with the result of evaluating `transform`
  ///   as the new failure value if this instance represents a failure.
  @inlinable
  public static func bind<NewSuccess>(
    _ transform: @escaping (Success) -> Result<NewSuccess, Failure>
  ) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
    { $0.bind(transform) }
  }

  /// Returns a new result, mapping any failure value using the given
  /// transformation and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the failure value of the
  ///   instance.
  /// - Returns: A `Result` instance, either from the closure or the previous
  ///   `.success`.
  @inlinable
  public static func bindError<NewFailure: Swift.Error>(
    _ transform: @escaping (Failure) -> Result<Success, NewFailure>
  ) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
    { $0.bindError(transform) }
  }

  // MARK: ╶╼• Combinators

  /// Returns the result of mapping either value homogenously.
  ///
  /// Performs a functional case analysis transformation over _either_
  /// `success` _or_ `failure`, depending on which one this instance
  /// holds, with each function returning the same type
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  @inlinable
  public static func either<U>(
    _ success: @escaping (Success) -> U,
    or failure: @escaping (Failure) -> U
  ) -> (Result) -> U {
    { result in result.either(success, or: failure) }
  }

  /// Either map the success case or the failure case.
  @inlinable
  public static func bimap<Successʼ, Failureʼ>(
    success: @escaping (Success) -> Successʼ,
    failure: @escaping (Failure) -> Failureʼ
  ) -> (Result) -> Result<Successʼ, Failureʼ> {
    { result in result.bimap(success: success, failure: failure) }
  }

  /// Either run a side effect on the unwrapped value for the success case, or
  /// another side-effect on the unwrapped error for the failure case of this
  /// `Result` instance.
  @inlinable
  public static func when(
    success: @escaping (Success) -> (),
    failure: @escaping (Failure) -> () = discard
  ) -> (Result) -> () {
    { result in result.when(success: success, failure: failure) }
  }

  /// Return this instance of `Result` after running either a side effect on
  /// the unwrapped value for the success case, or another side-effect on the
  /// unwrapped error for the failure case of this `Result` instance.
  @inlinable
  public static func tap(
    _ sink: @escaping (Success) -> ()
  ) -> (Result) -> Result {
    tap >>> with(sink)
  }

  /// Returns a new `Result` instance extracting the value the given keypath
  /// points to as the new `Success` value.
  @inlinable
  public static func select<NewSuccess>(
    _ path: KeyPath<Success, NewSuccess?>,
    or failure: Failure
  ) -> (Result) -> Result<NewSuccess, Failure> {
    flatMap { root in .init(root[keyPath: path], or: failure) }
  }

  @inlinable
  public static func select<NewSuccess₁, NewSuccess₂>(
    _ path₁: KeyPath<Success, NewSuccess₁?>,
    _ path₂: KeyPath<Success, NewSuccess₂?>,
    or failure: Failure
  ) -> (Result) -> Result<(NewSuccess₁, NewSuccess₂), Failure> {
    flatMap { root in .init(zip(path₁, path₂)(root), or: failure) }
  }
}

extension Result where Failure: Identity {

  /// Returns a new `Result` instance extracting from the current `Success`
  /// value, the value described by the given keypath as the new `Success`
  /// value.
  @inlinable
  public static func select<NewSuccess>(
    _ path: KeyPath<Success, NewSuccess?>
  ) -> (Result) -> Result<NewSuccess, Failure> {
    flatMap { root in .init(root[keyPath: path], or: .empty) }
  }

  @inlinable
  public static func select<NewSuccess₁, NewSuccess₂>(
    _ path₁: KeyPath<Success, NewSuccess₁?>,
    _ path₂: KeyPath<Success, NewSuccess₂?>
  ) -> (Result) -> Result<(NewSuccess₁, NewSuccess₂), Failure> {
    flatMap { root in
      .init(zip(path₁, path₂)(root), or: .empty)
    }
  }
}


extension Result where Success == () {

  // MARK: ╶╼• where Success is ()

  /// Either run a side effect on the unwrapped value for the success case, or
  /// another side-effect on the unwrapped error for the failure case of this
  /// `Result` instance.
//  @inlinable
//  public static func when(
//    success: @escaping () -> (),
//    failure: @escaping (Failure) -> () = discard
//  ) -> (Result) -> () {
//    return { result in result.when(success: success, failure: failure) }
//  }

  /// Returns the result of mapping either value with an homogenous result.
  ///
  /// Performs a functional case analysis transformation over _either_
  /// `success` _or_ `failure`, depending on which one this instance
  /// holds, with each function returning the same type
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  @inlinable
  public static func either<U>(
    _ success: @escaping @autoclosure () -> U,
    or failure: @escaping (Failure) -> U
  ) -> (Result) -> U {
    { result in result.either(success, or: failure) }
  }
}

// MARK: - Partial functions

extension Result {

  /// Either run a side effect on the unwrapped value for the success case, or
  /// another side-effect on the unwrapped error for the failure case of this
  /// `Result` instance.
  public func forᵀ(
    success: (Success) throws -> (),
    failure: (Failure) throws -> ()
  ) rethrows -> () {
    switch self {
    case .success(let value): try success(value)
    case .failure(let error): try failure(error)
    }
  }

  /// Return this instance of `Result` after running either a side effect on
  /// the unwrapped value for the success case, or another side-effect on the
  /// unwrapped error for the failure case of this `Result` instance.
  public func tapᵀ(
    success: (Success) throws -> (),
    failure: (Failure) throws -> ()
  ) rethrows -> Result {
    const(self)(try forᵀ(success: success, failure: failure))
  }
}

// MARK: - Free thunks

/// Returns a new result, mapping any success value using the given
/// transformation.
///
/// - Parameter transform: A closure that takes the success value of this
///   instance.
/// - Returns: A `Result` instance with the result of evaluating `transform`
///   as the new success value if this instance represents a success.
@inlinable
public func fmap<Success, Failure: Swift.Error, Transformed>(
  _ transform: @escaping (Success) -> Transformed
) -> (Result<Success, Failure>) -> Result<Transformed, Failure> {
  Result.fmap(transform)
}

/// Returns a new result, mapping any failure value using the given
/// transformation.
///
/// - Parameter transform: A closure that takes the failure value of the
///   instance.
/// - Returns: A `Result` instance with the result of evaluating `transform`
///   as the new failure value if this instance represents a failure.
@inlinable
public func fmapError<Success, Failure: Swift.Error, NewFailure: Error>(
  _ transform: @escaping (Failure) -> NewFailure
) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
  Result.fmapError(transform)
}

/// Evaluates the given closure when it is not a `failure` and this `Result`
/// instance is not `failure` either, passing the `success` value as a
/// parameter.
///
/// - Note: An Applicative. This is an ad-hoc applicative implementation
///   defined in monadic terms.
/// - Parameter transform: An optional closure that takes the unwrapped
///   value of the instance.
/// - Returns: The result of the given closure. If the given closure or this
///   instance are `nil`, returns `nil`.
@inlinable
public func apply<Success, NewSuccess, Failure: Swift.Error>(
  _ transform: Result<(Success) -> NewSuccess, Failure>
) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
  Result.apply(transform)
}

/// Returns a new result, mapping any success value using the given
/// transformation and unwrapping the produced result.
///
/// - Parameter transform: A closure that takes the success value of the
///   instance.
/// - Returns: A `Result` instance with the result of evaluating `transform`
///   as the new failure value if this instance represents a failure.
@inlinable
public func flatMap<Success, NewSuccess, Failure: Swift.Error>(
  _ transform: @escaping (Success) -> Result<NewSuccess, Failure>
) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
  Result.flatMap(transform)
}

/// Returns a new result, mapping any failure value using the given
/// transformation and unwrapping the produced result.
///
/// - Parameter transform: A closure that takes the failure value of the
///   instance.
/// - Returns: A `Result` instance, either from the closure or the previous
///   `.success`.
@inlinable
public func flatMapError<Success, Failure: Swift.Error, NewFailure: Swift.Error>(
  _ transform: @escaping (Failure) -> Result<Success, NewFailure>
) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
  Result.flatMapError(transform)
}

/// Returns a new result, mapping any success value using the given
/// transformation and unwrapping the produced result.
///
/// - Parameter transform: A closure that takes the success value of the
///   instance.
/// - Returns: A `Result` instance with the result of evaluating `transform`
///   as the new failure value if this instance represents a failure.
@inlinable
public func bind<Success, NewSuccess, Failure: Swift.Error>(
  _ transform: @escaping (Success) -> Result<NewSuccess, Failure>
) -> (Result<Success, Failure>) -> Result<NewSuccess, Failure> {
  Result.bind(transform)
}

/// Returns a new result, mapping any failure value using the given
/// transformation and unwrapping the produced result.
///
/// - Parameter transform: A closure that takes the failure value of the
///   instance.
/// - Returns: A `Result` instance, either from the closure or the previous
///   `.success`.
@inlinable
public func bindError<Success, Failure: Swift.Error, NewFailure: Swift.Error>(
  _ transform: @escaping (Failure) -> Result<Success, NewFailure>
) -> (Result<Success, Failure>) -> Result<Success, NewFailure> {
  Result.bindError(transform)
}

/// Returns a new function that is the composition of two Result
/// transformations.
///
/// - Parameters:
///     - f: A Result transform.
///     - g: Another Result transform over the Result of `f`.
/// - Returns: A function composing `f` and `g`.
@inlinable
public func >=> <T, Successʹ, Success, Failure: Swift.Error>(
  f: @escaping (T) -> Result<Successʹ, Failure>,
  g: @escaping (Successʹ) -> Result<Success, Failure>
) -> (T) -> Result<Success, Failure> {
  f >>> flatMap(g)
}

// MARK: · · · · · · · · · · · · · · · · · · · · ·

/// Returns the result of mapping either value homogenously.
///
/// Performs a functional case analysis transformation over _either_
/// `success` _or_ `failure`, depending on which one this instance
/// holds, with each function returning the same type
///
/// - Invariant: The result type of both transforms is guaranteed to be equal.
@inlinable
public func either<Success, Failure: Swift.Error, U>(
  _ success: @escaping (Success) -> U,
  or failure: @escaping (Failure) -> U
) -> (Result<Success, Failure>) -> U {
  Result.either(success, or: failure)
}

/// Either map the success case or the failure case.
@inlinable
public func bimap<Success, Successʼ, Failure: Swift.Error, Failureʼ: Swift.Error>(
  success: @escaping (Success) -> Successʼ,
  failure: @escaping (Failure) -> Failureʼ
) -> (Result<Success, Failure>) -> Result<Successʼ, Failureʼ> {
  Result.bimap(success: success, failure: failure)
}

/// Returns the result of mapping either value with an homogenous result.
///
/// Performs a functional case analysis transformation over _either_
/// `success` _or_ `failure`, depending on which one this instance
/// holds, with each function returning the same type
///
/// - Invariant: The result type for both transforms is guaranteed to equal.
@inlinable
public func either<Failure: Swift.Error, U>(
  _ success: @escaping @autoclosure () -> U,
  or failure: @escaping (Failure) -> U
) -> (Result<(), Failure>) -> U {
  { result in result.either(success, or: failure) }
}

/// Either run a side effect on the unwrapped value for the success case, or
/// another side-effect on the unwrapped error for the failure case of this
/// `Result` instance.
@inlinable
public func when<Success, Failure: Swift.Error>(
  success: @escaping (Success) -> (),
  failure: @escaping (Failure) -> () = discard
) -> (Result<Success, Failure>) -> () {
  Result.when(success: success, failure: failure)
}

/// Return this instance of `Result` after running either a side effect on
/// the unwrapped value for the success case, or another side-effect on the
/// unwrapped error for the failure case of this `Result` instance.
@inlinable
public func tap<Success, Failure: Swift.Error>(
  _ sink: @escaping (Success) -> ()
) -> (Result<Success, Failure>) -> Result<Success, Failure> {
  Result.tap(sink)
}

public func select<Root, Failure: Swift.Error, Value>(
  _ path: KeyPath<Root, Value?>,
  or failure: Failure
) -> (Result<Root, Failure>) -> Result<Value, Failure> {
  Result.select(path, or: failure)
}

public func select<Success, Failure: Swift.Error, Successʼ, Successˮ>(
  _ path₁: KeyPath<Success, Successʼ?>,
  _ path₂: KeyPath<Success, Successˮ?>,
  or failure: Failure
) -> (Result<Success, Failure>) -> Result<(Successʼ, Successˮ), Failure> {
  Result.select(path₁, path₂, or: failure)
}

/// Zips two result success discarding the failure of the second Result iff
/// both `Result` instances represent failures.
///
/// - Parameters:
///   - result₀: The first result to `zip`.
///   - result₁: The second result to `zip`.
/// - Returns: A single `Result` holding both successes, a failure or the
///   failure of the first `Result` if both are failures.
@inlinable
public func zip<Success₀, Success₁, Failure: Swift.Error>(
  _ result₀: Result<Success₀, Failure>,
  _ result₁: @autoclosure () -> Result<Success₁, Failure>
) -> Result<(Success₀, Success₁), Failure> {
  result₀.flatMap { l in result₁().map { r in (l, r) } }
}
