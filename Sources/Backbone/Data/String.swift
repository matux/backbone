import struct Foundation.CharacterSet
import struct Foundation.Data
import class Foundation.NSString
import Swift

// MARK: - Error

#if DEBUG
/// Usage: `throw "Something went wrong"`
extension String: Error { }
#endif

// MARK: - Character

extension Character {

  /// Repeats the given string on the left-hand side the amount of times given
  /// on the right-hand side integer.
  ///
  /// - Requires: `times` must be >= 0.
  /// - Parameters:
  ///   - generate: Nullary function that will generate an element on each
  ///     consecutive application of it.
  ///   - times: The amount of elements to generate.
  /// - Returns: A collection with the elements generated by `generate`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @_transparent
  public static func * (character: Character, many: Int) -> String {
    many.repeats(of: character)?.reduce(++) ?? ""
  }
}

extension String {
  public static let whitespace = " "
  public static let newline = "\n"
  public static let slash = "/"
  public static let period = "."
}

/// A type that can be initialized with a string value.
///
/// Types conforming to `ExpressibleByStringValue` can be initialized with a
/// variable or constant of type `String`.
///
///     let number = Int("42")
///     // number is 42
///
/// # Conforming to ExpressibleByStringValue
///
/// To add `ExpressibleByStringValue` conformance to a custom type, implement
/// the required initializer.
public protocol ExpressibleByStringValue {

  /// - Parameter description: The String representation of a value.
  init?(_ description: String)
}

extension String: ExpressibleByStringValue { }
extension Substring: ExpressibleByStringValue { }
extension Unicode.Scalar: ExpressibleByStringValue { }
extension Character: ExpressibleByStringValue { }
extension Bool: ExpressibleByStringValue { }
extension Int: ExpressibleByStringValue { }
extension UInt: ExpressibleByStringValue { }
extension Float: ExpressibleByStringValue { }
extension Double: ExpressibleByStringValue { }
extension AnyHashable: ExpressibleByStringValue { }
extension AnyIndex: ExpressibleByStringValue { }

public protocol FormattedStringConvertible {

  var formattedDescription: String { get }
}

extension FormattedStringConvertible {

  public func formattedDescription(of x: Any) -> String {
    return (x as? Self)?.formattedDescription ?? "\(x, trunc: 120)"
  }

  public func formattedDescription<Key, Value>(of kv: (Key, Value)) -> String {
    return "\(kv.0): \(formattedDescription(of: kv.1))"
  }
}

extension Collection where Self: FormattedStringConvertible {

  public var formattedDescription: String {
    return { "\t  \(type(of: self)) = [\n\($0)\t  ]" }(reduce(into: "") {
      $0 += "\t    \(formattedDescription(of: $1))\n"
    })
  }
}

extension KeyValueCollection where Self: FormattedStringConvertible {

  public var formattedDescription: String {
    return { "\t  \(type(of: self)) = [\n\($0)\t  ]" }(reduce(into: "") {
      $0 += "\t    \(formattedDescription(of: $1))\n"
    })
  }
}

extension Set: FormattedStringConvertible { }
extension Array: FormattedStringConvertible { }
extension KeyValuePairs: FormattedStringConvertible { }
extension Dictionary: FormattedStringConvertible { }

/// StaticString cons
prefix operator §

extension StaticString {

  /// Returns the underlying String the underlying
  @_transparent
  public static prefix func * (_ string: StaticString) -> String {
    // return self.withUTF8Buffer { String._uncheckedFromUTF8($0) }
    return .init(describing: string)
  }

  /// Returns an instance of a StaticString.
  ///
  /// This is a syntactic sugar for:
  ///
  ///     let char: StaticString = "A static string."
  ///     let char = "A static string." as StaticString
  ///
  /// Which can now be expressed as:
  ///
  ///     let string = §"A static string."
  ///
  /// - Parameter string: A string literal
  /// - Returns: An instance of StaticString with the given string literal.
  @_transparent
  public static prefix func § (_ string: StaticString) -> StaticString {
    return string
  }
}

