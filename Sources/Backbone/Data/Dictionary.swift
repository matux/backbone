import Foundation

/// `HDictionary` is a heterogenous hash map of key-values type-erased on its
/// value type. Each value has a unique map to a distinct polymorphic key with
/// a hash.
///
/// - SeeAlso:
///   https://www.vocabulary.com/dictionary/heterogenous
public typealias HDictionary<Key: Hashable> = [Key: Any]

/// A pure heterogenous hash map from type-erased hashable keys to type-erased
/// values.
public typealias AnyDictionary = HDictionary<AnyHashable>

/// A collection able to represent data consisting of maps from keys of type
/// `String` to heterogenous values `Any`.
public typealias JSON = HDictionary<String>

/// A type-level validation of an instance of `JSON` that is guaranteed to be
/// sound, and closed under serialization, that is to say, its serialization is
/// guaranteed to succeed.
public typealias SerializableJSON = Newtype<JSON, ⁺ˢJSON> ; public enum ⁺ˢJSON {}

extension JSON {

  /// Validates this JSON instance returning a `SerializableJSON` if valid or
  /// `nil` if not.
  ///
  /// A `SerializableJSON` guarantees the success of a serializing operation
  /// under normal circumstances eliminating the need for error handling at the
  /// point of use.
  var validated: SerializableJSON? {
    return JSONSerialization.isValidJSONObject(self) ? .init(self) : .none
  }
}

extension SerializableJSON {

  /// Returns the serialized Data of the given validated JSON.
  ///
  /// - Parameter json: A `Validated<JSON>` object to serialize.
  /// - Returns: The serialized Data.
  public static func serialize(
    _ json: SerializableJSON
  ) -> Data {
    return json.serialized
  }

  /// Returns the serialized Data of this validated json.
  ///
  /// - Returns: The serialized Data.
  public var serialized: Data {
    return try! JSONSerialization
      .data(withJSONObject: *self)
  }
}

extension Dictionary where Key: Hashable, Value == Any {

  public init(
    from type: Bundle.ResourceFormat,
    named name: String,
    in bundle: Bundle = .main
  ) {
    self = bundle
      .path(for: type, named: name)
      .flatMap(NSDictionary.init)
      .map(Type.bridge)!
      .compactMapKeys(T.cast)
  }
}

// MARK: - Algorithm

extension Dictionary {

  /// Returns a new dictionary containing the keys of this dictionary with the
  /// values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value. `transform`
  ///   accepts each value of the dictionary as its parameter and returns a
  ///   transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public func mapKeys<TransformedKey>(
    _ transform: (Key) -> TransformedKey
  ) -> [TransformedKey: Value] {
    return reduce { $0[transform($1.key)] = $1.value }
  }

  /// Returns a new dictionary containing the keys and values of this
  /// dictionary transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a `Dictionary` value of
  ///   `Element` type, defined as `(key: Key, value: Value)`.
  /// - Returns: A dictionary containing the transformed elements of this
  ///   dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public func mapElements<Key´, Value´>(
    _ transform: (Element) -> (key: Key´, value: Value´)
  ) -> [Key´: Value´] {
    return reduce { $0.insert(transform($1)) }
  }

  /// Returns a new dictionary containing the keys and values of this
  /// dictionary transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a `Dictionary` value of
  ///   `Element` type, defined as `(key: Key, value: Value)`.
  /// - Returns: A dictionary containing the transformed elements of this
  ///   dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public func bimap<Keyʹ, Valueʹ>(
    _ transform₀: (Key) -> Keyʹ,
    _ transform₁: (Value) -> Valueʹ
  ) -> [Keyʹ: Valueʹ] { 
    return reduce { dict, kv in dict[transform₀(kv.key)] = transform₁(kv.value) }
  }

  /// Returns a new dictionary containing the elements of this dictionary
  /// with the non-nil keys and values transformed by the given closure.
  ///
  /// - Parameters:
  ///   - transform₀: A closure that transforms a value. `transform₀` accepts
  ///     each key of the dictionary as its parameter and returns a transformed
  ///     key of the same or of a different type.
  ///   - transform₁: A closure that transforms a value. `transform₁` accepts
  ///     each value of the dictionary as its parameter and returns a
  ///     transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public func compactBimap<TransformedKey, TransformedValue>(
    _ transform₀: (Key) -> TransformedKey?,
    _ transform₁: (Value) -> TransformedValue?
  ) -> [TransformedKey: TransformedValue] {
    return reduce { dict, kv in
      zip(transform₀(kv.key), transform₁(kv.value)) { dict[$0] = $1 }
    }
  }

  /// Returns a new dictionary containing the keys of this dictionary with the
  /// non-nil values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value. `transform`
  ///   accepts each value of the dictionary as its parameter and returns a
  ///   transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public func compactMapKeys<TransformedKey>(
    _ transform: (Key) -> TransformedKey?
  ) -> [TransformedKey: Value] {
    return reduce { result, pair in
      transform(pair.key).when(some: { result[$0] = pair.value })
    }
  }

  /// Returns a new Dictionary with the non-nil values from this Dictionary.
  @inlinable
  public func compact() -> [Key: Value] {
    return compactMapValues(id)
  }

  /// Returns a new dictionary containing the key-value pairs of the
  /// dictionary whose keys satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes a key as its argument and
  ///   returns a Boolean value indicating whether the pair should be included
  ///   in the returned dictionary.
  /// - Returns: A dictionary of the key-value pairs that `isIncluded` allows.
  @inlinable
  public func filterByKey(
    where isIncluded: (Key) -> Bool
  ) -> [Key: Value] {
    var result = Dictionary()
    for element in self where isIncluded(element.key) {
      result[element.key] = element.value
    }

    return result
  }
}

