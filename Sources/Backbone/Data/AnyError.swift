import protocol Foundation.LocalizedError
import class Foundation.NSError
import Swift

// MARK: - Converters

/// Turns a partial function into a total function that consumes its exceptions.
///
/// - Parameter partial: A partial function.
/// - Returns: A function wrapping its result together with an exception.
public func total<T, U>(
  _ partial: @escaping (T) throws -> U
) -> (T) -> Optional<U> {
  return { x in .init(catching: { try partial(x) }) }
}

/// Turns a partial function into a total function.
///
/// - Parameter partial: A partial function.
/// - Returns: A function wrapping its result together with an exception.
public func total<T, U>(
  _ partial: @escaping (T) throws -> U
) -> (T) -> Result<U, Swift.Error> {
  return { x in .init(catching: { try partial(x) }) }
}

// MARK: - ErrorConvertible

/// A type with a `Swift.Error` representation.
public protocol ErrorConvertible: Swift.Error {

  /// Creates a new instance from the given `Swift.Error` instance.
  ///
  /// - Parameter error: The error to model this type after.
  /// - Returns: A new instance of the type modeled after the given error.
  static func from(_ error: Swift.Error) -> Self
}

// MARK: - Swift.Error

extension Swift.Error {

  /// The error code.
  public var code: Int {
    return (self as NSError).code
  }

  /// A error domain.
  public var domain: String {
    return (self as NSError).domain
  }
}

// MARK: - AnyError

/// A type-erased representation of a `Swift.Error` for generic contexts.
public struct AnyError: Swift.Error {

  /// The concrete `Swift.Error` instance made available for reification.
  public let error: Swift.Error

  /// Creates a new instance of `AnyError` wrapping the given `Swift.Error`.
  ///
  /// - Parameter error: The `Swift.Error` instance to wrap and type-erase.
  public init(_ error: Swift.Error) {
    switch error {
    case let error as AnyError:
      self = error
    case let error:
      self.error = error
    }
  }
}

/// Facilitates `AnyError` interop with conforming types.
extension AnyError: ErrorConvertible {

  public static func from(
    _ error: Swift.Error
  ) -> AnyError {
    return .init(error)
  }
}

extension AnyError: CustomStringConvertible & CustomDebugStringConvertible {

  public var description: String {
    return .init(describing: error)
  }

  public var debugDescription: String {
    return .init(reflecting: error)
  }
}

extension AnyError: LocalizedError {

  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    return error.localizedDescription
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    return (error as? LocalizedError)?.failureReason
  }

  /// A localized message providing “help” text if the user requests help.
  public var helpAnchor: String? {
    return (error as? LocalizedError)?.helpAnchor
  }

  /// A localized message describing how one might recover from the failure.
  public var recoverySuggestion: String? {
    return (error as? LocalizedError)?.recoverySuggestion
  }
}

extension AnyError: Equatable {

  public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
    return lhs.error._code == rhs.error._code
      && lhs.error._domain == rhs.error._domain
  }
}

// MARK: - NSError

import class Foundation.NSError
import let Foundation.NSLocalizedDescriptionKey

extension Result where Failure: NSError {

  enum Keys: String {
    case domain = "co.matux.prelude"
    case function = "co.matux.prelude.function"
    case file = "co.matux.prelude.file"
    case line = "co.matux.prelude.line"

    static var description: String { return NSLocalizedDescriptionKey }

    var key: String { return rawValue }
  }

  /// Returns an `NSError` encoded
  public static func error(
    _ message: String = "",
    function: String = #function,
    file: String = #file,
    line: Int = #line
  ) -> NSError {
    return .init(domain: Keys.domain.key, code: 0, userInfo: [
      Keys.function.key: function,
      Keys.file.key: file,
      Keys.line.key: line,
      Keys.description: message])
  }
}

/// Facilitates `Swift.Error` interop with `NSError`
extension NSError: ErrorConvertible {

  public static func from(_ error: Swift.Error) -> Self {
    return T.reinterpretCast(error)
  }
}

extension NSError {
  typealias Keys = Result<(), NSError>.Keys

  public var function: String? {
    return userInfo[Keys.function.key] as? String
  }

  public var file: String? {
    return userInfo[Keys.file.key] as? String
  }

  public var line: Int? {
    return userInfo[Keys.line.key] as? Int
  }
}