extension StaticString: Equatable {

  public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
    return *lhs == *rhs
  }
}

extension StaticString: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine("\(self)")
  }
}

extension String {

  /// Creates a new String with the given static string.
  ///
  /// - Parameter staticString: The static string.
  public init(_ staticString: StaticString) {
    self = "\(staticString)"
  }
}

// MARK: - Data

extension String {

  /// Creates a new String by decoding the given utf8-encoded Data.
  ///
  /// - Requires: Data must be `utf8` encoded.
  /// - Parameter data: The utf8-encoded Data.
  public init?(_ data: Data) {
    guard let string = String(data: data, encoding: .utf8) else { return nil }
    self = string
  }

  /// Returns a new string made from the receiver by replacing all characters
  /// not in the `urlPathAllowed` `CharacterSet` set, or `nil` if the
  /// transformation is not possible.
  public var urlEncoded: String? {
    return urlEncoded(excluding: .urlHostAllowed)
  }

  /// Returns a new string made from the receiver by replacing all characters
  /// not in the specified set with percent-encoded characters.
  ///
  /// - Parameter characters: The characters not replaced in the string.
  ///   Typically, you specify one of the predefined character sets for a
  ///   particular `URL` component, such as `urlPathAllowed` or
  ///   `urlQueryAllowed`.
  /// - Returns: Returns the encoded string, or `nil` if the transformation is
  ///   not possible.
  public func urlEncoded(excluding characters: CharacterSet) -> String? {
    return addingPercentEncoding(withAllowedCharacters: characters)
  }
}

extension String {

  public subscript(_ range: Range<Int>) -> Substring? {
    guard range.lowerBound >= .zero else { return .none }
    let (start, end) = (startIndex, endIndex)
    let index = { self.index(start, offsetBy: $0, limitedBy: end) }
    return zip(index(range.lowerBound), index(range.upperBound)).map {
      self[$0.0 ..< $0.1]
    }
  }

  public subscript(_ range: ClosedRange<Int>) -> Substring? {
    return self[range.lowerBound..<range.upperBound.advanced(by: .unit)]
  }

  public subscript(_ range: PartialRangeFrom<Int>) -> Substring {
    return index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex)
      .map { self[$0...] } ?? self[...]
  }

  public subscript(_ range: PartialRangeUpTo<Int>) -> Substring {
    return index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
      .map { self[..<$0] } ?? self[...]
  }

  public subscript(_ range: PartialRangeThrough<Int>) -> Substring {
    return self[.zero ..< range.upperBound.advanced(by: .unit)] ?? self[...]
  }

  // TODO: RangeExpression to eliminate overloads
//  public subscript<R: RangeExpression>(
//    _ range: R
//  ) -> Substring? where R.Bound == Int {
//    let relativeRange = range.relative(to: self)
//    let lowerIndex = index(startIndex, offsetBy: relativeRange)
//    let upperIndex = index(lowerIndex, offsetBy: range.length)
//    return index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
//        .fmap self[...$0] } ?? .init(self)
//    }
//  }
}

// MARK: - Algorithm

import struct Foundation.Locale
import struct CoreFoundation.CFIndex
import class CoreFoundation.CFLocale
import func CoreFoundation.CFStringIsHyphenationAvailableForLocale
import func CoreFoundation.CFStringGetHyphenationLocationBeforeIndex

extension CFLocale {

  /// A locale representing the user's region settings at the time the property
  /// is read.
  @inlinable
  public static var current: CFLocale {
    Locale.current as CFLocale
  }
}

extension StringProtocol {

  // FIXME: complexity is wrong
  /// Repeats the given string on the left-hand side the amount of times given
  /// on the right-hand side integer.
  ///
  /// - Requires: `times` must be >= 0.
  /// - Parameters:
  ///   - generate: Nullary function that will generate an element on each
  ///     consecutive application of it.
  ///   - times: The amount of elements to generate.
  /// - Returns: A collection with the elements generated by `generate`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @_transparent
  public static func * (string: Self, times: Int) -> String {
    return (string * times)?.joined() ?? ""
  }

