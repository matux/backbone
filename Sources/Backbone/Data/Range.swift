import Swift

/// Represents a mathematical object whose absolute value can be measured in
/// terms of the total distance between its bounds.
public protocol Magnitudinal {
  associatedtype Magnitude: Numeric
  associatedtype Length: SignedNumeric

  var magnitude: Magnitude { get }
  var length: Length { get }
}

/// Represents a Range whose absolute value can be derived from the distance
/// between its upper bound and its lower bound.
public protocol MagnitudinalRange: Magnitudinal & RangeExpression
  where Bound == Length, Bound.Magnitude == Magnitude
{
  /// The range's lower bound.
  var lowerBound: Bound { get }

  /// The range's upper bound.
  var upperBound: Bound { get }
}

extension MagnitudinalRange {

  public var magnitude: Bound.Magnitude {
    length.magnitude
  }

  public var length: Bound {
    upperBound - lowerBound
  }
}

extension Range: Magnitudinal, MagnitudinalRange
  where Bound: SignedNumeric {

  public typealias Magnitude = Bound.Magnitude
  public typealias Length = Bound
}

extension ClosedRange: Magnitudinal, MagnitudinalRange
  where Bound: SignedNumeric {

  public typealias Magnitude = Bound.Magnitude
  public typealias Length = Bound
}

extension PartialRangeFrom: Magnitudinal, MagnitudinalRange
  where Bound: FixedWidthInteger & SignedInteger
{
  public typealias Magnitude = Bound.Magnitude
  public typealias Length = Bound

  public var upperBound: Bound {
    .max
  }
}

extension PartialRangeUpTo: Magnitudinal, MagnitudinalRange
  where Bound: FixedWidthInteger & SignedInteger
{
  public var lowerBound: Bound {
    .min
  }

  public typealias Magnitude = Bound.Magnitude
  public typealias Length = Bound
}

extension PartialRangeThrough: Magnitudinal, MagnitudinalRange
  where Bound: FixedWidthInteger & SignedInteger
{
  public typealias Magnitude = Bound.Magnitude
  public typealias Length = Bound

  public var lowerBound: Bound {
    .min
  }
}

//MARK: - Scalar inits

extension Range {

  public init(_ scalar: Bound) {
    self = scalar..<scalar
  }
}

extension ClosedRange {

  public init(_ scalar: Bound) {
    self = scalar...scalar
  }
}

extension PartialRangeFrom {

  public init(_ scalar: Bound) {
    self = scalar...
  }
}

extension PartialRangeUpTo {

  public init(_ scalar: Bound) {
    self = ..<scalar
  }
}

extension PartialRangeThrough {

  public init(_ scalar: Bound) {
    self = ...scalar
  }
}

// MARK: - Case analysis

// Required to disambiguate from Sequence's `~=`

extension Range {

  public static func ~= (range: Self, bound: Bound) -> Bool {
    bound ∈ range
  }
}

extension ClosedRange {

  public static func ~= (range: Self, bound: Bound) -> Bool {
    bound ∈ range
  }
}

extension PartialRangeFrom {

  public static func ~= (range: Self, bound: Bound) -> Bool {
    bound ∈ range
  }
}

extension PartialRangeUpTo {

  public static func ~= (range: Self, bound: Bound) -> Bool {
    bound ∈ range
  }
}

extension PartialRangeThrough {

  public static func ~= (range: Self, bound: Bound) -> Bool {
    bound ∈ range
  }
}

extension Sequence where Element: RangeExpression {

  public static func ~= (ranges: Self, bound: Element.Bound) -> Bool {
    ranges.contains(where: { $0 ~= bound })
  }
}

// MARK: - Clamp

extension Range {

  public func clamp(_ x: Bound) -> Bound {
    Swift.max(lowerBound, Swift.min(x, upperBound))
  }
}

extension ClosedRange {

  public func clamp(_ x: Bound) -> Bound {
    Swift.max(lowerBound, Swift.min(x, upperBound))
  }
}

extension PartialRangeFrom {

  public func clamp(_ x: Bound) -> Bound {
    Swift.max(lowerBound, x)
  }
}

extension PartialRangeUpTo where Bound: Numeric {

  public func clamp(_ x: Bound) -> Bound {
    Swift.min(x, upperBound - .unit)
  }
}

extension PartialRangeThrough {

  public func clamp(_ x: Bound) -> Bound {
    Swift.min(x, upperBound)
  }
}

extension Comparable {

  public func clamped(to r: Range<Self>) -> Self { r.clamp(self) }
  public func clamped(to r: ClosedRange<Self>) -> Self { r.clamp(self) }
  public func clamped(to r: PartialRangeFrom<Self>) -> Self { r.clamp(self) }
  public func clamped(to r: PartialRangeThrough<Self>) -> Self { r.clamp(self) }

  public mutating func clamp(to r: Range<Self>) { self = clamped(to: r) }
  public mutating func clamp(to r: ClosedRange<Self>) { self = clamped(to: r) }
  public mutating func clamp(to r: PartialRangeFrom<Self>) { self = clamped(to: r) }
  public mutating func clamp(to r: PartialRangeThrough<Self>) { self = clamped(to: r) }
}

extension Comparable where Self: Numeric {

  public func clamped(to r: PartialRangeUpTo<Self>) -> Self {
    r.clamp(self)
  }

