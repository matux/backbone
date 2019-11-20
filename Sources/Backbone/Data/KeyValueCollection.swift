import Swift

extension KeyValuePairs: KeyValueCollection { }
extension Dictionary: HashableKeyValueCollection { }

/// A `Collection` whose elements are mappings from a key to a value.
public protocol KeyValueCollection: ExpressibleByDictionaryLiteral, Collection
  where Element == (key: Key, value: Value)
{
  associatedtype Key
  associatedtype Value
}

/// A `Collection` whose elements are mappings from a hashable key to a value.
public protocol HashableKeyValueCollection: KeyValueCollection
  where Key: Hashable
{
  /// A view of a map's keys.
  associatedtype Keys: Collection where Keys.Element == Key

  /// A view of a dictionary's values.
  associatedtype Values: MutableCollection where Values.Element == Value

  /// The element type of a hashable key-value collection, a pair containing an
  /// individual key-value pair.
  associatedtype Element = (key: Key, value: Value)

  /// Accesses the value associated with the given key for reading and writing.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the map, otherwise returns `nil`.
  subscript(key: Key) -> Value? { get set }

  /// Accesses key-associated values generically by inferring te context in
  /// which the expression exists.
  ///
  /// This *key-based* subscript returns the value for the given key iff the key
  /// is found in the map and and its type matches the context, otherwise
  /// returns `nil`.
  subscript<Inferred>(lookup key: Key) -> Inferred? { get }

  /// A _read-only_ collection containing just the keys of the map.
  ///
  /// When iterated over, keys appear in this collection in the same order as
  /// they occur in the dictionary's key-value pairs. Each key in the keys
  /// collection has a unique value.
  ///
  ///     ["AR": "Argentina", "GH": "Ghana", "JP": "Japan"]
  ///       .keys.forEach(print)
  ///     // Prints "AR", then "JP", and then "GH".
  var keys: Keys { get }

  /// A read-only collection containing just the values of the map.
  ///
  /// When iterated over, values appear in this collection in the same order as
  /// they occur in the map's key-value pairs.
  ///
  ///     ["AR": "Argentina", "GH": "Ghana", "JP": "Japan"]
  ///       .values.forEach(print)
  ///     // Prints "Argentina", then "Ghana", and then "Japan"
  var values: Values { get }


  /// Updates the value stored in the dictionary for the given key, or adds a
  /// new key-value pair if the key does not exist.
  ///
  /// Use this method instead of key-based subscripting when you need to know
  /// whether the new value supplants the value of an existing key. If the
  /// value of an existing key is updated, `updateValue(_:forKey:)` returns
  /// the original value.
  ///
  ///     var hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
  ///
  ///     if let oldValue = hues.updateValue(18, forKey: "Coral") {
  ///         print("The old value of \(oldValue) was replaced with a new one.")
  ///     }
  ///     // Prints "The old value of 16 was replaced with a new one."
  ///
  /// If the given key is not present in the dictionary, this method adds the
  /// key-value pair and returns `nil`.
  ///
  ///     if let oldValue = hues.updateValue(330, forKey: "Cerise") {
  ///         print("The old value of \(oldValue) was replaced with a new one.")
  ///     } else {
  ///         print("No value was found in the dictionary for that key.")
  ///     }
  ///     // Prints "No value was found in the dictionary for that key."
  ///
  /// - Parameters:
  ///   - value: The new value to add to the dictionary.
  ///   - key: The key to associate with `value`. If `key` already exists in
  ///     the dictionary, `value` replaces the existing associated value. If
  ///     `key` isn't already a key of the dictionary, the `(key, value)` pair
  ///     is added.
  /// - Returns: The value that was replaced, or `nil` if a new key-value pair
  ///   was added.
  mutating func updateValue(_ value: __owned Value, forKey key: Key) -> Value?

  /// Merges the key-value pairs in the given sequence into the dictionary,
  /// using a combining closure to determine the value for any duplicate keys.
  ///
  /// Use the `combine` closure to select a value to use in the updated
  /// dictionary, or to combine existing and new values. As the key-value
  /// pairs are merged with the dictionary, the `combine` closure is called
  /// with the current and new values for any duplicate keys that are
  /// encountered.
  ///
  /// This example shows how to choose the current or new values for any
  /// duplicate keys:
  ///
  ///     var dictionary = ["a": 1, "b": 2]
  ///
  ///     // Keeping existing value for key "a":
  ///     dictionary.merge(zip(["a", "c"], [3, 4])) { (current, _) in current }
  ///     // ["b": 2, "a": 1, "c": 4]
  ///
  ///     // Taking the new value for key "a":
  ///     dictionary.merge(zip(["a", "d"], [5, 6])) { (_, new) in new }
  ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
  ///
  /// - Parameters:
  ///   - other:  A sequence of key-value pairs.
  ///   - combine: A closure that takes the current and new values for any
  ///     duplicate keys. The closure returns the desired value for the final
  ///     dictionary.
  mutating func merge<S: Sequence>(
    _ other: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S.Element == (Key, Value)

  /// Merges the given dictionary into this dictionary, using a combining
  /// closure to determine the value for any duplicate keys.
  ///
  /// Use the `combine` closure to select a value to use in the updated
  /// dictionary, or to combine existing and new values. As the key-values
  /// pairs in `other` are merged with this dictionary, the `combine` closure
  /// is called with the current and new values for any duplicate keys that
  /// are encountered.
  ///
  /// This example shows how to choose the current or new values for any
  /// duplicate keys:
  ///
  ///     var dictionary = ["a": 1, "b": 2]
  ///
  ///     // Keeping existing value for key "a":
  ///     dictionary.merge(["a": 3, "c": 4]) { (current, _) in current }
  ///     // ["b": 2, "a": 1, "c": 4]
  ///
  ///     // Taking the new value for key "a":
  ///     dictionary.merge(["a": 5, "d": 6]) { (_, new) in new }
  ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
  ///
  /// - Parameters:
  ///   - other:  A dictionary to merge.
  ///   - combine: A closure that takes the current and new values for any
  ///     duplicate keys. The closure returns the desired value for the final
  ///     dictionary.
  mutating func merge(
    _ other: Self,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows

  /// Creates a dictionary by merging key-value pairs in a sequence into the
  /// dictionary, using a combining closure to determine the value for
  /// duplicate keys.
  ///
  /// Use the `combine` closure to select a value to use in the returned
  /// dictionary, or to combine existing and new values. As the key-value
  /// pairs are merged with the dictionary, the `combine` closure is called
  /// with the current and new values for any duplicate keys that are
  /// encountered.
  ///
  /// This example shows how to choose the current or new values for any
  /// duplicate keys:
  ///
  ///     let dictionary = ["a": 1, "b": 2]
  ///     let newKeyValues = zip(["a", "b"], [3, 4])
  ///
  ///     let keepingCurrent = dictionary.merging(newKeyValues) { (current, _) in current }
  ///     // ["b": 2, "a": 1]
  ///     let replacingCurrent = dictionary.merging(newKeyValues) { (_, new) in new }
  ///     // ["b": 4, "a": 3]
  ///
  /// - Parameters:
  ///   - other:  A sequence of key-value pairs.
  ///   - combine: A closure that takes the current and new values for any
  ///     duplicate keys. The closure returns the desired value for the final
  ///     dictionary.
  /// - Returns: A new dictionary with the combined keys and values of this
  ///   dictionary and `other`.
  func merging<S: Sequence>(
    _ other: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S.Element == (Key, Value)

  /// Creates a dictionary by merging the given dictionary into this
  /// dictionary, using a combining closure to determine the value for
  /// duplicate keys.
  ///
  /// Use the `combine` closure to select a value to use in the returned
  /// dictionary, or to combine existing and new values. As the key-value
  /// pairs in `other` are merged with this dictionary, the `combine` closure
  /// is called with the current and new values for any duplicate keys that
  /// are encountered.
  ///
  /// This example shows how to choose the current or new values for any
  /// duplicate keys:
  ///
  ///     let dictionary = ["a": 1, "b": 2]
  ///     let otherDictionary = ["a": 3, "b": 4]
  ///
  ///     let keepingCurrent = dictionary.merging(otherDictionary)
  ///           { (current, _) in current }
  ///     // ["b": 2, "a": 1]
  ///     let replacingCurrent = dictionary.merging(otherDictionary)
  ///           { (_, new) in new }
  ///     // ["b": 4, "a": 3]
  ///
  /// - Parameters:
  ///   - other:  A dictionary to merge.
  ///   - combine: A closure that takes the current and new values for any
  ///     duplicate keys. The closure returns the desired value for the final
  ///     dictionary.
  /// - Returns: A new dictionary with the combined keys and values of this
  ///   dictionary and `other`.
  func merging(
    _ other: Self,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self
}

/// Returns a lookup function over a given `Hashable` key.
///
/// Returns a function that when applied to a dictionary with keys of type
/// `Key`, it will return the value associated with the given key or `nil` if
/// no value was found.
///
/// - Parameter key: A `Hashable` value.
/// - Returns: A lookup function for `key` taking `Dictionary` values.
public prefix func ^ <D: HashableKeyValueCollection>(
  _ key: D.Key
) -> (D) -> D.Value? {
  return { dict in dict[key] }
}

// MARK: -

/// Default functions for any `HashableKeyValueCollection`.
extension HashableKeyValueCollection {

  /// Returns the key-associated values generically by inferring the context in
  /// which the expression exists.
  ///
  /// This *key-based* subscript returns the value for the given key iff the key
  /// is found in the map and and its type matches the context, otherwise
  /// returns `nil`.
  ///
  /// - Parameter key: The key to lookup.
  /// - Returns: A value of the inferred type or `nil` if either the value was
  ///   not found or the value could not be casted to the expected type.
  @inlinable
  public subscript<Inferred>(lookup key: Key) -> Inferred? {
    return self[key] as? Inferred
  }

  /// Returns a compact array with the values associated with the given keys.
  ///
  /// - Parameter keys: A variadic list of keys to lookup.
  /// - Returns: An array with the values found.
  @inlinable
  public subscript(keys: Key...) -> [Value] {
    return keys.compactMap(get)
  }

  /// Returns the value associated with the given key or raises a runtime
  /// exception if the key is not found.
  ///
  /// Use `require` when you are certain the key exists. For example, when
  /// a dictionary was based off static local data.
  ///
  /// - Parameter key: The key to find in this key-value map.
  /// - Returns: The value associated to the key.
  @inlinable
  public subscript(force key: Key) -> Value {
    return self[key] !! "\(key) was not found in the Dictionary."
  }

  /// Returns a Boolean value indicating whether the `Keys` subcollection of
  /// this key-value collection contains the given element.
  ///
  /// - Parameter key: The key to find in the `Keys` subcollection.
  /// - Returns: `true` if the key was found in the `Keys` subcollection;
  ///   otherwise, false.
  /// - Complexity: O(*n*), where *n* is the length of the `Keys`
  ///   subcollection.
  @inlinable
  public func contains(_ key: Key) -> Bool {
    return keys.contains(key)
  }

  /// Returns a Boolean value indicating whether the `Keys` subcollection of
  /// this key-value collection lacks a key.
  ///
  /// - Parameter key: The key to find in the `Keys` subcollection.
  /// - Returns: `true` if the key was not found in the `Keys` subcollection;
  ///   otherwise, false.
  /// - Complexity: O(*n*), where *n* is the length of the `Keys`
  ///   subcollection.
  @inlinable
  public func lacks(_ key: Key) -> Bool {
    return not(keys.contains(key))
  }

  /// Returns the value associated with the given key.
  ///
  /// Similar to the key-based subscript, this functional variant returns the
  /// value for the given key if the key is found in this key-value map, or
  /// `nil` if the key is not found.
  ///
  /// - Parameter key: The key to find in this key-value map.
  /// - Returns: The value associated to the key, or `nil` if not found.
  @inlinable
  public func get(_ key: Key) -> Value? {
    return self[key]
  }

  /// Sets the value associated with the given key regardless of whether it
  /// already exists, or not.
  ///
  /// A functional variant of the key-based subscript. Overwrites existing
  /// values or adds the key-value pair to the dictionary.
  ///
  /// Passing `.none` for the value, removes its key and, consequently, the
  /// value associated.
  ///
  /// - Parameters:
  ///   - value: A value to associate to the key. Pass `.none` to remove.
  ///   - key: The key to associate the value.
  public mutating func set(_ key: Key, to value: __owned Value?) {
    self[key] = value
  }

  /// Returns a new Dictinoary by setting the value associated with the given
  /// key regardless of whether it already exists, or not.
  ///
  /// Similar to the key-based subscript, this functional variant overwrites
  /// existing values. Otherwise, the key and value are added as a new
  /// key-value pair.
  ///
  /// Passing `nil` as the value for the given key, removes that key and its
  /// associated value.
  ///
  /// - Parameters:
  ///   - value: The value to associate to the key.
  ///   - key: The key to set.
  /// - Returns: A new Dictionary with the new key-value association.
  @_transparent
  public func setting(_ key: Key, to value: __owned Value?) -> Self {
    var dictCopy = self
    dictCopy[key] = value
    return dictCopy
  }

  /// Returns a new Dictinoary by setting the value associated with the given
  /// key regardless of whether it already exists, or not.
  ///
  /// Similar to the key-based subscript, this functional variant overwrites
  /// existing values. Otherwise, the key and value are added as a new
  /// key-value pair.
  ///
  /// Passing `nil` as the value for the given key, removes that key and its
  /// associated value.
  ///
  /// - Parameters:
  ///   - value: The value to associate to the key.
  ///   - key: The key to set.
  /// - Returns: A new Dictionary with the new key-value association.
  @_transparent
  public func updatingValue(_ value: __owned Value, forKey key: Key) -> Self {
    var dictCopy = self
    dictCopy[key] = value
    return dictCopy
  }
}

// MARK: - Map Algebra

extension HashableKeyValueCollection {

  /// Adds the given key-value pair `Element` to this collection.
  ///
  /// Overwrites existing values or adds the key-value pair to the dictionary.
  ///
  /// Passing `.none` for the value, removes its key and, consequently, the
  /// value associated.
  ///
  /// - Parameters:
  ///   - value: A value to associate to the key. Pass `.none` to remove.
  ///   - key: The key to associate the value.
  public mutating func insert(_ element: Element) {
    self[element.key] = element.value
  }

  /// Adds the given key-value pair `Element` to this collection.
  ///
  /// Overwrites existing values or adds the key-value pair to the dictionary.
  ///
  /// Passing `.none` for the value, removes its key and, consequently, the
  /// value associated.
  ///
  /// - Parameters:
  ///   - value: A value to associate to the key. Pass `.none` to remove.
  ///   - key: The key to associate the value.
  public func inserting(_ element: Element) -> Self {
    var map = self
    map.insert(element)
    return map
  }

  /// Returns a new `Dictionary` by merging this `Dictionary` with the one on
  /// the right `rhs`.
  ///
  /// The new `Dictionary` is the result of a left-biased `union` (`∪`) of the
  /// two dictionaries. If this Dictionary instance already contains one or more
  /// `Keys` present in the `other` `Dictionary`, the `other` ones are
  /// discarded.
  ///
  /// - Parameters:
  ///   - other: A `Dictionary` to merge with.
  /// - Returns: A new `Dictionary` with the result of the union.
  /// - SeeAlso: Dictionary.merging(_:uniquingKeysWith:)
  @inlinable
  public __consuming func union(_ other: __owned Self) -> Self {
    return self ∪ other
  }

  /// Merges the given dictionary into this dictionary.
  ///
  /// The new `Dictionary` is the result of a left-biased `union` (`∪`) of the
  /// two dictionaries. If this Dictionary instance already contains one or more
  /// `Keys` present in the `other` `Dictionary`, the `other` ones are
  /// discarded.
  ///
  /// - Parameters:
  ///   - other: A `Dictionary` to merge with.
  /// - SeeAlso: Dictionary.merge(_:uniquingKeysWith:)
  @inlinable
  public mutating func formUnion(_ other: __owned Self) {
    self ∪= other
  }

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
  public static func ∪ (lhs: Self, rhs: Self) -> Self {
    return lhs.merging(rhs, uniquingKeysWith: { x, _ in x })
  }

  /// Merges the given dictionary into this dictionary.
  ///
  /// The new `Dictionary` is the result of a left-biased `union` of two
  /// dictionaries. If `lhs` already contains one or more `Keys` in `rhs`,
  /// the ones in `lhs` are kept and the ones in `rhs` are ignored.
  ///
  /// - Parameters:
  ///   - lhs: A mutable `Dictionary` to merge into.
  ///   - rhs: A `Dictionary` to merge from.
  /// - SeeAlso: Dictionary.merge(_:uniquingKeysWith:)
  @_transparent
  public static func ∪= (lhs: inout Self, rhs: Self) {
    lhs.merge(rhs, uniquingKeysWith: { x, _ in x })
  }
}

// MARK: -
// MARK: - Static thunks

extension HashableKeyValueCollection {

  /// Returns a Boolean value indicating whether the `Keys` subcollection of
  /// this key-value collection contains the given element.
  ///
  /// - Parameter key: The key to find in the `Keys` subcollection.
  /// - Returns: `true` if the key was found in the `Keys` subcollection;
  ///   otherwise, false.
  /// - Complexity: O(*n*), where *n* is the length of the `Keys`
  ///   subcollection.
  @inlinable
  public static func contains(key: Key) -> (Self) -> Bool {
    return { $0.contains(key) }
  }

  /// Returns a Boolean value indicating whether the `Keys` subcollection of
  /// this key-value collection contains the given element.
  ///
  /// - Parameter key: The key to find in the `Keys` subcollection.
  /// - Returns: `true` if the key was found in the `Keys` subcollection;
  ///   otherwise, false.
  /// - Complexity: O(*n*), where *n* is the length of the `Keys`
  ///   subcollection.
  @inlinable
  public static func lacks(key: Key) -> (Self) -> Bool {
    return { $0.lacks(key) }
  }

  /// Returns the value associated with the given key.
  ///
  /// Similar to the key-based subscript, this functional variant returns the
  /// value for the given key if the key is found in this key-value map, or
  /// `nil` if the key is not found.
  ///
  /// - Parameter key: The key to find in this key-value map.
  /// - Returns: The value associated to the key, or `nil` if not found.
  @inlinable
  public static func get(_ key: Key) -> (Self) -> Value? {
    return { $0.get(key) }
  }

  /// Sets the value associated with the given key regardless of whether it
  /// already exists, or not.
  ///
  /// Similar to the key-based subscript, this functional variant overwrites
  /// existing values. Otherwise, the key and value are added as a new
  /// key-value pair.
  ///
  /// Passing `nil` as the value for the given key, removes that key and its
  /// associated value.
  ///
  /// - Parameters:
  ///   - value: The value to associate to the key.
  ///   - key: The key to set.
  @inlinable
  public static func updateValue(
    _ value: Value, forKey key: Key
  ) -> (inout Self) -> () {
    return { $0[key] = value }
  }

  /// Returns a new Dictinoary by setting the value associated with the given
  /// key regardless of whether it already exists, or not.
  ///
  /// Similar to the key-based subscript, this functional variant overwrites
  /// existing values. Otherwise, the key and value are added as a new
  /// key-value pair.
  ///
  /// Passing `nil` as the value for the given key, removes that key and its
  /// associated value.
  ///
  /// - Parameters:
  ///   - value: The value to associate to the key.
  ///   - key: The key to set.
  /// - Returns: A new Dictionary with the new key-value association.
  @_transparent
  public static func updatingValue(
    _ value: Value,
    forKey key: Key
  ) -> (Self) -> Self {
    return { $0.updatingValue(value, forKey: key) }
  }
}
