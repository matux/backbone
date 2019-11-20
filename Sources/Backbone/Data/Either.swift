//swiftlint:disable newline_after_brace_closing
import Swift

// MARK: - Constructors

//infix operator |^| : LogicalDisjunctionPrecedence

/// Performs a nil-coalescing operation, returning an `Either` with the wrapped
/// value of the `Optional` on the left-hand side or the one on the right-hand
/// side.
///
/// This is the polymorphic variant of the stdlib nil-coalescing `??` operator,
/// enabling the coalescing of unrelated types.
///
/// A nil-coalescing operation unwraps the left-hand side if it has a value,
/// returns the right-hand side as an right, or `nil` in case no value
/// is availalbe. The result of this operation will have the `Either` type of
/// the left-hand side's `L` type and the right-hand side's value type.
///
/// This operator uses short-circuit evaluation: the left-hand side is checked
/// first, and the right-hand side is evaluated only if the former is `nil`.
///
/// - Parameters:
///   - lhs: An optional value.
///   - rhs: A value to use as the right. `rhs` does not need be of the same
///     type as the `lhs`.
@_transparent
public func | <L, R>(
  lhs: L?,
  rhs: @autoclosure () -> R?
) -> Either<L, R>? {
  return lhs.map(Either.left) ?? rhs().map(Either.right)
}

/// Performs a nil-coalescing operation, returning an `Either` with the wrapped
/// value of an `Optional` instance or a right value.
///
/// This is the polymorphic variant of the stdlib nil-coalescing `??` operator,
/// enabling the coalescing of unrelated types.
///
/// A nil-coalescing operation unwraps the left-hand side if it has a value, or
/// it returns the right-hand side as a default. The result of this operation
/// will have the `Either` type of the left-hand side's `L` type and the
/// right-hand side's value type.
///
/// This operator uses short-circuit evaluation: the left-hand side is checked
/// first, and the right-hand side is evaluated only if the lhs is `nil`.
///
/// - Parameters:
///   - maybe: An optional value.
///   - choice: A value to use as the right. `choice` does not need to be
///     the same type as the `left`.
@_transparent
public func | <L, R>(
  lhs: L?,
  rhs: @autoclosure () throws -> R
) rethrows -> Either<L, R> {
  return try .init(lhs, or: rhs())
}

// TODO: Use Either's polymorphic capability to create a "?:"-type of ternary
// TODO: Make Either work nicely with ??
// TODO: Collect an Eithers lefts and rights
// TODO: Add Either other less common functions as we find a need for them.

// TODO: Try to @_frozen Either
// https://bugs.swift.org/browse/SR-5658
// https://github.com/apple/swift/pull/13573

// TODO: Make Either play nice so we can do Gen(in: 1...3).emit()
//public init(in range: Either<ClosedRange<A>, Range<A>>) {
//    self = range.either(do: Gen().in, or: Gen().in)
//}

// TODO: MonadError combinators:
// hush :: R m => Either e a -> m a Source #
// note :: MonadError e m => e -> Maybe a -> m a Source #
// tryIO :: MonadIO m => IO a -> ExceptT IOException m a Source #
// (<<$>>) :: (Functor f, Functor g) => (a -> b) -> f (g a) -> f (g b) infixl 4 Source #foreach :: Functor f => f a -> (a -> b) -> f b Source #
// head :: Foldable f => f a -> Maybe a Source #
// sortOn :: Ord o => (a -> o) -> [a] -> [a] Source #
// ordNub :: Ord a => [a] -> [a] Source #
// list :: [b] -> (a -> b) -> [a] -> [b] Source #
// product :: (Foldable f, Num a) => f a -> a Source #
// sum :: (Foldable f, Num a) => f a -> a Source #
// concatMapM :: Monad m => (a -> m [b]) -> [a] -> m [b] Source #
// liftM' :: Monad m => (a -> b) -> m a -> m b Source #
// liftM2' :: Monad m => (a -> b -> c) -> m a -> m b -> m c Source #

/// x + Never ≅ x  =  x + 0  =  x
public typealias IdentitySum<T> = Either<T, Never>

/// x * Never ≅ Never  =  x × 0  =  0
public typealias IdentityProduct<T> = (T, Never)

/// Riꞥg = a * (b + c) ≅ (a + b) * (a + c)
public typealias Rig<A, B, C> = (A, Either<B, C>)

// MARK: -

