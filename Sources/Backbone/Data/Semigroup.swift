import Swift

// https://wiki.haskell.org/Typeclassopedia#Semigroup

///┌──────────────╥─────┬─────┬─────┬─────┬─────╥─────┐
///│ ░▒▓██████▓▒░ ║AA->A│⁽⁾⁼⁽⁾│  ε  │ 𝑥⁻¹ │ˣʸ⁼ʸˣ║  •  │
///├══════════════╬─────┼─────┼─────┼─────┼─────╬─────┤
// │ Semigroupoid ║░░░░░│  ✓  │░░░░░│░░░░░│░░░░░║  •  │
// │     Category ║░░░░░│  ✓  │  ✓  │░░░░░│░░░░░║  ε  │
// │     Groupoid ║░░░░░│  ✓  │  ✓  │  ✓  │░░░░░║ 𝑥⁻¹ │
///│        Magma ║  ✓  │░░░░░│░░░░░│░░░░░│░░░░░║  ·  │
// │   Quasigroup ║  ✓  │░░░░░│░░░░░│  ✓  │░░░░░║  -  │
///│    Semigroup ║  ✓  │  ✓  │░░░░░│░░░░░│░░░░░║  +  │
// │         Loop ║  ✓  │░░░░░│  ✓  │  ✓  │░░░░░║  ÷  │
///│       Monoid ║  ✓  │  ✓  │  ✓  │░░░░░│░░░░░║ + × │
///│        Group ║  ✓  │  ✓  │  ✓  │  ✓  │░░░░░║ 𝑥⁻¹ │
// │Abelian Group ║  ✓  │  ✓  │  ✓  │  ✓  │  ✓  ║ ⊕ ⊗ │
///└──────────────╨─────┴─────┴─────┴─────┴─────╨─────┘
//

/// An algebraic structure (𝑆,⧺) such that 𝑆 is closed under ⧺.
///
/// That is, a magma is a pair (𝑆,⧺) where:
///
///     𝑆
///
/// is a set, and
///
///     ⧺ : 𝑆 × 𝑆 → 𝑆
///
/// is a binary operation on 𝑆.
public typealias Magma = Closure

/// Represents an associative binary operation that "combines" two values of
/// the same type yielding a value of the same type.
///
/// An operation conforming to Semigroup, guarantees that the arguments and the
/// result of the operation will be constrained to the concrete structure it is
/// defined in. As well as a gurantee that multiple operations will always
/// yield the same result no matter the order in which they appear.
///
/// Multiplication, addition, a set intersection or string concatenation are
/// some examples of what constitutes a Semigroup.
///
/// ### Examples:
///
///     𝑥 ⦁ (𝑦 ⦁ 𝑧) <=> (𝑥 ⦁ 𝑦) ⦁ 𝑧
///     1 * (2 * 3) <=> (1 * 2) * 3 // 6
///     "a" + ("b" + "c") <=> ("a" + "b") ≡ "c" // "abc"
///
/// - Note: To make `Semigroups`, simply conform to this protocol and implement
///   `++`. Default implementations are provided for all remainding
///   functionality.
///
/// - Important: Associative is not enforced during compilation.
public typealias Semigroup = Associative & Magma

/// Represents a single binary operation with its arguments and its result type
/// constrained to the concrete structure it is defined in.
///
/// `++` is the only requirement in `Magma`. There is no remainder functionality
/// this protocol guarantees.
public protocol Closure {

  /// An undefined binary operation, type constrained on its arguments and
  /// result to the concrete structure it is defined in.
  ///
  /// Usually denoted by `<>`, or `·`, and pronounced "combine".
  ///
  /// Users conforming to `Magma` or its derivatives are responsible of
  /// defining the concrete operation.
  static func ++ (lhs: Self, rhs: Self) -> Self
}

/// Represents the gurantee that multiple operations will always yield the same
/// result no matter the order in which they appear.
///
/// - Attention: There is no guarantee that multiple operations will always
///   yield the same result no matter the order in which they appear.
///
/// - TODO: Update summary to: _"Represents the hope that multiple operations
///   will always yield the same result no matter the order in which they
///   appear."_
public protocol Associative {

}

// MARK: - Intrinsics

extension Closure where Self: Associative {

  /// Combines this instance with a value of the same type.
  @inlinable
  public mutating func combine(with another: Self) {
    self = self ++ another
  }