  /// A copy of the string with each word changed to its corresponding
  /// capitalized spelling.
  ///
  /// This property performs the canonical (non-localized) mapping. It is
  /// suitable for programming operations that require stable results not
  /// depending on the current locale.
  ///
  /// A capitalized string is a string with the first character in each word
  /// changed to its corresponding uppercase value, and all remaining
  /// characters set to their corresponding lowercase values. A "word" is any
  /// sequence of characters delimited by spaces, tabs, or line terminators.
  /// Some common word delimiting punctuation isn't considered, so this
  /// property may not generally produce the desired results for multiword
  /// strings. See the `getLineStart(_:end:contentsEnd:for:)` method for
  /// additional information.
  ///
  /// Case transformations aren’t guaranteed to be symmetrical or to produce
  /// strings of the same lengths as the originals.
  @inlinable
  public static func capitalized(_ string: Self) -> String {
    return string.capitalized
  }

  /// Returns a Boolean value that indicates whether hyphenation data is
  /// available for the language's hyphenation conventions of the current
  /// locale.
  public var isHyphenationAvailable: Bool {
    return CFStringIsHyphenationAvailableForLocale(.current)
  }

  /// Returns the first potential hyphenation location found for this string
  /// before the specified location following the language hyphenation
  /// conventions of the current locale.
  ///
  /// - Parameter index: An `index` in the string. If a valid hyphen index is
  ///   returned, it will be before this `index`.
  /// - Returns: The first potential hyphenation location.
  @inlinable
  public func hyphenationIndex(before index: CFIndex) -> CFIndex {
    return CFStringGetHyphenationLocationBeforeIndex(
      cf, index, CFRangeMake(.zero, utf16.count), 0, .current, .none)
  }
}

extension StringProtocol where Self: RangeReplaceableCollection {

  public var hyphenated: Self {
    guard isHyphenationAvailable else { return self }

    var string = self
    var indices = [CFIndex]()
    let insert = { x in { ι in string.insert(x, at: ι) } }
    let appendIndex = { ι in indices.append(ι) }
    let asUTF16Index = flip(curry(Index.init))(self)

    utf16.enumerated().forEach(Tuple.fst
      >>> string.hyphenationIndex
      >>> when(not • equals(indices.last), appendIndex))

    indices.reversed()
      .filter(greaterThan(.zero))
      .map(asUTF16Index)
      .forEach(insert("\u{00AD}"))

    return string
  }
}

extension String {

  public func padded(width column: Int, with pad: Element = " ") -> String {
    self ++ (pad * (column - count))
  }

  public func leftPadded(width column: Int, with pad: Element = " ") -> String {
    (pad * (column - count)) ++ self
  }

  /// Returns a random string with the given length.
  ///
  /// - Parameter length: Amount of characters in the random string.
  /// - Returns: A randomized string of `length` characters.
  /// - Complexity: O(*n*) where *n* is the amount of characters in the string.
  public static func random(_ length: Int) -> String {
    let xs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let scalarRange = 0 ..< xs.unicodeScalars.count

    return length.iterations { Int.random(in: scalarRange) }!
      .compactMap(xs.index >=> xs.at)
      .reduce(.empty, ++)
  }

  /// Return an Index offset by the given amount, clamped to the bounds of
  /// this collection, returning `nil` in case the offset produces an index
  /// out of bounds.
  ///
  /// - Parameter offset: An amount, positive or negative, to offset the index.
  /// - Returns: The offsetted index or `nil` if out of bounds.
  public func index(offset: Int) -> Index? {
    return index(startIndex, offsetBy: offset, limitedBy: endIndex)
  }

  /// Returns an index generating function that will safely return an index
  /// offsetted by a given integer value clamped to the initial range or will
  /// return `nil` in case the offset produces an index out of bounds.
  ///
  /// - Parameter r: A range to clamp the indices generated.
  /// - Returns: A function that will produce indices when given an offset.
  public func index(
    in r: ClosedRange<Index>
    ) -> (_ offset: Int) -> Index? {
    let upperBound = r.upperBound >= endIndex ? endIndex : r.upperBound
    return { self.index(r.lowerBound, offsetBy: $0, limitedBy: upperBound)  }
  }

