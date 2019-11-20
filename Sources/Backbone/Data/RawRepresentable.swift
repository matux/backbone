import Swift

extension RawRepresentable {

  /// Returns the raw value represented by this instance.
  ///
  /// Prefix `RawRepresentable` values with (`*`) to access its raw value
  /// instead of invoking the literal variable `rawValue`.
  ///
  /// ## Rationale
  ///
  /// The primary, and arguably only, purpose of `RawRepresentable.rawValue`
  /// is to serve as plumbing. It's a syntactic facility with little to no
  /// semantic value. In other words, it's not the "meat" of your program.
  ///
  /// Therefore, a valid case can be presented for deemphasizing this operation.
  ///
  /// Functions that serve as plumbing make up the structure, not the
  /// **content** of an expression.
  ///
  /// _They're the code equivalent of_ **prepositions** _and_ **punctuation**
  /// **marks**.
  ///
  /// Operators are useful for this sort of plumbing because they make it easy
  /// to concentrate on the **content** of an expression while also breaking it
  /// into parts. I think of them as visual bookmarks. With a bit of experience,
  /// plumbing operators make code easier to read at a glance—a universally
  /// useful property.
  ///
  /// ## Term of art
  ///
  /// The prefix asterisk is known in the C-family of languages as the
  /// indirection (or dereference) operator and it's purpose is to allow
  /// users to operate on the raw value (l-value) that a reference (r-value)
  /// points to by returning the l-value itself.
  ///
  /// `RawRepresentable` is a reference type. In computer science, a reference
  /// is a value that enables a program to indirectly access a particular datum,
  /// such as a variable's value or a record, in the computer's memory or in
  /// some other storage device.
  ///
  /// The reference is said to refer to the datum, and accessing the datum is
  /// called dereferencing the reference.
  ///
  /// - Parameter rep: The instance representing the value.
  /// - Returns: The raw value this instance represents.
  @_transparent
  public static prefix func * (_ rep: Self) -> RawValue {
    return rep.rawValue
  }
}

/// This default implementation of `Comparable` allows for automatic synthesis
/// of `Comparable` conforming types.
extension RawRepresentable where Self: Comparable, RawValue: Comparable {

  /// Returns a `Boolean` value indicating whether the value of the first
  /// argument is **less than** that of the second argument.
  ///
  /// This function is the only requirement of the `Comparable` protocol. The
  /// remainder of the relational operator functions are implemented by the
  /// standard library for any type that conforms to `Comparable`.
  ///
  /// - Parameters
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  /// - Returns: Whether `lhs` is **less than** `rhs`.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return *lhs < *rhs
  }
}

extension RawRepresentable
  where Self: CustomStringConvertible, RawValue: CustomStringConvertible
{
  public var debugDescription: String {
    return rawValue.description
  }
}

extension RawRepresentable
  where Self: CustomDebugStringConvertible, RawValue: CustomDebugStringConvertible
{
  public var debugDescription: String {
    return rawValue.debugDescription
  }
}

extension RawRepresentable
  where Self: CustomReflectable, RawValue: CustomReflectable
{
  public var customMirror: Mirror {
    return rawValue.customMirror
  }
}

extension RawRepresentable
  where Self: ExpressibleByStringValue, RawValue: ExpressibleByStringValue
{
  public init?(_ description: String) {
    guard let rawValue = RawValue(description) else { return nil }
    self.init(rawValue: rawValue)
  }
}

