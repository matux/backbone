import Swift

public protocol Membership {
  associatedtype Element //: Equatable

  /// Returns a Boolean value indicating whether the sequence contains the
  /// given element
  ///
  /// - Parameter element: The element to look for.
  /// - Returns: `true` if the element exists; otherwise, `false`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  func contains(_ member: Element) -> Bool
}

public protocol ContainsWhere {
  associatedtype Element

  /// Returns a Boolean value indicating whether the sequence contains an
  /// element that satisfies the given predicate.
  ///
  /// You can use the predicate to check for an element of a type that
  /// doesn't conform to the `Equatable` protocol, such as the
  /// `HTTPResponse` enumeration in this example.
  ///
  ///     enum HTTPResponse {
  ///         case ok
  ///         case error(Int)
  ///     }
  ///
  ///     let lastThreeResponses: [HTTPResponse] = [.ok, .ok, .error(404)]
  ///     let hadError = lastThreeResponses.contains { element in
  ///         if case .error = element {
  ///             return true
  ///         } else {
  ///             return false
  ///         }
  ///     }
  ///     // 'hadError' == true
  ///
  /// Alternatively, a predicate can be satisfied by a range of `Equatable`
  /// elements or a general condition. This example shows how you can check an
  /// array for an expense greater than $100.
  ///
  ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
  ///     let hasBigPurchase = expenses.contains { $0 > 100 }
  ///     // 'hasBigPurchase' == true
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool
}

extension Membership {

  /// Returns a Boolean value that indicates whether the given element exists
  /// in the set.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: `true` if `member` exists in the set; otherwise, `false`.
  public static func contains(_ member: Element) -> (Self) -> Bool {
    return { $0.contains(member) }
  }
}

extension ContainsWhere {

  /// Returns a Boolean value indicating whether the sequence contains an
  /// element that satisfies the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  public static func contains(
    where predicate: @escaping (Element) -> Bool
  ) -> (Self) -> Bool {
    return { $0.contains(where: predicate) }
  }
}

/// Returns a Boolean value that indicates whether the given element exists
/// in the set.
///
/// - Parameter member: An element to look for in the set.
/// - Returns: `true` if `member` exists in the set; otherwise, `false`.
public func contains<S: Membership>(_ member: S.Element) -> (S) -> Bool {
  return { $0.contains(member) }
}

/// Returns a Boolean value indicating whether the sequence contains an
/// element that satisfies the given predicate.
///
/// - Parameter predicate: A closure that takes an element of the sequence
///   as its argument and returns a Boolean value that indicates whether
///   the passed element represents a match.
/// - Returns: `true` if the sequence contains an element that satisfies
///   `predicate`; otherwise, `false`.
///
/// - Complexity: O(*n*), where *n* is the length of the sequence.
public func contains<S: ContainsWhere>(
  where predicate: @escaping (S.Element) -> Bool
) -> (S) -> Bool {
  return { $0.contains(where: predicate) }
}

// MARK: - Conformances

import struct Foundation.NSRange
extension NSRange: Membership {}

extension Range: Membership {}
extension ClosedRange: Membership {}
extension PartialRangeFrom: Membership {}
extension PartialRangeUpTo: Membership {}
extension PartialRangeThrough: Membership {}
extension StrideThrough: Membership {}
extension StrideTo: Membership {}

extension Slice: Membership where Element: Equatable {}
extension Array: Membership where Element: Equatable {}
extension ContiguousArray: Membership where Element: Equatable {}
extension ArraySlice: Membership where Element: Equatable {}
extension AnyIterator: Membership where Element: Equatable {}
extension AnySequence: Membership where Element: Equatable {}
extension AnyCollection: Membership where Element: Equatable {}
extension AnyBidirectionalCollection: Membership where Element: Equatable {}
extension AnyRandomAccessCollection: Membership where Element: Equatable {}
extension FlattenSequence: Membership where Element: Equatable {}
extension Repeated: Membership where Element: Equatable {}
extension UnfoldSequence: Membership where Element: Equatable {}
extension DefaultIndices: Membership where Element: Equatable {}
extension CollectionOfOne: Membership where Element: Equatable {}
extension EmptyCollection: Membership where Element: Equatable {}
extension ReversedCollection: Membership where Element: Equatable {}
extension LazySequence: Membership where Element: Equatable {}
extension LazyMapSequence: Membership where Element: Equatable {}
extension LazyFilterSequence: Membership where Element: Equatable {}
extension LazyDropWhileSequence: Membership where Element: Equatable {}
extension LazyPrefixWhileSequence: Membership where Element: Equatable {}

extension String: Membership {}
extension Substring: Membership {}

extension Dictionary.Keys: Membership where Element: Equatable {}
extension Dictionary.Values: Membership where Element: Equatable {}

extension UnsafeBufferPointer: Membership where Element: Equatable {}
extension UnsafeMutableRawBufferPointer: Membership {}

extension KeyedDecodingContainer: Membership {}

extension Set: Membership where Element: Equatable {}

import struct Foundation.CharacterSet
import struct Foundation.DateInterval
import struct CoreGraphics.CGRect
import class Foundation.UserDefaults

extension CharacterSet: Membership {}
extension UserDefaults: Membership {}
@available(OSX 10.12, *)
extension DateInterval: Membership {}

extension CGRect: Membership {
  public typealias Element = CGRect
}

// MARK: -

extension Set: ContainsWhere {}
extension Slice: ContainsWhere {}
extension Array: ContainsWhere {}
extension ContiguousArray: ContainsWhere {}
extension ArraySlice: ContainsWhere {}
extension AnyIterator: ContainsWhere {}
extension AnySequence: ContainsWhere {}
extension AnyCollection: ContainsWhere {}
extension AnyBidirectionalCollection: ContainsWhere {}
extension AnyRandomAccessCollection: ContainsWhere {}
extension FlattenSequence: ContainsWhere {}
extension Repeated: ContainsWhere {}
extension UnfoldSequence: ContainsWhere {}
extension DefaultIndices: ContainsWhere {}
extension CollectionOfOne: ContainsWhere {}
extension EmptyCollection: ContainsWhere {}
extension ReversedCollection: ContainsWhere {}
extension LazySequence: ContainsWhere {}
extension LazyMapSequence: ContainsWhere {}
extension LazyFilterSequence: ContainsWhere {}
extension LazyDropWhileSequence: ContainsWhere {}
extension LazyPrefixWhileSequence: ContainsWhere {}
extension Zip2Sequence: ContainsWhere {}
extension EnumeratedSequence: ContainsWhere {}
extension EnumeratedSequence.Iterator: ContainsWhere {}

extension String: ContainsWhere {}
extension Substring: ContainsWhere {}

extension KeyValuePairs: ContainsWhere {}
extension Dictionary: ContainsWhere {}
extension Dictionary.Keys: ContainsWhere {}
extension Dictionary.Values: ContainsWhere {}

extension UnsafeBufferPointer: ContainsWhere {}
extension UnsafeMutableRawBufferPointer: ContainsWhere {}