  /// Returns an index generating function that will safely return an index
  /// offsetted by a given integer value clamped to the initial range or will
  /// return `nil` in case the offset produces an index out of bounds.
  ///
  /// - Parameter r: A range to clamp the indices generated.
  /// - Returns: A function that will produce indices when given an offset.
  public func index(
    in r: Range<Index>
    ) -> (_ offset: Int) -> Index? {
    let upperBound = r.upperBound >= endIndex ? endIndex : r.upperBound
    return { self.index(r.lowerBound, offsetBy: $0, limitedBy: upperBound) }
  }

  /// Returns an index generating function that will safely return an index
  /// offsetted by a given integer value clamped to the initial range or will
  /// return `nil` in case the offset produces an index out of bounds.
  ///
  /// - Parameter r: A range to clamp the indices generated.
  /// - Returns: A function that will produce indices when given an offset.
  public func index(
    in r: PartialRangeThrough<Index>
    ) -> (_ offset: Int) -> Index? {
    let upperBound = r.upperBound >= endIndex ? endIndex : r.upperBound
    return { self.index(self.startIndex, offsetBy: $0, limitedBy: upperBound) }
  }

  /// Returns an index generating function that will safely return an index
  /// offsetted by a given integer value clamped to the initial range or will
  /// return `nil` in case the offset produces an index out of bounds.
  ///
  /// - Parameter r: A range to clamp the indices generated.
  /// - Returns: A function that will produce indices when given an offset.
  public func index(
    in r: PartialRangeUpTo<Index>
    ) -> (_ offset: Int) -> Index? {
    let upperBound = r.upperBound >= endIndex ? endIndex : r.upperBound
    return { self.index(self.startIndex, offsetBy: $0, limitedBy: upperBound) }
  }

  /// Returns the longest possible substrings of this `String`, in order,
  /// around elements equal to any character of the given `CharacterSet`.
  ///
  /// The resulting array consists of at most `1` subsequence. Elements that
  /// are used to split the collection are **not** returned as part of any
  /// subsequence.
  ///
  /// - Parameters:
  ///   - splittingCharacters: The set of characters to split on.
  /// - Returns: An array of `Substrings` such that each element is the
  ///   consecutive continuation from the last character in the string
  ///   that matched one of the characters in the set `splittingCharacters`.
  ///   matching `splittingCharacters`.
  /// - Complexity: O(*n*), where *n* is the length of the `String`.
  public func split(by splittingCharacters: CharacterSet) -> [Substring] {
    return split(whereSeparator: splittingCharacters.contains • ^\.scalar)
  }

  @inlinable
  public func replacingFirst(
    _ target: String,
    with replacement: String
  ) -> String {
    return range(of: target).map(curry(replacing) >>> with(replacement)) ?? self
  }

}

// MARK: - Append

extension String {

  /// Appends the given static string to this string.
  public mutating func append(
    contentsOf semistring: StaticString
  ) {
    append("\(semistring)")
  }

  /// Appends the given static string to this string.
  public mutating func append(
    _ scalar: Unicode.Scalar
  ) {
    append("\(scalar)")
  }

  @inlinable // Forward inlinability to append
  @_effects(readonly)
  @_semantics("string.concat")
  public func appending(_ other: String) -> String {
    mutating(self, with: String.append(other))
  }
}

// MARK: - Insert

extension String {

