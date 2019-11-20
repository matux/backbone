import struct Swift.Character
import struct Swift.String

extension Unicode.Scalar: ExpressibleByIntegerLiteral {

  public static let null = 0 as Unicode.Scalar

  /// Creates a new Unicode.Scalar instance from the given 8-bit unsigned
  /// integer literal.
  ///
  /// - Parameter value: An 8-bit unsigned integer literal.
  public init(integerLiteral value: UInt8) {
    self.init(value)
  }
}

/// Character cons by an extended grapheme cluster literal.
prefix operator ¢

extension Character {

  /// The null ASCII character `\0`.
  public static let null = ¢"\0"

  /// The whitespace character ` `.
  public static let whitespace = ¢" "

  /// The newline character `\n`.
  public static let newline = ¢"\n"

  /// The slash character `/`.
  public static let slash = ¢"/"
}

extension Character {

  /// Returns an instance of a Character.
  ///
  /// This is a syntactic sugar for:
  ///
  ///     let char: Character = "c"
  ///     let char = "c" as Character
  ///     let char = "car".first
  ///
  /// - Parameter singleCharacterString: a single-character string literal
  /// - Returns: An instance of Charactr with th given character or literal.
  @_transparent
  public static prefix func ¢ (_ character: Character) -> Character {
    return character
  }
}

extension Character {

  @inlinable
  public var scalar: Unicode.Scalar {
    return unicodeScalars.first ?? 0
  }

  /// A lowercased version of this Character.
  ///
  /// The following example lowercases a character:
  ///
  ///     let c = ¢"C".lowercased()
  ///     // c is "c"
  ///
  /// - Note: The returned value must be a String as case conversion may
  ///   yield multiple characters.
  /// - Returns: A copy of the character uppercased.
  @inlinable
  public var lowercased: String {
    return lowercased()
  }

  /// An uppercased version of the Character.
  ///
  /// The following example uppercases a character:
  ///
  ///     let c = ¢"c".uppercased()
  ///     // Prints "C"
  ///
  /// - Note: The returned value must be a String as case conversion may
  ///   yield multiple characters.
  /// - Returns: A copy of the character uppercased.
  @inlinable
  public var uppercased: String {
    return uppercased()
  }
}

// MARK: - Thunks

extension Character {

  /// Returns the first Unicode scalar of the given Character.
  @inlinable
  public static func scalar(of c: Character) -> Unicode.Scalar {
    return c.scalar
  }

  @_transparent
  public static func lowercased(_ c: Character) -> String {
    return c.lowercased()
  }

  @_transparent
  public static func uppercased(_ c: Character) -> String {
    return c.uppercased()
  }

  @_transparent
  public static func scalar(_ character: Character) -> Unicode.Scalar {
    return character.scalar
  }

}
