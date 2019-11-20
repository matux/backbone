import Swift

/// The type of values that can be either true or false, but never both.
///
/// This ADT⁽¹⁾ is mostly redundant and serves only as an exploration on sum
/// types.
///
/// A sum type corresponds to the exclusive disjunction logical connective (`xor`/`^`) of types in
/// logic and
///
/// `enum` is the sum type constructor in Swift. The "sum" in sum type refers
/// to the fact the  sum of all possible values:
///
///     enum { case ⊤, ⊥ } = ⊤ 𝒙𝒐𝒓 ⊥ = 1 + 1 = 2
///
///
///
/// - TODO: @frozen
/// - - -
/// ⁽¹⁾ _Algebraic data type_
public enum Boolean: CaseIterable {
  case ꓔ, ꓕ

  /// Creates an instance initialized to `false`.
  ///
  /// Do not call this initializer directly. Instead, use the Boolean literal
  /// `false` to create a new `Bool` instance.
  @_transparent
  public init() {
    self = .ꓕ
  }

  /// Creates an instance initialized to the given `Bool` value.
  ///
  /// - Parameter bool: The `Bool` value to use for the new instance.
  @_transparent
  public init(_ bool: Bool) {
    self = bool ? .ꓔ : .ꓕ
  }
}

extension Boolean: RawRepresentable
  & ExpressibleByBooleanLiteral
  & ExpressibleByIntegerLiteral
  & ExpressibleByStringLiteral
  & ExpressibleByNilLiteral
{
  public typealias IntegerLiteralType = Int
  public typealias StringLiteralType = String

  public var rawValue: Bool {
    return self == .ꓔ
  }

  /// Creates an instance initialized to the given `Bool` value.
  ///
  /// - Parameter bool: The `Bool` value to use for the new instance.
  @_transparent
  public init(rawValue: Bool) {
    self.init(rawValue)
  }

  /// Creates an instance initialized to the given `Bool` value.
  ///
  /// - Parameter bool: The `Bool` value to use for the new instance.
  @_transparent
  public init(booleanLiteral: Bool) {
    self.init(booleanLiteral)
  }

  @_transparent
  @_specialize(exported: true, kind: full, where Integer == Int)
  public init<Integer: BinaryInteger>(integerLiteral: Integer) {
    self.init(integerLiteral != .zero)
  }

  @inlinable
  public init(stringLiteral: String) {
    switch stringLiteral.lowercased() {
    case "true",  "1", "yes"  : self = .ꓔ
    case "false", "0", "no", _: self = .ꓕ
    }
  }

  @inlinable
  public init(_ string: String) {
    switch string.lowercased() {
    case "true",  "1", "yes"  : self = .ꓔ
    case "false", "0", "no", _: self = .ꓕ
    }
  }

  @_transparent
  public init(nilLiteral: ()) {
    self.init(false)
  }
}

