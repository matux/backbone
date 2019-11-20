import Swift

// https://wiki.haskell.org/Typeclassopedia#Monoid

///┌──────────────╥─────┬─────┬─────┬─────┬─────╥─────┐
///│ ░▒▓██████▓▒░ ║AA->A│⁽⁾⁼⁽⁾│  ε  │ x⁻¹ │ˣʸ⁼ʸˣ║  ·  │
///├══════════════╬─────┼─────┼─────┼─────┼─────╬─────┤
// │ Semigroupoid ║░░░░░│  ✓  │░░░░░│░░░░░│░░░░░║  •  │
// │     Category ║░░░░░│  ✓  │  ✓  │░░░░░│░░░░░║  ε  │
// │     Groupoid ║░░░░░│  ✓  │  ✓  │  ✓  │░░░░░║ x⁻¹ │
///│        Magma ║  ✓  │░░░░░│░░░░░│░░░░░│░░░░░║  ·  │
// │   Quasigroup ║  ✓  │░░░░░│░░░░░│  ✓  │░░░░░║  -  │
///│    Semigroup ║  ✓  │  ✓  │░░░░░│░░░░░│░░░░░║  +  │
// │         Loop ║  ✓  │░░░░░│  ✓  │  ✓  │░░░░░║  ÷  │
///│       Monoid ║  ✓  │  ✓  │  ✓  │░░░░░│░░░░░║ + × │
// │        Group ║  ✓  │  ✓  │  ✓  │  ✓  │░░░░░║ x⁻¹ │
// │Abelian Group ║  ✓  │  ✓  │  ✓  │  ✓  │  ✓  ║ ⨁⨂ │
///└──────────────╨─────┴─────┴─────┴─────┴─────╨─────┘
//

public typealias Monoid = Closure & Associative & Identity
//public typealias Monoid = Semigroup & Identity

/// A `Monoidal` type with an identity element `empty` that further specializes
/// the behavior of the `combine` operation.
///
/// A monoid is a structure with an associative binary function and a value
/// which acts as an identity, denoted by (`𝑒`), with respect to that function. Meaning that upon
/// being applied to some other value, the result is always equal to that value.
/// Eg.: `1` is the identity with respect to integer multiplication
/// (`x * 1 = x`), the empty array (`[]`) is the identity with respect to array
/// concatenation (`[1, 2, 3] + [] = [1, 2, 3]`), the empty string (`""`) to
/// string concat and interpolation (`"hello\("")" = "hello"`, `"a" + "" = "a"`)
/// and the empty tuple (`()`) throws an error. See how the pattern arises with
/// structures modeled after mathematics and breaks down when going against it?
/// All operations are abstracted under the semigroup binary operation, denoted
/// here as the usual algebraic placeholder symbol, (`·`), pronounced "combined
/// with", and typically implemented as (`<>`) or (`++`). Many monoids exist in
/// Swift, `Monoid` represents them as the types which act like monoids and
/// `Monoidal` are all the types 𝑤𝑖𝑡ℎ identity.
///
/// Therefore, a `Monoid`, specified by `(𝑇,·,𝑒)` is any type `𝑇` with a
/// function:
///
///     · : 𝑇 × 𝑇 → 𝑇
///
/// Satisfying the associative property:
///
///     ∀ 𝑥𝑦𝑧 ∈ 𝑇 => (𝑥•𝑦)•𝑧 ≡ 𝑥•(𝑦•𝑧)
///
/// And with an identity `𝑒` such that any instance `𝑥` of `𝑇` satisfies:
///
///     𝑒 · 𝑥 = x · 𝑒 = 𝑥
///
/// In other words, a `Monoid` is an associative magma (aka. semigroup) with
/// an identity element.
public protocol Identity {

  /// The identity element.
  ///
  /// Also called the neutral element, it leaves values unchanged when
  /// combined with it and can be used, for example, to represent the absence
  /// of elements in a collection, or the default starting point of a folding
  /// or reduce operation.
  static var empty: Self { get }
}

