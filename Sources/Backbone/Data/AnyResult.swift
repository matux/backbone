import Swift

/// `AnyResult` is the abstract representation of success _or_ failure, and
/// the values associated with each case.
///
/// Since `Result` is a generic `enum`, `Result.Success` and `Result.Failure`
/// must be declared as a generic parameter instead of an `associatedtype`,
/// this means we can't constrain it.  We workaround this limitation by
/// extending `Result` with a `protocol` in the same vein as `AnyOptional`,
/// which effectively declares `Result.Success` and `Result.Failure` as
/// `associatedtype`s.
public protocol AnyResult {

  /// A success, storing a `Success` value.
  associatedtype Success

  /// A failure, storing a `Failure` value.
  associatedtype Failure: Swift.Error

  /// Returns the `Failure` value wrapped in an `Optional` monad or
  /// `.none` in case of `.failure`.
  var success: Success? { get }

  /// Returns the `Failure` value wrapped in an `Optional` monad, returning
  /// `.none` in case of `.success`.
  var failure: Failure? { get }

  /// Creates a successful `Result` with the given value.
  init(success: Success)

  /// Creates a failed `Result` with the given error value.
  init(failure: Failure)
}

extension AnyResult {

  /// The concrete instance.
  @_transparent
  public var result: Self {
    return self
  }

  /// Returns the `Failure` value wrapped in an `Optional` monad or
  /// `.none` in case of `.failure`.
  @_transparent
  public static func success(_ result: Self) -> Success? {
    return result.success
  }

  /// Returns the `Failure` value wrapped in an `Optional` monad, returning
  /// `.none` in case of `.success`.
  @_transparent
  public static func failure(_ result: Self) -> Failure? {
    return result.failure
  }
}

extension Result: AnyResult {

  // MARK: ╶╼• AnyResult

  @inlinable
  public var success: Success? {
    switch self {
    case .success(let x): return x
    case .failure: return .none
    }
  }

  @inlinable
  public var failure: Failure? {
    switch self {
    case .success: return .none
    case .failure(let e): return e
    }
  }
}