  public mutating func clamp(to r: PartialRangeUpTo<Self>) {
    self = clamped(to: r)
  }
}

extension Strideable where Self: SignedNumeric & BinaryInteger {

  @inlinable
  public static func clamped(to r: Range<Self>) -> (Self) -> Self {
    clamped >>> with(r)
  }

  @inlinable
  public static func clamp(to r: Range<Self>) -> (inout Self) -> () {
    { $0.clamp(to: r) }
  }

  @inlinable
  public func clamped(to r: Range<Self>) -> Self {
    mutating(self, with: Self.clamp(to: r))
  }

  @inlinable
  public mutating func clamp(to r: Range<Self>) -> () {
    self = clamped(to: r.lowerBound...r.upperBound - min(r.length, 1))
  }
}

// MARK: - Arithmetic

extension Range where Bound: AdditiveArithmetic {

  public static func + (r: Self, x: Bound) -> Self {
    (r.lowerBound + x) ..< (r.upperBound + x)
  }

  public static func - (r: Self, x: Bound) -> Self {
    (r.lowerBound - x) ..< (r.upperBound - x)
  }
}

extension ClosedRange where Bound: AdditiveArithmetic {

  public static func + (r: Self, x: Bound) -> Self {
    (r.lowerBound + x) ... (r.upperBound + x)
  }

  public static func - (r: Self, x: Bound) -> Self {
    (r.lowerBound - x) ... (r.upperBound - x)
  }
}

extension PartialRangeFrom where Bound: AdditiveArithmetic {

  public static func + (r: Self, x: Bound) -> Self {
    (r.lowerBound + x)...
  }

  public static func - (r: Self, x: Bound) -> Self {
    (r.lowerBound - x)...
  }
}

extension PartialRangeUpTo where Bound: AdditiveArithmetic {

  public static func + (r: Self, x: Bound) -> Self {
    ..<(r.upperBound + x)
  }

  public static func - (r: Self, x: Bound) -> Self {
    ..<(r.upperBound - x)
  }
}

extension PartialRangeThrough where Bound: AdditiveArithmetic {

  public static func + (r: Self, x: Bound) -> Self {
    ...(r.upperBound + x)
  }

  public static func - (r: Self, x: Bound) -> Self {
    ...(r.upperBound - x)
  }
}

// MARK: Static thunks

extension Range {

  /// Returns a Boolean value indicating whether the given element is contained
  /// within the range.
  ///
  /// Because `Range` represents a half-open range, a `Range` instance does not
  /// contain its upper bound. `element` is contained in the range if it is
  /// greater than or equal to the lower bound and less than the upper bound.
  ///
  /// - Parameter n: The element to check for containment.
  /// - Returns: `true` if `element` is contained in the range; otherwise,
  ///   `false`.
  public static func contains(_ n: Bound) -> (Self) -> Bool {
    { $0.contains(n) }
  }

  /// A Boolean value indicating whether the range contains no elements.
  ///
  /// An empty `Range` instance has equal lower and upper bounds.
  ///
  ///     let empty: Range = 10..<10
  ///     print(empty.isEmpty)
  ///     // Prints "true"
  @inlinable
  public static func isEmpty(_ range: Self) -> Bool {
    range.isEmpty
  }

  /// Returns a copy of this range clamped to the given limiting range.
  ///
  /// The bounds of the result are always limited to the bounds of `limits`.
  /// For example:
  ///
  ///     let x: Range = 0..<20
  ///     print(x.clamped(to: 10..<1000))
  ///     // Prints "10..<20"
  ///
  /// If the two ranges do not overlap, the result is an empty range within the
  /// bounds of `limits`.
  ///
  ///     let y: Range = 0..<5
  ///     print(y.clamped(to: 10..<1000))
  ///     // Prints "10..<10"
  ///
  /// - Parameter limits: The range to clamp the bounds of this range.
  /// - Returns: A new range clamped to the bounds of `limits`.
  @inlinable
  public static func clamped(to limits: Self) -> (Self) -> Range {
    { $0.clamped(to: limits) }
  }

  /// Returns a Boolean value indicating whether this range and the given range
  /// contain an element in common.
  ///
  /// This example shows two overlapping ranges:
  ///
  ///     let x: Range = 0..<20
  ///     print(x.overlaps(10...1000))
  ///     // Prints "true"
  ///
  /// Because a half-open range does not include its upper bound, the ranges
  /// in the following example do not overlap:
  ///
  ///     let y = 20..<30
  ///     print(x.overlaps(y))
  ///     // Prints "false"
  ///
  /// - Parameter other: A range to check for elements in common.
  /// - Returns: `true` if this range and `other` have at least one element in
  ///   common; otherwise, `false`.
  @inlinable
  public static func overlaps(_ other: Self) -> (Self) -> Bool {
    { $0.overlaps(other) }
  }

  /// Returns a Boolean value indicating whether this range and the given
  /// closed range contain an element in common.
  ///
  /// - Parameter other: A closed range to check for elements in common.
  /// - Returns: `true` if this range and `other` have at least one element in
  ///   common; otherwise, `false`.
  @inlinable
  public static func overlaps(_ other: ClosedRange<Bound>) -> (Self) -> Bool {
    { $0.overlaps(other) }
  }
}
