import protocol Swift.AdditiveArithmetic
import protocol Swift.Numeric
import protocol Swift.SignedNumeric

// arithmetic operations against Optional instances where the left-hand side is
// returned in case the right-hands side is `nil` to avoid breaking equations
// or let binding boilerplate to be used in cases where equational reasoning
// takes precedence over optional binding.

infix operator *? : MultiplicationPrecedence
infix operator /? : MultiplicationPrecedence
infix operator +? : AdditionPrecedence
infix operator -? : AdditionPrecedence

extension AdditiveArithmetic where Self: ExpressibleByIntegerLiteral {

  /// The zero value.
  ///
  /// Zero is the identity element for addition. For any value,
  /// `x + .zero == x` and `.zero + x == x`.
  @_transparent
  public static var zero: Self {
    return 0
  }

  /// Returns a `Boolean` indicating whether the given number is zero.
  @_transparent
  public static func isZero(value: Self) -> Bool {
    return value.isZero
  }

  /// A `Boolean` value indicating whether the instance is equal to zero.
  ///
  /// The `isZero` property of a value `x` is `true` when `x` represents `0`.
  /// `x.isZero` is equivalent to `x == 0`.
  @_transparent
  public var isZero: Bool {
    return self == Self.zero
  }
}

extension Numeric where Self: ExpressibleByIntegerLiteral {

  /// The unit value.
  ///
  /// Unit is the identity element for multiplication. For any value,
  /// `x * .unit == x` and `.unit * x == x`.
  @_transparent
  public static var unit: Self {
    return 1
  }

  /// Returns a `Boolean` indicating whether the given number is zero.
  @_transparent
  public static func isUnit(value: Self) -> Bool {
    return value.isUnit
  }

  /// A `Boolean` value indicating whether the instance is equal to zero.
  ///
  /// The `isUnit` property of a value `x` is `true` when `x` represents `0`.
  /// `x.isUnit` is equivalent to `x == 0`.
  @_transparent
  public var isUnit: Bool {
    return self == Self.unit
  }
}

extension SignedNumeric {

  /// Returns the additive inverse of a value.
  ///
  /// Negating a value results in the additive inverse of that value.
  ///
  ///     let y = SignedNumeric.negate(21)
  ///     // y == -21
  ///
  /// The resulting value must be representable in the same type as the
  /// argument. In particular, negating a signed, fixed-width integer type's
  /// minimum results in a value that cannot be represented.
  ///
  ///     let z = SignedNumeric.negate(Int8.min)
  ///     // Overflow error︀
  ///
  /// - Returns: The additive inverse of a value.
  public static func negate(value: Self) -> Self {
    return value.negated()
  }

  /// Returns the additive inverse of this value.
  ///
  /// Negation returns the additive inverse of this value.
  ///
  ///     let x = 21
  ///     let y = x.negated()
  ///     // y == -21
  ///
  /// The resulting value must be representable in the same type as the
  /// argument. In particular, negating a signed, fixed-width integer type's
  /// minimum results in a value that cannot be represented.
  ///
  ///     let z = -Int8.min
  ///     // Overflow error
  ///
  /// - Returns: The additive inverse of this value.
  public func negated() -> Self {
    return -self
  }
}

// MARK: - Optional arithmetic -

extension AdditiveArithmetic {

  /// Attempts to add the value on the left-hand side `lhs` to the `Optional`
  /// value on the right-hand side `rhs` — or return `lhs` if `rhs` is `nil`.
  ///
  /// - Parameters:
  ///   - lhs: A value to add.
  ///   - rhs: An Optional value of the same type.
  /// - Returns: The sum of `lhs` and `rhs` or just `lhs` if `rhs` is `nil`.
  @_transparent
  public static func +? (lhs: Self, rhs: Self?) -> Self {
    return rhs.map { lhs + $0 } ?? lhs
  }

  /// Attempts to subtract the value on the left-hand side `lhs` from the
  /// `Optional` value on the right-hand side `rhs` — or return `lhs` if
  /// `rhs` is `nil`.
  ///
  /// - Parameters:
  ///   - lhs: A value to subtract.
  ///   - rhs: An Optional value of the same type.
  /// - Returns: The subtraction of `lhs` and `rhs` or just `lhs` if `rhs` is
  ///   `nil`.
  @_transparent
  public static func -? (lhs: Self, rhs: Self?) -> Self {
    return rhs.map { lhs - $0 } ?? lhs
  }
}

extension Numeric {