/// An enumeration encoding two values whose existence is mutually exclusive:
/// a left and an right.
///
/// Either represents a biased-towards-left exclusive disjunction (`xor`)
/// construction of two types. It is a more advanced form of Swift's `Result`
/// in that its types are not constrained in any way.
///
/// - Important: More advanced doesn't mean better. Choose the right tool for
/// the problem. If you need to encode success and failure, `Optional` and
/// `Result` are probably what you're looking for.
/// - Note: `Result` and `Either` are closely related in that `Result` _is_
/// `Either` with an `Error`-type requirement for on one of its cases.
///
/// ### Understanding Sum-types
/// Constructions such as `Optional`, `Result` or `Either` are called sum-types
/// because they form the sum of their potential values.
///
///     Either<Bool, Bool>  = Bool + Bool  = 2 + 2 = 4
///     Either<Bool, These> = Bool + Three = 2 + 3 = 5
///     Either<Bool, UInt8> = Bool + Three = 2 + 255 = 257
///
/// - `Bool` represents two possible values, `true` or `false`.
/// - `These` represents three possible values, `this`, `that`, `these`.
/// - `UInt8` represents 8-bits of possible values.
///
/// - Remark: `Either` is similar to `Optional`, except that it is covariant
///   on both casesm thus its coalescing operation yields polymorphically
/// - Important: If you're looking to encode cases of `success` and `failure`,
///   Swift's failure-monads Optional and Result may be better suited for the
///   task.
///
/// ### Constructing Either-types
///
/// `Either` uses Swift's `Optional` mechanism together and the coalescing
/// operation to create new instances, together with its powerful type system,
/// Swift can decide for us the most convenient instance based on whether the
/// coalescing types match or would require the more powerful polymorphic
/// capabilities of `Either`.
///
/// ### Example
///
/// The type `Either<String, Int>` is the type of values which can be either a
/// `String` or an `Int`. The `.left` case constructor can be used only on
/// `Strings`, and the `.right` case constructor can be used only on
/// `Ints`:
///
///     let a = "Ten"
///     let b = 10
///     let ab = a ?? b
///     print(type(of: ab))
///     // prints Either<A, B>
///
/// ### Functorial bias towards left
///
/// The `map` from our `Functor` instance will ignore `.right` cases, but
/// will conditionally apply the supplied transformation to `.left` case
/// values.
///
/// ### A more complex example
///
///     let data = try? fetchData(model.id) // ⟹ Data?
///     let url = model.remoteLocation      // ⟹ URL
///     let dataOrUrl = data ?? url         // ⟹ Either<Data, URL>.right
///     loadObject(using: dataOrUrl)        // ⟹ func expects 𝑒𝑖𝑡ℎ𝑒𝑟 Data 𝑜𝑟 URL
/// - - -
/// ### See more
/// - https://github.com/apple/swift-evolution/blob/master/proposals/0235-add-result.md
/// - https://github.com/apple/swift/blob/master/docs/ErrorHandlingRationale.rst
/// - https://wiki.haskell.org/Failure
public enum Either<L, R> {

  /// Creates an instance that stores the given value.
  case left(L)

  /// Creates an instance that stores the given value.
  case right(R)

  /// The underlying type for the left case, externally referenceable.
  public typealias Left = L

  /// The underlying type for the right case, externally referenceable.
  public typealias Right = R

  /// Returns the left value in the instance or `nil` if there's none.
  @inlinable
  public var left: L? {
    return either(id, or: const(.none))
  }

  /// Returns the right value in the instance or `nil` if there's none.
  @inlinable
  public var right: R? {
    return either(const(.none), or: id)
  }

  @_transparent
  public init(_ l: L?, or r: @autoclosure () throws -> R) rethrows {
    switch l {
    case let x?:
      self = .left(x)
    case .none:
      self = .right(try r())
    }
  }
}

extension Either where L == () {

  /// Creates an instance with the empty tuple `()` stored in it.
  public static var left: Self {
    return .left(())
  }

  /// Given a `Either<(), R>`, attempts to create the right case or defaults
  /// to `()` in case its `nil`.
  ///
  /// - Parameter right: The right value for `Either`.
  @_transparent
  public init(_ right: R?) {
    switch right {
    case .none: self = .left
    case let .some(x): self = .right(x)
    }
  }
}

extension Either where R == () {

  /// Creates an instance with the empty tuple `()` stored in it.
  public static var right: Self {
    return .right(())
  }

  /// Given a `Either<L, ()`, attempts to create the `L?`
  /// `Either` or defaults to `()` in case is `nil`.
  ///
  /// - Parameter left: The left value for `Either`.
  @_transparent
  public init(_ left: L?) {
    self.init(left, or: ())
  }
}

extension Either {

  /// Returns the result of transforming either value.
  ///
  /// Performs a functional case analysis transformation over _either_ the
  /// left _or_ the right, depending on which one this instance
  /// holds.
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  ///
  /// ```
  /// either :: (a -> c) -> (b -> c) -> Either a b -> c
  /// ```
  @inlinable
  public func either<Result>(
    _ ltransform: (L) throws -> Result,
    or rtransform: (R) throws -> Result
  ) rethrows -> Result {
    switch self {
    case let .left(x):
      return try ltransform(x)
    case let .right(x):
      return try rtransform(x)
    }
  }
}

// MARK: -

extension Either {
  // MARK: Functor (map)
  public typealias A = L

  /// A left-biased Either constructor.
  ///
  /// - Parameter left: The `left` value for Either.
  @_transparent
  public init(_ x: L) {
    self = .left(x)
  }

  /// Either evaluates the given closure, passing the right value unwrapped
  /// as a parameter and repacking it, or return the instance untouched.
  @inlinable
  public func imap(
    _ transform: (L) -> L
  ) -> Either {
    return bimap(transform, id)
  }