extension Dictionary where Value: AnyOptional {

  /// Returns a new Dictionary with the non-nil elements of the Dictionary.
  @inlinable
  public func compact() -> [Key: Value.Wrapped] {
    return compactMapValues(^\.some)
  }
}

extension Dictionary {

  private func describe(_ x: Any) -> String {
    switch x {
    case let x as Dictionary: return x.description
    case let x as Array<Any>: return x.description
    case let x as Set<AnyHashable>: return x.description
    case let x as CustomStringConvertible: return x.description
    case let x: return "\(x, trunc: 64)"
    }
  }

  public var description: String {
    return { "\(type(of: self)) = [\n\($0)\t\t\t]" }(reduce {
      $0 += "\t\t\t\t\($1.0): \(describe($1.1))\n"
    })
  }

  public var debugDescription: String {
    return description
  }
}

// MARK: - Static thunks

extension Dictionary {

  /// Returns a new dictionary containing the values of this dictionary with
  /// the keys transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a key. `transform`
  ///   accepts each key of the dictionary as its parameter and returns a
  ///   transformed key of the same or of a different type.
  /// - Returns: A dictionary containing the values and transformed keys of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public static func mapKeys<TransformedKey>(
    _ transform: @escaping (Key) -> TransformedKey
  ) -> (Self) -> [TransformedKey: Value] {
    return { $0.mapKeys(transform) }
  }

  /// Returns a new dictionary containing the keys of this dictionary with the
  /// values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value. `transform`
  ///   accepts each value of the dictionary as its parameter and returns a
  ///   transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public static func mapValues<TransformedValue>(
    _ transform: @escaping (Value) -> TransformedValue
  ) -> (Self) -> [Key: TransformedValue] {
    return { $0.mapValues(transform) }
  }

  /// Returns a new dictionary containing the keys of this dictionary with the
  /// values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value. `transform`
  ///   accepts each value of the dictionary as its parameter and returns a
  ///   transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public static func mapElements<Keyʹ, Valueʹ>(
    _ transform: @escaping (Element) -> (key: Keyʹ, value: Valueʹ)
  ) -> (Self) -> [Keyʹ: Valueʹ] {
    return { $0.mapElements(transform) }
  }

  /// Returns a new dictionary containing the keys and values of this
  /// dictionary transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a `Dictionary` value of
  ///   `Element` type, defined as `(key: Key, value: Value)`.
  /// - Returns: A dictionary containing the transformed elements of this
  ///   dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public static func bimap<Keyʹ, Valueʹ>(
    _ transformKey: @escaping (Key) -> Keyʹ,
    _ transformValue: @escaping (Value) -> Valueʹ
  ) -> (Self) -> [Keyʹ: Valueʹ] {
    return { $0.bimap(transformKey, transformValue) }
  }

  /// Returns a new dictionary containing the keys of this dictionary with the
  /// non-nil values transformed by the given closure.
  ///
  /// - Parameter transform: A closure that transforms a value. `transform`
  ///   accepts each value of the dictionary as its parameter and returns a
  ///   transformed value of the same or of a different type.
  /// - Returns: A dictionary containing the keys and transformed values of
  ///   this dictionary.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the dictionary.
  @inlinable
  public static func compactMapKeys<TransformedKey>(
    _ transform: @escaping (Key) -> TransformedKey?
  ) -> (Self) -> [TransformedKey: Value] {
    return { $0.compactMapKeys(transform) }
  }

  /// Returns a new Dictionary with the non-nil values from this Dictionary.
  @inlinable
  public static func compact(_ dictionary: Self) -> [Key: Value] {
    return dictionary.compactMapValues(id)
  }

  /// Returns a new dictionary containing the key-value pairs of the
  /// dictionary whose keys satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes a key as its argument and
  ///   returns a Boolean value indicating whether the pair should be included
  ///   in the returned dictionary.
  /// - Returns: A dictionary of the key-value pairs that `isIncluded` allows.
  @inlinable
  public static func filterByKey(
    where isIncluded: @escaping (Key) -> Bool
  ) -> (Self) ->  [Key: Value] {
    return { $0.filterByKey(where: isIncluded) }
  }
}