  /// Returns a new instance of this type by combining this instance with
  /// another of the same type.
  @inlinable
  public func combined(with another: Self) -> Self {
    return self ++ another
  }

  /// Combines the `Semigroup` on the left-hand side with the `Semigroup` on
  /// the right-hand side in-place.
  @_transparent
  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs ++ rhs
  }
}

// MARK: - Algorithm

extension Closure where Self: Associative {

  /// Returns the result of combining this semigroup with itself.
  ///
  /// - Returns: The semigroup combined with itself.
  @_transparent
  public func doubled() -> Self {
    return self ++ self
  }

  /// Combine this semigroup with itself, effectively doubling its value.
  @_transparent
  public mutating func double() {
    self = doubled()
  }

  /// Returns a pair containing this semigroup and a copy of it.
  ///
  /// - Returns: A pair with the semigroup twice.
  @_transparent
  public func duplicated() -> (Self, Self) {
    return (self, self)
  }

  /// Creates a collection containing the specified number of this semigroup.
  ///
  /// - Parameter count: The number of times to repeat the semigroup.
  /// - Returns: A collection containing the given number of this semigroup.
  @_transparent
  @_specialize(exported: true, kind: partial, where T == Int)
  public func repeated<T: BinaryInteger>(count: T) -> Repeated<Self>? {
    return self * count
  }
}

// MARK: Folds

extension Sequence where Self: Semigroup, Self.Element: Semigroup {

  /// Returns the result of combining the elements of the sequence using the
  /// semigroup binary operation.
  ///
  /// Use `reduce(_:)` to produce a single value from the elements of an
  /// entire sequence. For example, you can use this method on an array of
  /// numbers to find their sum:
  ///
  ///     let sum = [1, 2, 3, 4].reduce(0)
  ///     // sum == 10
  ///
  /// Or append strings:
  ///
  ///     let append = ["Hello, ", "World!"].reduce("")
  ///     // append = "Hello, World!"
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Parameter initialResult: The initial accumulating value.
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func reduce(_ initialResult: Element) -> Element {
    return reduce(initialResult, ++)
  }

  /// Returns the result of combining the elements of the sequence using the
  /// semigroup binary operation.
  ///
  /// Use `reduce(into:)` to produce a single value from the elements of an
  /// entire sequence. For example, you can use this method on an array of
  /// integers to filter adjacent equal entries or count frequencies.
  ///
  /// This method is preferred over `reduce(_:)` for efficiency when `result`
  /// is a cow (copy-on-write) type, for example `Array` or `Dictionary`.
  ///
  ///     let indexedAlphabet = [("a", 1), ("b": 2), ("c": 3), ("d": 4)]
  ///     let alphabetedIndex = indexedAlphabet.reduce(into: [:])
  ///     // alphabetedIndex == ["a": 1, "b": 2, "c": 3, "d": 4]
  ///
  /// If the sequence has no elements, the reduction is never executed and
  /// `initialResult` is the result of the call to `reduce(_:)`.
  ///
  /// - Parameter initialResult: The initial accumulating value.
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func reduce(into result: inout Element) -> Element {
    return reduce(into: result, +=)
  }
}

// MARK: - Abstract witnessing

import struct CoreGraphics.CGFloat
import struct Foundation.Decimal

extension AnyOptional where Self: Semigroup, Self.Wrapped: Semigroup {

  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    switch (lhs.some, rhs.some) {
    case (_, nil):
      return lhs
    case (nil, _):
      return rhs
    case let (a?, b?):
      return .init(a ++ b)
    }
  }
}

extension Numeric where Self: Semigroup {

  /// Adds two values and produces their sum.
  ///
  /// Numerics whose representation don't depend on the instance having a fixed
  /// size are closed under the semigroup operation. (`++`) calculates the sum
  /// of its two arguments. For example:
  ///
  ///     1 <> 2                   // 3
  ///     -10 <> 15                // 5
  ///     -15 <> -5                // -20
  ///     21.5 <> 3.25             // 24.75
  ///
  /// For this Semigroup operation to remain aximoatically consistent, like the
  /// (`+`) operation, it cannot be used with arguments of different. To add
  /// values of different types, convert one of the values to the other value's
  /// type:
  ///
  ///     let x: Int8 = 21
  ///     let y: Int = 1000000
  ///     Int(x) + y              // 1000021
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return lhs + rhs
  }
}