extension Identity {

  /// The identity initializer
  ///
  /// A default implementation that initializes to the identity element,
  /// effectively endowing comforming types with a default initializer.
  ///
  /// - Remark: This is outside the mathematical definition of Monoid, which
  ///   is something absolutely no one cares about.
//  public init() {
//    self = Self.empty
//  }

  /// The identity function
  public static func empty(_ µ: Self) -> Self {
    return µ.self
  }
}

// MARK: -
// MARK: - Folds

extension Identity
  where Self: Monoid & Sequence,
  Self.Element: Numeric & Monoid
{
  /// The sum of all the elements in a sequence.
  @_transparent
  public static prefix func ∑ (_ xs: Self) -> Element {
    xs.reduce(.zero, +)
  }

  /// The sum of all the elements in this instance.
  @inlinable
  public var sum: Element {
    ∑self
  }

  @_transparent
  public static prefix func ∏ (_ xs: Self) -> Element {
    xs.reduce(.unit, *)
  }

  /// The product of all the elements in this instance.
  @inlinable
  public var product: Element {
    ∏self
  }
}

extension Collection where Self: Monoid, Element: BinaryFloatingPoint & Monoid {

  /// The average of the sum of all the numeric elements in the instance.
  @inlinable
  public var average: Element {
    sum / .init(count)
  }
}

extension Sequence where Self: Semigroup, Element: Monoid {

  /// Returns the result of combining the elements of the sequence using the
  /// semigroup binary operation.
  ///
  /// Use `reduce()` to produce a single value from the elements of an entire
  /// sequence. For example, you can use this method to append strings, for
  /// example:
  ///
  ///     let append = ["Hello, ", "World!"].reduce()
  ///     // append = "Hello, World!"
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func reduce() -> Element {
    reduce(into: .empty, +=)
  }
}

extension Sequence where Self: Identity {

  /// Returns the result of combining the elements of a sequence of key-value
  /// pairs which results in a `Dictionary` type.
  ///
  /// Use `reduce()` to produce a Dictionary collection out of a sequence of
  /// key-value pairs where the key component `K` is Hashable, and the result
  /// expects a Dictionary of keys of type `K` associated to values of type `V`.
  ///
  ///     allHTTPHeaderFields = header.standard
  ///       .map(product(^\.rawValue, ^\.rawValue))
  ///       .reduce()
  ///     // append = "Hello, World!"
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func reduce<K: Hashable, V>() -> [K: V] where Self.Element == (K, V) {
    reduce(into: .empty, { $0[$1.0] = $1.1 })
  }

  @inlinable
  public func reduce<Result: Identity>(
    _ nextPartialResult: (Result, Element) -> Result
  ) -> Result {
    reduce(.empty, nextPartialResult)
  }

  @inlinable
  public func reduce<Result: Identity>(
    _ updateAccumulatingResult: (inout Result, Element) -> ()
  ) -> Result {
    reduce(into: .empty, updateAccumulatingResult)
  }
}

// MARK: - Fold static thunks

extension Sequence where Self: Monoid, Element: Numeric & Monoid {

  /// Returns the sum of all the elements in the given instance.
  @inlinable
  public static func sum(_ seq: Self) -> Element {
    ∑seq
  }

  /// Returns the product of all the elements in the given instance.
  @inlinable
  public static func product(_ seq: Self) -> Element {
    ∏seq
  }
}

extension Collection where Self: Monoid, Element: BinaryFloatingPoint & Monoid {

  /// Returns the average of the sum of all the elements in the given instance.
  @inlinable
  public static func average(_ seq: Self) -> Element {
    seq.average
  }
}

extension Sequence where Self: Semigroup, Self.Element: Monoid {

