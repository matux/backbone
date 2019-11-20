// TODO: Generalize an AnySumType so all sum types (eg. Either, Optional, Result) share functionality for free?
import Swift

/// Since `Optional` is a generic `enum`, `Optional.Wrapped` must be declared
/// as a generic parameter instead of an `associatedtype`, this means we can't
/// constrain it. We workaround this limitation by extending `Optional` with a
/// `protocol` that effectively defines `Wrapped` _also_ as an `associatedtype`.
public protocol AnyOptional: ExpressibleByNilLiteral {
  /// The type of value the Optional holds.
  associatedtype Wrapped

  /// Returns the value wrapped in the given instance iff it is possible to do
  /// so, otherwise, a `nil` is returned.
  static func unwrap(_ it: Self) -> Wrapped?

  /// Returns the value wrapped in the given instance unconditionally,
  /// triggering a runtime error if it is not possible to return it.
  static func unwrapǃ(_ it: Self) -> Wrapped

  /// Lifts the given value, wrapping it into a new instance of this type.
  init(_ some: Wrapped)

  /// Any instance of Optional that is absent of a value can be expressed
  /// with `nil`, and `nil` has no type information in and off itself,
  /// therefore, `AnyOptional` should be constructible without requiring
  /// structural knowledge of the conforming type.
  init(nilLiteral: ())

  /// Returns the value wrapped or `nil` if there is none.
  ///
  /// Use the `some` computed value to safely access a value wrapped in an enum
  /// case with an associated value without a `let` binding.
  var some: Wrapped? { get }

  /// Returns the value wrapped in this instance unconditionally, triggering a
  /// runtime error if it is not possible to return it.
  var someǃ: Wrapped { get }
}

// MARK: - Query

extension AnyOptional {

  public static var hasSome: (Wrapped?) -> Bool { return { $0.hasSome } }
  public static var isNil: (Wrapped?) -> Bool { return { $0.isNil } }

  public var hasSome: Bool { return some != nil }
  public var isNil: Bool { return some == nil }
}

public func isSome<T>(_ optional: T?) -> Bool { return optional.hasSome }
public func isNone<T>(_ optional: T?) -> Bool { return optional.isNil }

// MARK: - KeyPath

extension KeyPath where Value: AnyOptional {
  public typealias SomeOptional = Value

  /// Performs a nil-coalescing operation, returning the wrapped value of an
  /// `Optional` instance or a default value.
  ///
  /// A nil-coalescing operation unwraps the left-hand side if it has a value, or
  /// it returns the right-hand side as a default. The result of this operation
  /// will have the non-optional type of the left-hand side's `Wrapped` type.
  ///
  /// This operator uses short-circuit evaluation: `optional` is checked first,
  /// and `defaultValue` is evaluated only if `optional` is `nil`.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to an `Optional` value.
  ///   - defaultValue: A value to use as a default. `defaultValue` is the same
  ///     type as the `Wrapped` type of the optional value.
  /// - Returns: A function taking the `Root` value of the key path.
  @_transparent
  public static func ?? (
    path: KeyPath<Root, SomeOptional>,
    defaultValue: @escaping @autoclosure () -> SomeOptional.Wrapped
  ) -> (Root) -> SomeOptional.Wrapped? {
    return { $0[keyPath: path].some ?? defaultValue() }
  }

  /// Performs a safe unwrap on the given `Optional`, returning the unwrapped
  /// value, `nil` in case this `Optional` instance is `nil`, or executing
  /// `assertionFailure` with the given `message` iff running on a **debug**
  /// configuration and the `Optional` is `nil`.
  @_transparent
  public static func !? (
    path: KeyPath<Root, SomeOptional>,
    message: @escaping @autoclosure () -> String
  ) -> (Root) -> SomeOptional.Wrapped? {
    return { $0[keyPath: path].some !? message() }
  }

