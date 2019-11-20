import Swift

/// Makes RawRepresentable conditionally conform to Hashable if its RawValue is
/// Hashable, which in turn allows us to use the rawValue value for hashing.
///
/// By leveraging a hashable RawValue, _concrete_ RawRepresentables can be
/// made hashable without the need to provide an implementation.
///
/// This is useful when extending concrete RawRepresentables across file/module
/// boundaries, since Swift is unable to automatically synthesize Hashable
/// conformances in extensions in a different file to the type.
extension RawRepresentable
  where Self: Hashable, RawValue: Hashable
{
  /// Hashes the essential components of this value by feeding them into the
  /// given hasher.
  ///
  /// - Parameter hasher: The hasher to use when combining the components
  ///                     of this instance.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
}

/// Allows homogenous descriptions of reified `AnyHashable` references.
extension _HasCustomAnyHashableRepresentation where Self: AnyObject {

  /// The reified `AnyHashable` description.
  public var anyHashableDescription: String {
    return "\(type(of: self)) reified from custom AnyHashable"
  }
}

extension Hasher {

  /// Adds the given value to this hasher, mixing its essential parts into the
  /// hasher state.
  ///
  /// - Parameter value: A value to add to the hasher.
  @inlinable
  @inline(__always)
  public static func combine<H: Hashable>(
    _ value: H
  ) -> (inout Hasher) -> () {
    return { hasher in hasher.combine(value) }
  }

  /// Finalizes the hasher state and returns the hash value.
  ///
  /// Finalizing consumes the hasher: it is illegal to finalize a hasher you
  /// don't own, or to perform operations on a finalized hasher. (These may
  /// become compile-time errors in the future.)
  ///
  /// Hash values are not guaranteed to be equal across different executions of
  /// your program. Do not save hash values to use during a future execution.
  ///
  /// - Returns: The hash value calculated by the hasher.
  @_effects(releasenone)
  public static func finalize(_ hasher: Hasher) -> Int {
    return hasher.finalize()
  }
}