  /// Attempts to multiply the value on the left-hand side `lhs` by the
  /// `Optional` value on the right-hand side `rhs` — or return `lhs` if
  /// `rhs` is `nil`.
  ///
  /// - Parameters:
  ///   - lhs: A value to multiply.
  ///   - rhs: An Optional value of the same type.
  /// - Returns: The product of `lhs` and `rhs` or just `lhs` if `rhs` is
  ///   `nil`.
  @_transparent
  public static func *? (lhs: Self, rhs: Self?) -> Self {
    return rhs.map { lhs * $0 } ?? lhs
  }
}

extension BinaryFloatingPoint {

  /// Attempts to divide the value on the left-hand side `lhs` by the
  /// `Optional` value on the right-hand side `rhs` — or return `lhs` if
  /// `rhs` is `nil`.
  ///
  /// - Parameters:
  ///   - lhs: A value to divide.
  ///   - rhs: An Optional value of the same type.
  /// - Returns: The division of `lhs` and `rhs` or just `lhs` if `rhs` is
  ///   `nil`.
  @_transparent
  public static func /? (lhs: Self, rhs: Self?) -> Self {
    return rhs.map { lhs / $0 } ?? lhs
  }
}

extension BinaryInteger {

  /// Attempts to divide the value on the left-hand side `lhs` by the
  /// `Optional` value on the right-hand side `rhs` — or return `lhs` if
  /// `rhs` is `nil`.
  ///
  /// - Parameters:
  ///   - lhs: A value to divide.
  ///   - rhs: An Optional value of the same type.
  /// - Returns: The division of `lhs` and `rhs` or just `lhs` if `rhs` is
  ///   `nil`.    @_transparent
  public static func /? (lhs: Self, rhs: Self?) -> Self {
    return rhs.map { lhs / $0 } ?? lhs
  }
}

// MARK: - Numeric casts

/// Returns the given integer as the equivalent value if another integer type.
///
/// Use `integerCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The integer to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func integerCast<A: BinaryInteger, B: BinaryInteger>(
  _ x: A
) -> B {
  return B(x)
}

/// Returns the given integer as the equivalent value if another integer type.
///
/// Use `integerCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The integer to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func integerCast<A: BinaryInteger, B: BinaryInteger>(
  _ x: A, _ y: A
) -> (B, B) {
  return (B(x), B(y))
}

/// Returns the given integer as the equivalent value if another integer type.
///
/// Use `integerCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The integer to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func integerCast<A: BinaryInteger, B: BinaryInteger>(
  _ x: A, _ y: A, _ z: A
) -> (B, B, B) {
  return (B(x), B(y), B(z))
}

/// Returns the given integer as the equivalent value if another integer type.
///
/// Use `integerCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The integer to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func integerCast<A: BinaryInteger, B: BinaryInteger>(
  _ x: A, _ y: A, _ z: A, _ w: A
) -> (B, B, B, B) {
  return (B(x), B(y), B(z), B(w))
}

/// Returns the given floating point value as the equivalent value in another
/// floating point type.
///
/// Use `floatingCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The floating point to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func floatingCast<A: BinaryFloatingPoint, B: BinaryFloatingPoint>(
  _ x: A
) -> B {
  return B(x)
}

/// Returns the given floating point value as the equivalent value in another
/// floating point type.
///
/// Use `floatingCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The floating point to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func floatingCast<A: BinaryFloatingPoint, B: BinaryFloatingPoint>(
  _ x: A, _ y: A
) -> (B, B) {
  return (B(x), B(y))
}

/// Returns the given floating point value as the equivalent value in another
/// floating point type.
///
/// Use `floatingCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The floating point to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func floatingCast<A: BinaryFloatingPoint, B: BinaryFloatingPoint>(
  _ x: A, _ y: A, _ z: A
) -> (B, B, B) {
  return (B(x), B(y), B(z))
}

/// Returns the given floating point value as the equivalent value in another
/// floating point type.
///
/// Use `floatingCast(_:)` to convert a value when the destination type can be
/// inferred through context.
///
/// - Note: This function traps on overflow in `-O` and `-Onone` builds.
/// - Parameter x: The floating point to convert, and instance of type `A`.
/// - Returns: The value of `x` converted to type `B`.
@inlinable
public func floatingCast<A: BinaryFloatingPoint, B: BinaryFloatingPoint>(
  _ x: A, _ y: A, _ z: A, _ w: A
) -> (B, B, B, B) {
  return (B(x), B(y), B(z), B(w))
}