  /// Performs an unsafe force unwrap, returning the wrapped
  /// value of the given `Optional` or executing `preconditionFailure`
  /// with the given `message` in case of `nil`.
  @_transparent
  public static func !! (
    path: KeyPath<Root, SomeOptional>,
    message: @escaping @autoclosure () -> String
  ) -> (Root) -> SomeOptional.Wrapped {
    return { $0[keyPath: path].some !! message() }
  }
}

// MARK: - Equatable

extension AnyOptional where Wrapped: Equatable {

  /// Returns a Boolean value indicating whether two optional instances are
  /// equal.
  ///
  /// - Parameters:
  ///   - lhs: An optional value to compare.
  ///   - rhs: Another optional value to compare.
  /// - Returns: Whether the optional instances are equal or not.
  @inlinable
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs.some, rhs.some) {
    case let (l?, r?):
      return l == r
    case (nil, nil):
      return true
    default:
      return false
    }
  }

  /// Returns a Boolean value indicating whether the optional instance `lhs` is
  /// equal to the raw value representation of `rhs`.
  ///
  /// - Parameters:
  ///   - lhs: An optional value to compare.
  ///   - rhs: A raw representable whose raw value type matches the unwrapped
  ///     value type of the optional.
  /// - Returns: Whether the optional instances are equal or not.
  @_transparent
  public static func == <T: Equatable & RawRepresentable>(
    lhs: Self,
    rhs: T
  ) -> Bool where T.RawValue == Wrapped {
    return lhs.some.map { lhs in lhs == rhs.rawValue } ?? false
  }

  /// Returns a Boolean value indicating whether the optional instance `lhs` is
  /// equal to the raw value representation of `rhs`.
  ///
  /// - Parameters:
  ///   - lhs: A raw representable whose raw value type matches the unwrapped
  ///     value type of the optional.
  ///   - rhs: An optional value to compare.
  /// - Returns: Whether the optional instances are equal or not.
  @_transparent
  public static func == <T: Equatable & RawRepresentable>(
    lhs: T,
    rhs: Self
  ) -> Bool where T.RawValue == Wrapped {
    return rhs.some.map { rhs in lhs.rawValue == rhs } ?? false
  }
}

// MARK: - Equatable (Pattern)

extension AnyOptional where Wrapped: Equatable {

  /// Returns a Boolean value indicating whether an argument matches `nil`.
  ///
  /// You can use the pattern-matching operator (`~=`) to test whether an
  /// optional instance is `nil` even when the wrapped value's type does not
  /// conform to the `Equatable` protocol. The pattern-matching operator is used
  /// internally in `case` statements for pattern matching.
  ///
  /// The following example declares the `stream` variable as an optional
  /// instance of a hypothetical `DataStream` type, and then uses a `switch`
  /// statement to determine whether the stream is `nil` or has a configured
  /// value. When evaluating the `nil` case of the `switch` statement, this
  /// operator is called behind the scenes.
  ///
  ///     var stream: DataStream? = nil
  ///     switch stream {
  ///     case nil:
  ///         print("No data stream is configured.")
  ///     case let x?:
  ///         print("The data stream has \(x.availableBytes) bytes available.")
  ///     }
  ///     // Prints "No data stream is configured."
  ///
  /// - Note: To test whether an instance is `nil` in an `if` statement, use the
  ///   equal-to operator (`==`) instead of the pattern-matching operator. The
  ///   pattern-matching operator is primarily intended to enable `case`
  ///   statement pattern matching.
  ///
  /// - Parameters:
  ///   - lhs: A `nil` literal.
  ///   - rhs: A value to match against `nil`.
  @_transparent
  public static func ~= (lhs: Nil, rhs: Self) -> Bool {
    return rhs.some.map(const(false)) ?? true
  }

  /// Returns a Boolean value indicating whether the wrapped value in `lhs`
  /// matches a membership pattern against the values in the given collection.
  ///
  /// - Parameters:
  ///   - lhs: An optional value to compare.
  ///   - rhs: A collection of value whose type matches the unwrapped value
  ///     type of the optional `lhs`.
  /// - Returns: Whether the pattern matches or not.
  @_transparent
  public static func ~= <C: Collection>(
    rhs: C,
    lhs: Self
  ) -> Bool where C.Element == Wrapped {
    return lhs.some.map(rhs.contains) ?? false
  }