extension Dictionary where Value: AnyOptional {

  /// Returns a new Dictionary with the non-nil elements of the Dictionary.
  @inlinable
  public static func compact(_ dictionary: Self) -> [Key: Value.Wrapped] {
    return dictionary.compact()
  }
}

extension JSON {

  static func validated(_ json: JSON) -> SerializableJSON? {
    return json.validated
  }
}

// MARK: - Free thunks

/// Returns a new dictionary containing the keys of this dictionary with the
/// values transformed by the given closure.
///
/// - Parameter transform: A closure that transforms a value. `transform`
///   accepts each value of the dictionary as its parameter and returns a
///   transformed value of the same or of a different type.
/// - Returns: A dictionary containing the keys and transformed values of
///   this dictionary.
///
/// - Complexity: O(*n*), where *n* is the length of the dictionary.
@inlinable
public func mapKeys<Key, Value, TransformedKey>(
  _ transform: @escaping (Key) -> TransformedKey
) -> ([Key: Value]) -> [TransformedKey: Value] {
  return { $0.reduce { $0[transform($1.key)] = $1.value } }
}

/// Returns a new dictionary containing the keys and values of this
/// dictionary transformed by the given closure.
///
/// - Parameter transform: A closure that transforms a `Dictionary` value of
///   `Element` type, defined as `(key: Key, value: Value)`.
/// - Returns: A dictionary containing the transformed elements of this
///   dictionary.
///
/// - Complexity: O(*n*), where *n* is the length of the dictionary.
@inlinable
public func mapElements<Key, Keyʹ, Value, Valueʹ>(
  _ transform: @escaping (Key, Value) -> (key: Keyʹ, value: Valueʹ)
) -> ([Key: Value]) -> [Keyʹ: Valueʹ] {
  return { $0.reduce { dict, kv in transform(kv.0, kv.1) => { dict[$0] = $1 } } }
}

/// Returns a new Dictionary with the non-nil values from this Dictionary.
@inlinable
public func compact<Key, Value>(_ dict: [Key: Value]) -> [Key: Value] {
  return dict.compactMapValues(id)
}

/// Returns a new dictionary containing the key-value pairs of the
/// dictionary whose keys satisfy the given predicate.
///
/// - Parameter isIncluded: A closure that takes a key as its argument and
///   returns a Boolean value indicating whether the pair should be included
///   in the returned dictionary.
/// - Returns: A dictionary of the key-value pairs that `isIncluded` allows.
@inlinable
public func filterByKey<Key, Value>(
  where isIncluded: @escaping (Key) -> Bool
) -> ([Key: Value]) -> [Key: Value] {
  return Dictionary.filterByKey(where: isIncluded)
}

/// Returns a new dictionary containing the keys of this dictionary with the
/// non-nil values transformed by the given closure.
///
/// - Parameter transform: A closure that transforms a value. `transform`
///   accepts each value of the dictionary as its parameter and returns a
///   transformed value of the same or of a different type.
/// - Returns: A dictionary containing the keys and transformed values of
///   this dictionary.
///
/// - Complexity: O(*n*), where *n* is the length of the dictionary.
@inlinable
public func compactMapKeys<Key, Keyʼ, Value>(
  _ transform: @escaping (Key) -> Keyʼ?
) -> ([Key: Value]) -> [Keyʼ: Value] {
  return Dictionary.compactMapKeys(transform)
}

/// Returns a new dictionary containing the keys and values of this
/// dictionary transformed by the given closure.
///
/// - Parameter transform: A closure that transforms a `Dictionary` value of
///   `Element` type, defined as `(key: Key, value: Value)`.
/// - Returns: A dictionary containing the transformed elements of this
///   dictionary.
///
/// - Complexity: O(*n*), where *n* is the length of the dictionary.
@inlinable
public func bimap<Key, Value, Keyʹ, Valueʹ>(
  keys transformKey: @escaping (Key) -> Keyʹ,
  values transformValue: @escaping (Value) -> Valueʹ
) -> ([Key: Value]) -> [Keyʹ: Valueʹ] {
  return Dictionary.bimap(transformKey, transformValue)
}