  /// Returns the result of combining the elements of the sequence using the
  /// semigroup binary operation.
  ///
  /// Use `reduce()` to produce a single value from the elements of an entire
  /// sequence. For example, you can use this method to append strings, for
  /// example:
  ///
  ///     let append = ["Hello, ", "World!"].reduce()
  ///     // append = "Hello, World!"
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func reduce(_ s: Self) -> Element {
    return s.reduce()
  }
}

/// Returns the result of combining the elements of the sequence using the
/// semigroup binary operation.
///
/// Use `reduce()` to produce a single value from the elements of an entire
/// sequence. For example, you can use this method to append strings, for
/// example:
///
///     let append = reduce(["Hello, ", "World!"])
///     // append = "Hello, World!"
///
/// If the sequence has no elements, the reduction is never executed and
/// `initialResult` is the result of the call to `reduce(_:)`.
///
/// - Returns: The final accumulated value. If the sequence has no elements,
///   the result is `initialResult`.
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func reduce<S: Sequence>(
  _ xs: S
) -> S.Element where S: Semigroup, S.Element: Monoid {
  xs.reduce()
}

extension Sequence where Self: Monoid  {

  /// Returns the result of combining the elements of a sequence of key-value
  /// pairs which results in a `Dictionary` type.
  ///
  /// Use `reduce()` to produce a Dictionary collection out of a sequence of
  /// key-value pairs where the key component `K` is Hashable, and the result
  /// expects a Dictionary of keys of type `K` associated to values of type `V`.
  ///
  ///     allHTTPHeaderFields = header.standard
  ///       .map(product(^\.rawValue, ^\.rawValue))
  ///       .reduce()
  ///     // append = "Hello, World!"
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func reduce<K: Hashable, V>(
    _ seq: Self
  ) -> [K: V] where Self.Element == (K, V) {
    seq.reduce()
  }

  @inlinable
  public static func reduce<Result: Identity>(
    _ nextPartialResult: @escaping (Result, Element) -> Result
  ) -> (Self) -> Result {
    { $0.reduce(nextPartialResult) }
  }

  @inlinable
  public static func reduce<Result: Identity>(
    _ updateAccumulatingResult: @escaping (inout Result, Element) -> ()
  ) -> (Self) -> Result {
    { $0.reduce(updateAccumulatingResult) }
  }
}

/// Returns the result of combining the elements of a sequence of key-value
/// pairs which results in a `Dictionary` type.
///
/// Use `reduce()` to produce a Dictionary collection out of a sequence of
/// key-value pairs where the key component `K` is Hashable, and the result
/// expects a Dictionary of keys of type `K` associated to values of type `V`.
///
///     allHTTPHeaderFields = header.standard
///       .map(product(^\.rawValue, ^\.rawValue))
///       .reduce()
///     // append = "Hello, World!"
///
/// If the sequence has no elements, the reduction is never executed and
/// `initialResult` is the result of the call to `reduce(_:)`.
///
/// - Returns: The final accumulated value. If the sequence has no elements,
///   the result is `initialResult`.
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func reduce<S: Sequence & Identity, K: Hashable, V>(
  _ seq: S
) -> [K: V] where S.Element == (K, V) {
  seq.reduce()
}

@inlinable
public func reduce<S: Sequence & Identity, Result: Identity>(
  _ nextPartialResult: @escaping (Result, S.Element) -> Result
) -> (S) -> Result {
  { $0.reduce(nextPartialResult) }
}

@inlinable
public func reduce<S: Sequence & Identity, Result: Identity>(
  _ updateAccumulatingResult: @escaping (inout Result, S.Element) -> ()
) -> (S) -> Result {
  { $0.reduce(updateAccumulatingResult) }
}

// MARK: -
// MARK: - Generalizations

extension Error where Self: Identity {

  @_transparent
  public static var empty: Self { .empty }
}

extension AdditiveArithmetic where Self: Identity {

  @_transparent
  public static var empty: Self { return .zero }
}