extension FixedWidthInteger where Self: Semigroup {

  /// Returns the sum of the two given values, wrapping the result in case of
  /// any overflow.
  ///
  /// The set of all integer numbers is closed under the semigroup binary
  /// operation satisfying the property of [closure](closure) making it a total
  /// function, in contrast with the standard sum operation (`+`) which is a
  /// partial function due to its overflow behavior. This translates to the
  /// following behavior: any bits that overflow the fixed width of the integer
  /// type will be discarded.
  ///
  /// In the following example, the sum of `100` and `121` is greater than the
  /// maximum representable `Int8` value, so the result is the partial value
  /// after discarding the overflowing bits.
  ///
  ///     let x: Int8 = 10 <> 21
  ///     // x == 31
  ///     let y: Int8 = 100 <> 121
  ///     // y == -35 (after overflow)
  ///
  /// For more about arithmetic with overflow operators, see [Overflow
  /// Operators][overflow] in *[The Swift Programming Language][tspl]*.
  ///
  /// [overflow]: https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID37
  /// [tspl]: https://docs.swift.org/swift-book/
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  /// [closure]: https://en.wikipedia.org/wiki/Closure_(mathematics)
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return lhs &+ rhs
  }
}

// MARK: - CRUD

extension RangeReplaceableCollection where Self: Semigroup {

  /// Returns a new collection by concatenating the elements of the collection
  /// on the left-hand side and the elements of the collection on the right-hand
  /// side.
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return lhs.appending(contentsOf: rhs)
  }

  /// Returns a new collection by appending the element on the right-hand side
  /// to the collection on the left-hand side collection.
  @_transparent
  public static func ++ (xs: Self, x: Element) -> Self {
    return xs.appending(x)
  }

  /// Returns a new collection by prepending the element on the left-hand
  /// side to the collection on the right-hand side.
  @_transparent
  public static func ++ (x: Element, xs: Self) -> Self {
    return xs.prepending(x)
  }

  /// Appends the element on the right-hand side to the collection on the
  /// left-hand side collection in-place.
  @_transparent
  public static func += (xs: inout Self, ys: Self) {
    xs.append(contentsOf: ys)
  }

  /// Appends the element on the right-hand side to the collection on the
  /// left-hand side collection in-place.
  @_transparent
  public static func += (xs: inout Self, x: Element) {
    xs.append(x)
  }
}

extension OptionSet where Self: Semigroup, Element == Self {

  @_transparent
  public static func ++ (xs: Self, x: Self) -> Self {
    return xs |> mutating { $0.insert(x) }
  }
}

extension SetAlgebra where Self: Semigroup {

  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return lhs.union(rhs)
  }

  @_transparent
  public static func ++ (xs: Self, x: Element) -> Self {
    return xs |> mutating { $0.insert(x) }
  }
}

// MARK: - Witnesses

extension Optional: Semigroup where Wrapped: Semigroup { }
extension Result: Semigroup where Success: Semigroup {

  /// Returns the result of combining two `Result` `Successes`.
  ///
  /// Returns the given `Result` instance on the left-hand side combined with
  /// the `Result` instance _iff_ both instances represent `Success`.
  /// Otherwise, returns either the `Failure` from the left-hand side `Result`
  /// or the one from the right-hand side with a left-hand side bias.
  @_transparent
  public static func ++ (lhs: Result, rhs: Result) -> Result {
    switch (lhs, rhs) {
    case let (.success(x), .success(y)):
      return .success(x ++ y)
    case let (.failure(e), _):
      return .failure(e)
    case let (_, .failure(e)):
      return .failure(e)
    }
  }
}

extension Array: Semigroup { }
extension Set: Semigroup { }
extension ContiguousArray: Semigroup { }
extension ArraySlice: Semigroup { }
extension Slice: Semigroup where Base: RangeReplaceableCollection { }

import struct Foundation.Data
extension Data: Semigroup { }

extension Dictionary: Semigroup {

