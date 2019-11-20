import Swift

infix operator |+| : LogicalDisjunctionPrecedence

@_transparent
public func |+| <This, That>(x: This?, y: That) -> These<This, That> {
  return These(x, y)
}

@_transparent
public func |+| <This, That>(x: This, y: That?) -> These<This, That> {
  return These(x, y)
}

@_transparent
public func |+| <This, That>(x: This?, y: That?) -> These<This, That>? {
  switch (x, y) {
  case let (this?, that?): return .both(this, and: that)
  case let (this?, .none): return .just(this: this)
  case let (.none, that?): return .just(that: that)
  case     (.none, .none): return .none
  }
}

/// A representation of OR as an algebraic data type.
///
/// These has either a value of type `This`, a value of type `That`, or
/// two values of types `This` and `That`, respectively.
///
/// - Remark: `These` is to `OR` (`|`) as `Either` is to `XOR` (`^`)
public enum These<This, That> {

  /// Creates an instance that stores the given value.
  case this(This)

  /// Creates an instance that stores the given value.
  case that(That)

  /// Creates an instance that stores the given value.
  case these(This, That)

  // MARK: -

  /// Returns `this` value or returns `nil` if there's only `that` value.
  @inlinable
  public var this: This? {
    return `case`(this: id, that: const(.none), these: { x, _ in x })
  }

  /// Returns `that` value or returns `nil` if there's only `this` value.
  @inlinable
  public var that: That? {
    return `case`(this: const(.none), that: id, these: { _, y in y })
  }

  /// Returns both `this` and `that` or `nil` if one of `these` is `nil`.
  @inlinable
  public var these: (This, That)? {
    return `case`(this: const(.none), that: const(.none), these: cross(id, id))
  }

  // MARK: -

  @inlinable
  public static func just(this: This) -> Self {
    return .this(this)
  }

  @inlinable
  public static func just(that: That) -> Self {
    return .that(that)
  }

  @inlinable
  public static func both(_ this: This, and that: That) -> Self {
    return .these(this, that)
  }

  @_transparent
  public init(_ this: This) {
    self = .this(this)
  }

  @_transparent
  public init(_ that: That) {
    self = .that(that)
  }

  @inlinable
  public init(_ this: This?, _ that: That) {
    switch this {
    case .some(let this):
      self = .these(this, that)
    case .none:
      self = .that(that)
    }
  }

  @inlinable
  public init(_ this: This, _ that: That?) {
    switch that {
    case .some(let that):
      self = .these(this, that)
    case .none:
      self = .this(this)
    }
  }

  @inlinable
  public init?(_ this: This?, _ that: That?) {
    switch (this, that) {
    case (let x?, .none ): self = .this(x)
    case (.none,  let y?): self = .that(y)
    case (let x?, let y?): self = .these(x, y)
    case (.none,  .none ): return nil
    }
  }
}

extension These where This == () {

  /// Creates an instance with the empty tuple `()` stored in it.
  public static var this: Self {
    return .this(())
  }

  /// Creates an instance with the empty tuple `()` stored in it.
  @_transparent
  public init() {
    self = .this
  }

  /// Given a `These<(), That>`, attempts to create `that?`
  /// or defaults to this, ie. `()`, in case is `nil`.
  ///
  /// - Parameter that: This `These` `that` value.
  @_transparent
  public init(_ that: That?) {
    switch that {
    case .none:
      self = .this
    case .some(let that):
      self = .that(that)
    }
  }
}

extension These where That == () {

  /// Creates an instance with the empty tuple `()` stored in it.
  public static var that: Self {
    return .that(())
  }

  /// Creates an instance with the empty tuple `()` stored in it.
  @_transparent
  public init() {
    self = .that
  }

  /// Given a `These<This, ()>`, attempts to create `this?`
  /// or defaults to `that`, ie. `()`, in case is `nil`.
  ///
  /// - Parameter this: This `These` `this` value.
  @_transparent
  public init(_ this: This?) {
    switch this {
    case .none:
      self = .that
    case .some(let this):
      self = .this(this)
    }
  }
}

extension These {

  /// Returns the result of transforming either value.
  ///
  /// Performs a functional case analysis transformation over _either_ the
  /// left _or_ the right, depending on which one this instance
  /// holds.
  ///
  /// - Invariant: The result type for both transforms is guaranteed to equal.
  ///
  /// ```
  /// either :: (a -> c) -> (b -> c) -> Either a b -> c
  /// ```
  @inlinable
  public func `case`<Transformed>(
    this transform: (This) -> Transformed,
    that transformʹ: (That) -> Transformed,
    these transformʺ: (This, That) -> Transformed
  ) -> Transformed {
    switch self {
    case let .this(this):
      return transform(this)
    case let .that(that):
      return transformʹ(that)
    case let .these(this, that):
      return transformʺ(this, that)
    }
  }
}