// Despite Apple documentation explicitly disencourages users from
// extending `ExpressibleBy*Literal` typeclasses, this allows us
// to cover the most ground.

extension ExpressibleByNilLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return nil }
}

extension ExpressibleByBooleanLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return false }
}

extension ExpressibleByArrayLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return [] }
}

extension ExpressibleByDictionaryLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return [:] }
}

extension ExpressibleByUnicodeScalarLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return "\u{0}" }
}

extension ExpressibleByExtendedGraphemeClusterLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return "\0" }
}

extension ExpressibleByStringLiteral where Self: Identity {

  @_transparent
  public static var empty: Self { return "" }
}

// MARK: - Witness · Memberwise monoidal

extension Array: Identity { }
extension ContiguousArray: Identity { }
extension ArraySlice: Identity { }
extension EmptyCollection: Identity {

  public static var empty: EmptyCollection {
    return .init()
  }
}

extension Repeated: Identity where Element: Identity {

  public static var empty: Repeated {
      return repeatElement(.empty, count: 0)
  }
}

extension ReversedCollection: RangeReplaceableCollection & Identity
  where Base: RangeReplaceableCollection {

  public init() {
    self.init(Base().reversed())
  }

  public static var empty: ReversedCollection {
    return .init()
  }
}

extension Slice: Identity where Base: RangeReplaceableCollection {

  @_transparent
  public static var empty: Slice {
    return .init()
  }
}

// MARK: - Witness · {{𝑆,∪,∅}, {{𝑆},∩,∅}

extension Set: Identity { }

//extension NSMutableSet: SelfAware {
//  public var empty: Self { return Self() }
//}

// MARK: - Witness · Key-value Maps

extension Dictionary: Identity { }
extension KeyValuePairs: Identity { }

// MARK: - Witness · Sums

extension Optional: Identity {

  public static var empty: Self {
    .none
  }
}

extension Result: Identity where Failure: Identity {

  public static var empty: Self {
    .failure(.empty)
  }
}

// MARK: - Witness · Foundation

import struct Dispatch.DispatchData
import struct Foundation.Data

extension DispatchData: Identity { }

extension Data: Identity {

  @_transparent
  public static var empty: Data {
    return .init()
  }
}

// MARK: - Witness · Ranges

extension Range: Identity
  where Bound: Strideable & Identity, Bound.Stride: SignedInteger
{
  @_transparent
  public static var empty: Range {
    return .empty ..< .empty
  }
}

extension ClosedRange: Identity
  where Bound: Strideable & Identity, Bound.Stride: SignedInteger
{
  @_transparent
  public static var empty: ClosedRange {
    return .empty ... .empty
  }
}

extension PartialRangeUpTo: Identity
  where Bound: Strideable & Identity, Bound.Stride: SignedInteger
{
  @_transparent
  public static var empty: PartialRangeUpTo {
    return ..<(.empty)
  }
}

extension PartialRangeThrough: Identity
  where Bound: Strideable & Identity, Bound.Stride: SignedInteger
{
  @_transparent
  public static var empty: PartialRangeThrough {
    return ...(.empty)
  }
}

// MARK: - Witness · Strings

extension Unicode.Scalar: Identity { }
extension Character: Identity { }
extension Substring: Identity { }
extension String: Identity {

  @inlinable
  public static var empty: String { "" }
}

extension String.UTF8View: Identity {

  @inlinable
  public static var empty: String.UTF8View {
    return String.empty.utf8
  }
}

extension String.UTF16View: Identity {

  @inlinable
  public static var empty: String.UTF16View {
    return String.empty.utf16
  }
}


extension String.UnicodeScalarView: Identity {

  @inlinable
  public static var empty: String.UnicodeScalarView {
    return .init()
  }
}

extension Substring.UnicodeScalarView: Identity {

  @inlinable
  public static var empty: Substring.UnicodeScalarView {
    return .init()
  }
}

// MARK: - Conjunctive