  /// Returns a Boolean value indicating whether the wrapped value in `lhs`
  /// matches an equivalence pattern against the raw value representation of
  /// `rhs`.
  ///
  /// - Parameters:
  ///   - lhs: An optional value to compare.
  ///   - rhs: A raw representable whose raw value type matches the unwrapped
  ///     value type of the optional.
  /// - Returns: Whether the pattern matches or not.
//  @_transparent
//  public static func ~= <R: RawRepresentable>(
//    rhs: R,
//    lhs: Self
//  ) -> Bool where R.RawValue == Wrapped {
//    return lhs.some.fmap(equals(rhs)) ?? false
//  }

  /// Returns a Boolean value indicating whether the wrapped value in `lhs`
  /// matches an equivalence pattern against any one raw representation of the
  /// values contained in the given set `rhs`.
  ///
  /// - Parameters:
  ///   - lhs: An optional value to compare.
  ///   - rhs: A set of raw representables whose raw value type matches the
  ///     unwrapped value type of the optional.
  /// - Returns: Whether the pattern matches or not.
  @_transparent
  public static func ~= <S: Collection, T: Hashable & RawRepresentable>(
    lhs: S,
    rhs: Self
  ) -> Bool where S.Element == T, S.Element.RawValue == Wrapped {
    return rhs.some.map { rawValue in
      lhs.contains { $0.rawValue == rawValue }
    } ?? false
  }
}

// MARK: - Hashable

extension AnyOptional where Wrapped: Hashable {

  /// Hashes the essential components of this value by feeding them into the
  /// given hasher.
  ///
  /// - Parameter hasher: The hasher to use when combining the components
  ///   of this instance.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    switch some {
    case .none:
      hasher.combine(0 as UInt8)
    case .some(let wrapped):
      hasher.combine(1 as UInt8)
      hasher.combine(wrapped)
    }
  }
}

/// Definitions for the a default protocol conformance.
extension AnyOptional {

  /// Returns the value wrapped in the given instance iff it is possible to do
  /// so, otherwise, a `nil` is returned.
  @inlinable
  public static func unwrap(_ it: Self) -> Wrapped? {
    return it.some
  }

  /// Returns the value wrapped in the given instance unconditionally,
  /// triggering a runtime error if it is not possible to return it.
  @inlinable
  public static func unwrapǃ(_ it: Self) -> Wrapped {
    return it.some!
  }

  /// Returns the value wrapped in this instance unconditionally, triggering a
  /// runtime error if it is not possible to return it.
  @inlinable
  public var someǃ: Wrapped {
    return some!
  }
}

// MARK: -

// These should probably be in `Optional.swift`

extension Optional: AnyOptional {

  public var some: Wrapped? {
    return map(id)
  }
}

// Monad

// Comonad
extension AnyOptional where Wrapped: Identity {

  /// The dual of `init`
  ///
  ///     extract :: w a -> a
  @inlinable
  public static func extract(_ wa: Wrapped?) -> Wrapped {
    switch wa.some {
    case let .some(a):
      return a
    case .none:
      return .empty
    }
  }

  /// The dual of flatMap (aka. bind, =<<)
  ///
  ///     (<<=) :: Comonad w => (w a -> b) -> w a -> w b
  ///     extend f = fmap f . duplicate
  @inlinable
  public static func extend<U>(
    _ f: @escaping (Wrapped?) -> U
  ) -> (Wrapped?) -> U? {
    return fmap(f) • duplicate
  }

  /// The dual of join,
  ///
  ///     duplicate :: w a -> w (w a)
  ///     duplicate = extend id
  @inlinable
  public static func duplicate(_ optional: Wrapped?) -> Optional<Wrapped?> {
    return extend(id)(optional)
  }
}
