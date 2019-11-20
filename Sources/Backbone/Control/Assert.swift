import Swift

infix operator !  : CastingPrecedence // throw, left associative
infix operator !? : CastingPrecedence // assert, left associative
infix operator !! : FunctionMap // precond, left associative

@_transparent
public func assert<T>(_ predicate: @escaping (T) -> Bool) -> (T) -> () {
  return { x in assert(predicate(x)) }
}

@_transparent
public func ! <T>(
  optional: T?,
  error: @autoclosure () throws -> Swift.Error
) throws -> T {
  guard let x = optional.some else { throw try error() }
  return x
}

@_transparent
public func ! <T>(
  optional: T?,
  fail: () throws -> Never) rethrows -> T {
  guard let x = optional.some else { try fail() }
  return x
}

extension AnyOptional {

  /// Performs an `assert`-backed `unwrap` operation on the given `Optional`
  /// instance.
  ///
  /// (`!?`) returns the unwrapped value or, in case this `Optional` instance
  /// is `nil` this function will:
  ///   * Return `nil` when running in a non-Debug configuration.
  ///   * Raise with `assertionFailure` and the given `message`.
  ///
  /// - Parameters:
  ///   - optional: An optional value.
  ///   - message: A message to emit via `assertionFailure` upon
  ///     failing to unwrap the optional.
  /// - Returns: The unwrapped optional, `nil` on Release or `Never` on Debug.
  /// - SeeAlso:
  ///     https://github.com/apple/swift-evolution/blob/master/proposals/0217-bangbang.md
  @_transparent
  public static func !? (
    optional: Self,
    message: @autoclosure () -> String
  ) -> Self {
    switch optional.some {
    case .some:
      return optional
    case .none:
      assertionFailure(message())
      return nil
    }
  }
}

extension Optional {

  /// Performs an unsafe force unwrap, returning the wrapped
  /// value of the given `Optional` or executing `preconditionFailure`
  /// with the given `message` in case of `nil`.
  ///
  /// The unwrap or die operator provides a code-source rationale for failed
  /// unwraps:
  ///
  ///     let value = wrappedValue !! "Explanation why `lhs` must not be `nil`"
  ///
  /// Use (`!!`) when a `nil` `Optional` value would constitute a serious
  /// programming error with undefined behavior:
  ///
  ///     let mainHost = URL(string: "http://swift.org")
  ///         !! "host url malformed, cannot operate without one, exiting..."
  ///
  /// - Remark: The result of a successful operation will be the same type
  ///   as the wrapped value of `lhs`.
  ///
  /// - Note: This operation can be found across many different languages,
  ///   for example: Perl and Ruby's `x or die` operator, Rust's postfix `?`
  ///   and Kotlin's special case of the elvis operator `x ?: throw`.
  ///
  /// - Parameters:
  ///   - optional: An optional value.
  ///   - message: A message to emit via `preconditionFailure` upon
  ///     failing to unwrap the optional.
  /// - Returns: The unwrapped optional or `Never`
  /// - SeeAlso:
  ///     https://github.com/apple/swift-evolution/blob/master/proposals/0217-bangbang.md
  @_transparent
  public static func !! (
    _ optional: Wrapped?,
    _ message: @autoclosure () -> String
  ) -> Wrapped {
    switch optional {
    case let .some(x):
      return x
    case .none:
      preconditionFailure(message())
    }
  }
}

/// Abstracts the notion of a runtime failure.
///
/// - assert: Indicates that an internal sanity check failed.
/// - precond: Indicates that a precondition was violated.
/// - undef:
/// - fatal: Unconditionally prints a given message and stops execution.
/// - signal: Raises a POSIX signal.
public enum Trap {
  //case overflow<T>(T, Bool)
  case precond(String)
  case undef(String)
  case fatal(String)
  case signal(Signal)
}

public enum DebugTrap {
  case assert(String)
}

@_transparent
@inline(__always)
public func raise(
  _ trap: Trap,
  file: StaticString = #file,
  line: UInt = #line
) -> Never {
  trap.raise(file, line)
}

@_transparent
@inline(__always)
public func raise(
  _ trap: DebugTrap
) -> () {
  assertionFailure(trap.message)
}

/// If `error` is true, prints an error message in debug mode, traps in
/// release mode, and returns an undefined error otherwise.
/// Otherwise returns `result`.
@_transparent
@_optimize(size)
public func assertOverflow<T>(
  _ args: (T, Bool)
) -> T {
  return _overflowChecked(args)
}

// MARK: - Stdlib

/// Represents internal assert levels in Swift.
public enum AssertConfiguration {
  case debug, release, fast

  public static let current =
    _isDebugAssertConfiguration() ? debug :
    _isFastAssertConfiguration()  ? fast :
                                    release
}

// MARK: - POSIX

import func Darwin.exit

extension Trap {

  @_transparent
  @usableFromInline
  @inline(never)
  internal func raise(
    _ file: StaticString,
    _ line: UInt
  ) -> Never {
    switch self {
    case let .precond(message):
      preconditionFailure(message, file: file, line: line)
    case let .undef(message):
      return _undefined(message, file: file, line: line)
    case let .fatal(message):
      fatalError(message, file: file, line: line)
    case let .signal(signal):
      exit(signal, file: file, line: line)
    }
  }

  @_transparent
  @_semantics("programtermination_point")
  @usableFromInline
  internal func exit(
    _ signal: Signal,
    file: StaticString,
    line: UInt
  ) -> Never {
    Swift.print("[FATAL] Raised \(signal) at \(file):\(line)")
    Darwin.exit(signal.posix)
  }
}

extension DebugTrap {

  @_transparent
  @usableFromInline
  var message: String {
    switch self { case let .assert(s): return s }
  }
}

import let Darwin.SIGHUP
import let Darwin.SIGINT
import let Darwin.SIGQUIT
import let Darwin.SIGILL
import let Darwin.SIGTRAP
import let Darwin.SIGABRT

extension Trap {

  public enum Signal: String, CustomStringConvertible {
    case hangup = "SIGHUP"
    case interrupt = "SIGINT"
    case quit = "SIGQUIT"
    case illegal = "SIGILL"
    case trap = "SIGTRAP"
    case abort = "SIGABRT"

    public var description: String {
      return rawValue
    }

    public var posix: Int32 {
      switch self {
      case .hangup: return SIGHUP
      case .interrupt: return SIGINT
      case .quit: return SIGQUIT
      case .illegal: return SIGILL
      case .trap: return SIGTRAP
      case .abort: return SIGABRT
      }
    }
  }
}