/// Boolean monoid under conjunction (&&)
public struct All: Semigroup & Identity {
  @inlinable
  public static var empty: All { return true }

  public let value: Bool

  @usableFromInline
  init(value: Bool) {
    self.value = value
  }

  @_transparent
  public static func ++ (lhs: All, rhs: All) -> All {
    return .init(value: lhs.value && rhs.value)
  }
}

extension All: ExpressibleByBooleanLiteral {
  public typealias BooleanLiteralType = Bool

  @_transparent
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value: value)
  }
}

// MARK: - Disjunctive

/// Boolean monoid under disjunction (||)
public struct `Any`: Semigroup & Identity {
  @inlinable
  public static var empty: `Any` { return false }

  public let value: Bool

  @usableFromInline
  init(value: Bool) {
    self.value = value
  }

  @_transparent
  public static func ++ (lhs: `Any`, rhs: `Any`) -> `Any` {
    return .init(value: lhs.value || rhs.value)
  }
}

extension `Any`: ExpressibleByBooleanLiteral {
  public typealias BooleanLiteralType = Bool

  @_transparent
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value: value)
  }
}

// MARK: - (ℕ|ℝ,+,0)

/// Monoid under addition.
public struct Sum<Numeral: Numeric>: Monoid {
  @inlinable
  public static var empty: Sum { return 0 }

  public let value: Numeral

  @usableFromInline
  init(value: Numeral) {
    self.value = value
  }

  @_transparent
  public static func ++ (lhs: Sum, rhs: Sum) -> Sum {
    return .init(value: lhs.value + rhs.value)
  }
}

extension Sum: ExpressibleByIntegerLiteral where Numeral: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = Numeral.IntegerLiteralType

  @_transparent
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value: .init(integerLiteral: value))
  }
}

extension Sum: ExpressibleByFloatLiteral where Numeral: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Numeral.FloatLiteralType

  @_transparent
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value: .init(floatLiteral: value))
  }
}

// MARK: - (ℤ|ℝ,×,1)

/// Monoid under multiplication
public struct Product<Numeral: Numeric>: Monoid {
  @inlinable
  public static var empty: Product { return 1 }

  public let value: Numeral

  @usableFromInline
  init(value: Numeral) {
    self.value = value
  }

  @_transparent
  public static func ++ (lhs: Product, rhs: Product) -> Product {
    return .init(value: lhs.value * rhs.value)
  }

  @_transparent
  public static func * (lhs: Product, rhs: Product) -> Product {
    return .init(value: lhs.value * rhs.value)
  }
}

extension Product: ExpressibleByIntegerLiteral where Numeral: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = Numeral.IntegerLiteralType

  @_transparent
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value: .init(integerLiteral: value))
  }
}

extension Product: ExpressibleByFloatLiteral where Numeral: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Numeral.FloatLiteralType

  @_transparent
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value: .init(floatLiteral: value))
  }
}

// TODO: {ℤ⁺,𝑚𝑎𝑥,0}/ {ℤ⁺,𝑚𝑖𝑛,?}, ∀, ∃, ×, +

import struct CoreGraphics.CGFloat
import struct QuartzCore.Decimal

// MARK: - ((⊤,⊥),∧,⊤), ((⊤,⊥),∨,⊥) ((⊤,⊥),⊕,⊤)

extension Bool: Identity { }

// MARK: - (ℤ,+,0)

extension Int: Identity { }
extension Int8: Identity { }
extension Int16: Identity { }
extension Int32: Identity { }
extension Int64: Identity { }

// MARK: - (ℕ,+,0)

extension UInt: Identity { }
extension UInt8: Identity { }
extension UInt16: Identity { }
extension UInt32: Identity { }
extension UInt64: Identity { }

// MARK: - (ℝ,+,0)

extension Float: Identity { }
extension Double: Identity { }
extension CGFloat: Identity { }
extension Decimal: Identity { }

#if os(OSX)
extension Float80: Identity { }
#endif