  /// Returns a new `Dictionary` by merging the `Dictionary` on the left hand
  /// side `lhs` with the one on the right `rhs`.
  ///
  /// The new `Dictionary` is the result of a left-biased `union` (`∪`) of two
  /// dictionaries. If `lhs` already contains one or more `Keys` in `rhs`,
  /// the ones in `lhs` are kept and the ones in `rhs` are ignored.
  ///
  /// - Parameters:
  ///   - lhs: A `Dictionary`.
  ///   - rhs: Another `Dictionary`.
  /// - Returns: A new `Dictionary` with the result of the union.
  /// - SeeAlso: Dictionary.merging(_:uniquingKeysWith:)
  @_transparent
  public static func ++ (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
    return lhs ∪ rhs
  }

  @_transparent
  public static func ++ (lhs: Dictionary, rhs: Element) -> Dictionary {
    return lhs.updatingValue(rhs.value, forKey: rhs.key)
  }
}

// Substrings are not a Semigroup because we want to up conv
extension Substring: Semigroup { }

extension Substring {

  @_transparent
  @_effects(readonly)
  @_semantics("string.concat")
  public static func ++ (lhs: Substring, rhs: String) -> String {
    return String(lhs) ++ rhs
  }
}

// TODO: 5.1: Try to get rid of the compiler hints without slowing compilation down to a crawl.
extension String: Semigroup {

  @_transparent
  @_effects(readonly)
  @_semantics("string.concat")
  public static func ++ (lhs: String, rhs: String) -> String {
    mutating(lhs, with: append(contentsOf: rhs))
  }

  @_transparent
  @_effects(readonly)
  @_semantics("string.concat")
  public static func ++ (lhs: String, rhs: StaticString) -> String {
    mutating(lhs, with: append(contentsOf: rhs))
  }

  @_transparent
  @_effects(readonly)
  @_semantics("string.concat")
  public static func ++ (lhs: String, rhs: Substring) -> String {
    mutating(lhs, with: append(contentsOf: rhs))
  }

  @_transparent
  @_effects(readonly)
  @_semantics("string.concat")
  public static func ++ (lhs: String, rhs: Character) -> String {
    mutating(lhs, with: append(rhs))
  }
}

import struct Foundation.URL

extension URL: Semigroup {

  @_transparent
  public static func ++ (base: URL, path: URL) -> URL {
    return URL(string: path.absoluteString, relativeTo: base) ?? base
  }

  @_transparent
  public static func ++ (base: URL, path: String) -> URL {
    return base.appendingPathComponent(path)
  }
}

extension Range: Semigroup
  where Bound: Strideable & Semigroup, Bound.Stride: SignedInteger
{
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return (..<)(Swift.min(lhs.lowerBound, rhs.lowerBound),
                 Swift.max(lhs.upperBound, rhs.upperBound))
  }
}

extension ClosedRange: Semigroup
  where Bound: Strideable & Semigroup, Bound.Stride: SignedInteger
{
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return (...)(Swift.min(lhs.lowerBound, rhs.lowerBound),
                 Swift.max(lhs.upperBound, rhs.upperBound))
  }
}

extension PartialRangeFrom: Semigroup
  where Bound: Strideable & Semigroup, Bound.Stride: SignedInteger
{
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return Swift.min(lhs.lowerBound, rhs.lowerBound)...
  }
}

extension PartialRangeUpTo: Semigroup
  where Bound: Strideable & Semigroup, Bound.Stride: SignedInteger
{
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return ..<Swift.max(lhs.upperBound, rhs.upperBound)
  }
}

extension PartialRangeThrough: Semigroup
  where Bound: Strideable & Semigroup, Bound.Stride: SignedInteger
{
  @_transparent
  public static func ++ (lhs: Self, rhs: Self) -> Self {
    return ...Swift.max(lhs.upperBound, rhs.upperBound)
  }
}

extension Bool: Semigroup {

  @_transparent
  public static func ++ (lhs: Bool, rhs: Bool) -> Bool {
    return lhs || rhs
  }
}

extension Int: Semigroup { }
extension Int8: Semigroup { }
extension Int16: Semigroup { }
extension Int32: Semigroup { }
extension Int64: Semigroup { }

extension UInt: Semigroup { }
extension UInt8: Semigroup { }
extension UInt16: Semigroup { }
extension UInt32: Semigroup { }
extension UInt64: Semigroup { }

extension Float: Semigroup { }
extension Double: Semigroup { }
extension CGFloat: Semigroup { }
extension Decimal: Semigroup { }

#if os(OSX)
extension Float80: Semigroup { }
#endif