  /// Either evaluates the given closure, passing the right value unwrapped
  /// as a parameter and repacking it, or return the instance untouched.
  ///
  /// For `Either`, or any `Bifunctor`-type such as `Result`, you can use
  /// `map` when you need to operate on an optional right value and the left
  /// value can be ignored in case there is no right value.
  ///
  /// For a safer right, however, consider using `Optional`, or applying
  /// the `either` or `bimap` functions, which appropriately performs case
  /// analysis considering both the `left` and the `right`.
  ///
  /// - Parameter transform: A closure that takes the right value unwrapped
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is the
  ///   `.right` value, it is returned untouched.
  @inlinable
  public func map <Lꞌ>(
    _ transform: (L) -> Lꞌ
  ) -> Either<Lꞌ, R> {
    return bimap(transform, id)
  }
}

extension Either /*: Bifunctor*/ {

  // MARK: Bifunctor (bimap)

  public init(_ x: R) {
    self = .right(x)
  }

  /// Returns the result of transforming the left in this instance or
  /// the instance itself untouched in case of right.
  @inlinable
  public func lmap<L𖾓>( //
    _ transform: (L) -> L𖾓
    ) -> Either<L𖾓, R> {
    return bimap(transform, id)
  }

  /// Map over the right value of this instance of `Either` covariantly or
  /// return the instance untouched.
  @inlinable
  public func rmap<R𖾓>(
    _ transform: (R) -> R𖾓
    ) -> Either<L, R𖾓> {
    return bimap(id, transform)
  }

  /// Return the result of transforming either the left or the
  /// right value in this instance
  @inlinable
  public func bimap<L´, R´>(
    _ transform: (L) -> L´,
    _ transform´: (R) -> R´
  ) -> Either<L´, R´> {
    switch self {
    case .left(let x):
      return .init(transform(x))
    case .right(let x):
      return .init(transform´(x))
    }
  }
}

extension Either /*: Applicative*/ { // MARK: Applicative (apply)

  @inlinable
  public func apply<L´>(
    _ either: Either<(L) -> L´, R>
  ) -> Either<L´, R> {
    switch self {
    case .left(let l):
      return either.bimap(with(l), id)
    case .right(let x):
      return .init(x)
    }
  }
}

extension Either /*: Monad*/ { // MARK: Monad (flatMap)

  @inlinable
  public func flatMap <L´>(
    _ transform: (L) -> Either<L´, R>
  ) -> Either<L´, R> {
    switch self {
    case .left(let x):
      return transform(x)
    case .right(let x):
      return .right(x)
    }
  }
}

// MARK: - Transformers

extension Either where R == Error {

  @_transparent
  public static func formThrowing<A>(
    _ λ: @escaping (A) -> Either
  ) -> (A) throws -> L {
    return {
      switch λ($0) {
      case let .left(x): return x
      case let .right(error): throw error
      }
    }
  }

  @_transparent
  public static func formResult<A>(
    _ λ: @escaping (A) throws -> L
  ) -> (A) -> Either {
    return {
      do {
        return .left(try λ($0))
      } catch {
        return .right(error)
      }
    }
  }
}

// MARK: - Base conformances

extension Either: Equatable
  where L: Equatable, R: Equatable
{
  // MARK: Equatable

  @inlinable
  public static func == (lhs: Either, rhs: Either) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs == rhs
    case let (.right(lhs), .right(rhs)):
      return lhs == rhs
    case (.left, .right),
         (.right, .left):
      return false
    }
  }

  @inlinable
  public static func ~= (
    lhs: Either,
    rhs: (L) -> Either
    ) -> Bool {
    switch lhs {
    case .left(let value):
      return rhs(value) == lhs
    case .right:
      return false
    }
  }

  @inlinable
  public static func ~= (
    lhs: Either,
    rhs: (R) -> Either
    ) -> Bool {
    switch lhs {
    case .right(let right):
      return rhs(right) == lhs
    case .left:
      return false
    }
  }
}

extension Either: Comparable
  where L: Comparable, R: Comparable
{
  // MARK: Comparable

  @inlinable
  public static func < (lhs: Either, rhs: Either) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs < rhs
    case let (.right(lhs), .right(rhs)):
      return lhs < rhs
    case (.left, .right),
         (.right, .left):
      return false
    }
  }
}

extension Either: Hashable where L: Hashable, R: Hashable { }

// MARK: - Convertibles

extension Either: CustomStringConvertible
  where L: CustomStringConvertible,
  R: CustomStringConvertible
{
  public var description: String {
    let convertible = left ?? right as CustomStringConvertible
    return convertible.description
  }
}

extension Either: CustomDebugStringConvertible
  where L: CustomDebugStringConvertible,
  R: CustomDebugStringConvertible
{
  public var debugDescription: String {
    let convertible = left ?? right as CustomDebugStringConvertible
    return convertible.debugDescription
  }
}

//extension Either: CustomBriefStringConvertible
//  where L: CustomBriefStringConvertible,
//  R: CustomBriefStringConvertible
//{
//  public var briefDescription: String {
//    let convertible = left ?? right as CustomBriefStringConvertible
//    return convertible.briefDescription
//  }
//}
