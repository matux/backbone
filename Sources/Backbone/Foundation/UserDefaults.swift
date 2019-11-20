import struct Swift.String
import struct Foundation.Date
import class  Foundation.UserDefaults

extension UserDefaults {

  /// Returns the object associated with the specified key casted to the
  /// inferred contextual type.
  ///
  /// This method searches the domains included in the search list in the order
  /// in which they are listed and returns the object associated with the first
  /// occurrence of the specified default.
  ///
  /// - Parameter key: A key in the current user‘s defaults database.
  /// - Returns: The object associated with the specified key, or nil if the
  ///   key was not found.
  public subscript<U>(_ key: String) -> U? {
    get { return Type.cast(object(forKey: key)) }
    set {
      newValue.when(
        some: { set($0, for: key) },
        none: { remove(key) })
    }
  }

  /// Returns a Boolean value indicating whether the sequence contains the
  /// given element
  ///
  /// - Parameter element: The element to look for.
  /// - Returns: `true` if the element exists; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  public func contains(_ key: String) -> Bool {
    return object(forKey: key).hasSome
  }
}

extension UserDefaults {

  /// Sets the value of the specified default key on the standard
  /// `UserDefaults` domain.
  ///
  /// The value parameter can only be one of: `Data`, `String`, `Int`, `Float`,
  /// `Double`, `Date`, `URL`, `Bool`, `Array`, or `Dictionary`. For `Array`
  /// and `Dictionary`, their contents must be one of those, also.
  ///
  /// For more information, see [What is a Property List?](what) in the
  /// [Property List Programming Guide](guide).
  ///
  /// Setting a default has no effect on the value returned by the `object(_:)`
  /// function if the same key exists in a domain that precedes the application
  /// domain in the search list.
  ///
  /// - Parameters:
  ///   - value: The object to store in the defaults database.
  ///   - defaultName: The key with which to associate the value.
  ///
  /// [what]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html#//apple_ref/doc/uid/10000048i-CH3-54303
  /// [guide]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048i
  public static func set(_ value: Any?, for key: String) -> () {
    standard.set(value, for: key)
  }

  /// Removes the value of the specified default key from the standard
  /// `UserDefaults` domain.
  ///
  /// Removing a default has no effect on the value returned by the `object(_:)`
  /// function if the same key exists in a domain that precedes the standard
  /// application domain in the search list.
  ///
  /// - Parameters:
  ///   - defaultName: The key whose value you want to remove.
  public static func remove(_ key: String) -> () {
    standard.remove(key)
  }

  /// Returns the object associated with the specified key.
  public static let object = log(standard.object)

  /// Returns the data associated with the specified key.
  public static let data = log(standard.data)

  /// Returns the date associated with the specified key.
  public static let date = log(standard.object) |> Type.as(Date.self)

  /// Returns the url associated with the specified key.
  public static let url = log(standard.url)

  /// Returns the boolean associated with the specified key.
  public static let bool = log(standard.bool)

  /// Returns the integer object associated with the specified key.
  public static let integer = log(standard.integer)

  /// Returns the float associated with the specified key.
  public static let float = log(standard.float)

  /// Returns the double associated with the specified key.
  public static let double = log(standard.double)

  /// Returns the array associated with the specified key.
  public static let array = log(standard.array)

  /// Returns the string associated with the specified key.
  public static let string = log(standard.string)

  /// Returns the array of strings associated with the specified key.
  public static let stringArray = log(standard.stringArray)

  /// Returns the dictionary associated with the specified key.
  public static let dictionary = log(standard.dictionary)
}

extension UserDefaults {

  /// Sets the value of the specified default key on the standard
  /// `UserDefaults` domain.
  ///
  /// The value parameter can only be one of: `Data`, `String`, `Int`, `Float`,
  /// `Double`, `Date`, `URL`, `Bool`, `Array`, or `Dictionary`. For `Array`
  /// and `Dictionary`, their contents must be one of those, also.
  ///
  /// For more information, see [What is a Property List?](what) in the
  /// [Property List Programming Guide](guide).
  ///
  /// Setting a default has no effect on the value returned by the `object(_:)`
  /// function if the same key exists in a domain that precedes the application
  /// domain in the search list.
  ///
  /// - Parameters:
  ///   - value: The object to store in the defaults database.
  ///   - defaultName: The key with which to associate the value.
  ///
  /// [what]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html#//apple_ref/doc/uid/10000048i-CH3-54303
  /// [guide]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048i
  public func set(_ value: Any?, for key: String) -> () {
    print("[\(key)] = \(optional: value)")
    set(value, forKey: key)
  }

  /// Removes the value of the specified default key from the standard
  /// `UserDefaults` domain.
  ///
  /// Removing a default has no effect on the value returned by the `object(_:)`
  /// function if the same key exists in a domain that precedes the standard
  /// application domain in the search list.
  ///
  /// - Parameters:
  ///   - defaultName: The key whose value you want to remove.
  public func remove(_ key: String) -> () {
    print("\(key)")
    removeObject(forKey: key)
  }
}
