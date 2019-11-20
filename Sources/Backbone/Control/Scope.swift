import Swift

// "Effects are good, side-effects are bugs."

// MARK: - Side-Effect control

/// The capability of an instance to introduce self-bound scopes.
public protocol ScopeBinding {

  func `do`(_ f: (Self) throws -> ()) rethrows -> ()
  func tap(_ f: (Self) throws -> ()) rethrows -> Self

  func map<U>(_ f: (Self) throws -> U) rethrows -> U

  mutating func mutate(_ f: (inout Self) -> ()) -> Self
  func with<U>(_ f: (inout Self) throws -> U) rethrows -> U
}

extension ScopeBinding {

  // swift's do
  @inlinable
  public func `do`(
    _ f: (Self) throws -> ()
  ) rethrows -> () {
    return try f(self)
  }

  // tee, tap or kotlin's also
  @inlinable
  public func thru(
    _ f: (Self) throws -> ()
  ) rethrows -> Self {
    try f(self)
    return self
  }

  @inlinable
  public func map<U>(
    _ f: (Self) throws -> U
  ) rethrows -> U {
    return try f(self)
  }

  @inlinable
  public mutating func `var`(
    _ f: (inout Self) throws -> ()
  ) rethrows -> Self {
    var x = self
    try f(&x)
    return self
  }

  @inlinable
  public func with<U>(
    _ f: (inout Self) throws -> U
  ) rethrows -> U {
    var `self` = self
    return try f(&self)
  }
}