  /// Returns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    _ string: String,
    afterFirst character: Character
  ) -> (inout String) -> () {
    return { $0.insert(string, afterFirst: character) }
  }

  /// Returns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    contentsOf string: String,
    afterFirst character: Character
  ) -> (inout String) -> () {
    return { $0.insert(string, afterFirst: character) }
  }

  /// Returns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    contentsOf staticString: StaticString,
    afterFirst character: Character
  ) -> (inout String) -> () {
    return { $0.insert(contentsOf: staticString, afterFirst: character) }
  }

  /// Reeturns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    contentsOf substring: Substring,
    afterFirst character: Character
  ) -> (inout String) -> () {
    return { $0.insert(contentsOf: substring, afterFirst: character) }
  }

  /// Returns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    _ character: Character,
    afterFirst characterInString: Character
  ) -> (inout String) -> () {
    return { $0.insert(character, afterFirst: characterInString) }
  }

  /// Returns a function that will insert the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func insert(
    _ scalar: Unicode.Scalar,
    afterFirst character: Character
  ) -> (inout String) -> () {
    return { $0.insert(scalar, afterFirst: character) }
  }

  // MARK: Instance

  /// Infixes the given string to this string following the first occurrence
  /// of the given Character.
  ///
  /// - Parameters:
  ///   - other: The string to infix.
  ///   -
  /// - Complexity: O(*n*), where *n* is the combined length of the string and
  /// 1  `other`.
  public mutating func insert(
    _ string: String,
    afterFirst character: Character
  ) {
    guard let index = firstIndex(where: equals(character)) else { return }
    replaceSubrange(index..<index, with: string)
  }

  /// Infixes the given substring to this string following the first
  /// occurrence of the given Character.
  public mutating func insert(
    contentsOf substring: Substring,
    afterFirst character: Character
  ) {
    insert("\(substring)", afterFirst: character)
  }

  /// Infixes the given static string to this string following the first
  /// occurrence of the given Character.
  public mutating func insert(
    contentsOf staticString: StaticString,
    afterFirst character: Character
  ) {
    insert("\(staticString)", afterFirst: character)
  }

  /// Infixes the given character to this string following the first
  /// occurrence of the given Character.
  ///
  /// - Parameters:
  ///   - character: A character to insert.
  ///   - characterInString: A character in the string marking the start of the infix.
  public mutating func insert(
    _ character: Character,
    afterFirst characterInString: Character
  ) {
    insert("\(character)", afterFirst: characterInString)
  }

  /// Infixes the given uincode scalar to this string following the first
  /// occurrence of the given Character.
  ///
  /// - Parameters:
  ///   - scalar: A Unicode scalar.
  ///   - character: A character in the string marking the start of the infix.
  public mutating func insert(
    _ scalar: Unicode.Scalar,
    afterFirst character: Character
  ) {
    insert("\(scalar)", afterFirst: character)
  }

  /// Infixes the characters in the given sequence to the string.
  ///
  /// - Parameters:
  ///   - characters: A sequence of characters.
  ///   - character: A character in the string marking the start of the infix.
  @_specialize(where S == String)
  @_specialize(where S == Substring)
  @_specialize(where S == Array<Character>)
  public mutating func insert<S: Sequence>(
    contentsOf characters: S,
    afterFirst character: Character
  ) where S.Iterator.Element == Character {
    switch characters {
    case let string as String:
      insert(string, afterFirst: character)
    case let substring as Substring:
      insert(contentsOf: substring, afterFirst: character)
    case let characters:
      characters.forEach { insert(.init($0), afterFirst: character) }
    }
  }

  /// Returns a new String with the given string infixed following th first
  /// occurrence of the given Character.
  ///
  /// - Parameters:
  ///   - characters: A sequence of characters.
  ///   - character: A character in the string marking the start of the infix.
  @inlinable // Forward inlinability to insert
  @_effects(readonly)
  public func inserting(
    _ string: String,
    afterFirst character: Character
  ) -> String {
    mutating(self, with: String.insert(string, afterFirst: character))
  }
}

// MARK: - Trim

extension String {

  /// Returns a new string with any whitespaces removed from its ends.
  @inlinable
  public var trimmed: String {
    trimming(.whitespaces)
  }

  /// Returns a new string made by removing from both ends of
  /// the `String` characters contained in a given character set.
  @inlinable
  public func trimming(_ set: CharacterSet) -> String {
    trimmingCharacters(in: set)
  }

  /// Removes from both ends of the `String` characters contained in a given
  /// character set.
  @inlinable
  public mutating func trim(_ characters: CharacterSet) -> () {
    self = .init(trimming(characters))
  }

  /// Removes whitespaces from both ends of this `String`.
  @inlinable
  public mutating func trim() -> () {
    trim(.whitespaces)
  }
}

// MARK: - Prepend

extension String {

  /// Reeturns a function that will prepend the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  /// - Complexity: O(*n*), where *n* is the combined length of the string and
  ///   `other`.
  public static func prepend(_ other: String) -> (inout String) -> () {
    return { $0.prepend(other) }
  }

  // MARK: Instance

  /// Prepends the given string to this string.
  ///
  /// The following example builds a customized greeting by using the
  /// `prepend(_:)` method:
  ///
  ///     var greeting = ", hello!"
  ///     if let name = getUserName() {
  ///         greeting.prepend(name)
  ///     } else {
  ///         greeting.prepend("Friend")
  ///     }
  ///     print(greeting)
  ///     // Prints "Friend, hello!"
  ///
  /// - Parameter other: Another string.
  /// - Complexity: O(*n*), where *n* is the combined length of the string and
  ///   `other`.
  public mutating func prepend(_ other: String) {
    replaceSubrange(startIndex..<startIndex, with: other)
  }

  /// Prepends the given character to the string.
  ///
  /// The following example adds a string to the beginning of a string.
  ///
  ///     var world = " World!"
  ///     world.prepend("Hello,")
  ///     print(world)
  ///     // Prints "Hello, World!r"
  ///
  /// - Parameter c: The character to prepend to the string.
  public mutating func prepend(_ c: Character) {
    prepend("\(c)")
  }

  /// Prepends the given Unicode scalar to this string.
  public mutating func prepend(_ scalar: Unicode.Scalar) {
    prepend("\(scalar)")
  }

  /// Prepends the given string to this string.
  public mutating func prepend(contentsOf string: String) {
    prepend(string)
  }

  /// Prepends the given substring to this string.
  public mutating func prepend(contentsOf string: Substring) {
    prepend("\(string)")
  }

  /// Prepends the given static string to this string.
  public mutating func prepend(contentsOf string: StaticString) {
    prepend("\(string)")
  }

  /// Prepends the characters in the given sequence to the string.
  ///
  /// - Parameter characters: A sequence of characters.
  @_specialize(where S == String)
  @_specialize(where S == Substring)
  @_specialize(where S == Array<Character>)
  public mutating func prepend<S: Sequence>(
    contentsOf characters: S
  ) where S.Iterator.Element == Character {
    switch characters {
    case let string as String:
      prepend(string)
    case let substring as Substring:
      prepend(contentsOf: substring)
    case let characters:
      characters.forEach { prepend(.init($0)) }
    }
  }

  @inlinable // Forward inlinability to prepend
  @_effects(readonly)
  @_semantics("string.concat")
  public func prepending(_ other: String) -> String {
    mutating(self, with: String.prepend(other))
  }
}

// MARK: - Reflection

extension String {

  public init<Subjectᵦ, Subjectᵧ>(
    reflecting subjects: (Subjectᵦ, Subjectᵧ),
    separator sep: String
  ) {
    self = subjects
      => cross(Self.init(reflecting:), Self.init(reflecting:))
      => { $0 ++ sep ++ $1 }
  }
}

// MARK: - Interpolation

extension DefaultStringInterpolation {

  /// Interpolates the amount of characters `n` specified of the string
  /// representation of the given instance `x`, ending with the specified
  /// terminator.
  ///
  /// - Parameters
  ///   - x: An instance to interpolate as its `String` representation.
  ///   - n: The amount of characters to take from the string.
  ///   - terminator: A suffix to interpolate, defaults to `"…"`.
  @inlinable
  public mutating func appendInterpolation<T>(
    _ x: T,
    trunc n: Int,
    terminator: String = "…"
  ) {
    appendInterpolation("\(x)".count > n
      ? "\(x)"[...n] ++ terminator
      : "\(x)")
  }

  /// Repeats the given string the specified amount of times.
  ///
  /// - Parameters:
  ///   - string: The string whose repetitions will be interpolated.
  ///   - n: The amount of times to repeat the given string.
//  @inlinable
//  public mutating func appendInterpolation<S: StringProtocol>(
//    _ string: S,
//    times: Int
//  ) {
//    appendInterpolation(times.repeats(of: string)?.reduce("", +) ?? "")
//  }

  /// Interpolates a string created by using the given format string `format`
  /// as a template into which the given value `x` is substituted according to
  /// the user’s default locale.
  ///
  /// - Parameters:
  ///   - x: The value to format.
  ///   - format: The format to apply.
  @inlinable
  public mutating func appendInterpolation(_ x: CVarArg, format: String) {
    appendInterpolation(String.localizedStringWithFormat(format, x))
  }
}

extension String {

  /// Returns a `String` object initialized by using a given format string as
  /// a template into which the remaining argument values are substituted
  /// according to the user’s default locale.
  ///
  /// Use `%` when the mindboggingly slow Swift's String interpolation lexer
  /// severly affects compilation and/or runtime performance.
  ///
  /// ### Example
  ///     "\(file):\(fn):\(line)"
  ///     // "Warning, the expression took 5 years to type-check." - Swift
  ///
  ///     "%@:%@:%d" % [file, fn, float]
  ///     // Objc: "Step aside, kid. I got this."
  ///     // Swift: "Wait, wait! One of the va—"
  ///     // *crashes*!
  ///     // Swift: "—lues has the wrong type..."
  ///     // Objc: "...I'm too old for this shit."
  ///
  /// - Note: Operation is inherently unsafe, use sparingly.
  /// - Parameters:
  ///   - format: C-like formatted string.
  ///   - arguments: An array of consecutive values corresponding to each
  ///     formatting token in `format`.
  /// - Returns: The formatted String.
  /// - SeeAlso:
  ///   https://docs.python.org/2/library/stdtypes.html#string-formatting
  @_transparent
  @available(swift, deprecated: 5.0, message: "Use Swift 5 interpolation.")
  public static func % (format: String, arguments: [CVarArg]) -> String {
    return String(format: format, arguments: arguments)
  }
}

// MARK: - Foundation interop

import class CoreFoundation.CFString
import func CoreFoundation.CFRangeMake
import struct Foundation.NSRange

extension StringProtocol {

  public var ns: NSString {
    return String(self) as NSString
  }

  public var cf: CFString {
    return String(self) as CFString
  }

  public var nsRange: NSRange {
    return nsRange(of: String(self))
  }

  public func nsRange(of string: String) -> NSRange {
    return ns.range(of: string, options: [])
  }
}

// MARK: -
// MARK: - Static thunks

extension String {

  /// Returns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    _ other: String
  ) -> (inout String) -> () {
    return { $0.append(other) }
  }

  /// Returns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    contentsOf other: String
  ) -> (inout String) -> () {
    return { $0.append(other) }
  }

  /// Returns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    contentsOf other: StaticString
  ) -> (inout String) -> () {
    return { $0.append(contentsOf: other) }
  }

  /// Reeturns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    contentsOf substring: Substring
  ) -> (inout String) -> () {
    return { $0.append(contentsOf: substring) }
  }

  /// Returns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    _ other: Character
  ) -> (inout String) -> () {
    return { $0.append(other) }
  }

  /// Returns a function that will append the given string to any mutable,
  /// `inout` string it is given.
  ///
  /// - Parameter other: Another string.
  public static func append(
    _ other: Unicode.Scalar
  ) -> (inout String) -> () {
    return { $0.append(other) }
  }
}

// MARK: - Free thunks

public func hasPrefix(_ prefix: String) -> (String) -> Bool {
  return { $0.hasPrefix(prefix) }
}

public func hasSuffix(_ suffix: String) -> (String) -> Bool {
  return { $0.hasSuffix(suffix) }
}

public func joined(separator: String) -> ([String]) -> String {
  return { $0.joined(separator: separator) }
}
