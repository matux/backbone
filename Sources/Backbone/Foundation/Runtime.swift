import Foundation

// MARK: - Selector

extension NSObject {

  /// Returns a pointer to the start of the **Objective-C** _nullary_ method
  /// implementation described by the given `Selector` value, reinterpreted as
  /// a `@convention(c)`-decorated Swift _0-ary_ function that can be invoked
  /// idiomatically with no parameters.
  ///
  /// This data type is a pointer to the start of the function that implements
  /// the method. This function uses standard C calling conventions as
  /// implemented for the current CPU architecture.
  ///
  /// ### Internal function reification.
  ///
  /// The first argument is a pointer to **self** (that is, the memory for the
  /// particular instance of this **class**, or, for a **class method**, a
  /// pointer to the **metaclass**).
  ///
  /// The second argument is the method selector. The method arguments follow,
  /// which in the case of this _nullary_ function, there are none.
  ///
  /// - Parameter selector: The selector to build the function from.
  /// - Returns: An idiomatic Swift function of 0-arity.
  open func method(named name: String) -> Optional<() -> ()> {
    typealias Sel = T<@convention(c) (NSObject, Selector) -> ()>
    return weak(zip(˙$0, Selector(named: name)) >>> { Π in
      Π.0.method(for: Π.1).map(Sel.reinterpretCast >>> splat(Π))
    })
  }
}

extension Selector: SelfAware {

  /// Creates a new **unchecked** `Selector` with the given name.
  ///
  /// Use `#selector` whenever possible instead of this function as `#selector`
  /// provides type checking over the entire function's signature, including
  /// whether or not such function actually exists.
  ///
  /// To make a `Selector`, `Selector.from(string:)` passes a **UTF-8 encoded**
  /// character representation of `string` to `sel_registerName(_:)` and
  /// returns the value returned by that function.
  ///
  /// - Attention: If the selector does not exist, **it is registered** and the
  ///   newly registered `Selector` is returned.
  ///
  /// - Note: A colon (`:`) is part of a method name; `setHeight` is not the
  ///   same as `setHeight:`.
  ///
  /// - Parameter name: The name of the `Selector`.
  public init(named name: String) {
    self = NSSelectorFromString(name)
  }
}

// MARK: -

/// Policies related to associative references.
/// These are options to `objc_setAssociatedObject()`
extension objc_AssociationPolicy {

  /// Specifies a weak reference to the associated object.
  public static let assignment = OBJC_ASSOCIATION_ASSIGN

  /// Specifies a strong reference to the associated object.
  /// The association is not made atomically.
  public static let nonatomicRetain = OBJC_ASSOCIATION_RETAIN_NONATOMIC

  /// Specifies that the associated object is copied.
  /// The association is not made atomically.
  public static let nonatomicCopy = OBJC_ASSOCIATION_COPY_NONATOMIC

  /// Specifies a strong reference to the associated object.
  /// The association is made atomically.
  public static let retain = OBJC_ASSOCIATION_RETAIN

  /// Specifies that the associated object is copied.
  /// The association is made atomically.
  public static let copy = OBJC_ASSOCIATION_COPY
}

public /*namespace*/ enum Runtime {

  public static subscript<Root: NSObjectProtocol, Value>(
    key: UnsafeRawPointer,
    with root: Root
  ) -> Value? {
    objc_getAssociatedObject(root, key) as? Value
  }

  /// Associates a value for a given object using a given key and policy.
  ///
  /// - Parameters:
  ///   - value: The `value` to associate with the `key` for `object`. Pass
  ///     `.none` to clear an existing association.
  ///   - root: The source `object` for the association.
  ///   - key: The `key` for the association.
  ///   - policy: The `policy` for the association.
  @_transparent
  public static func associate<Root: NSObjectProtocol, Value>(
    _ value: Value,
    with root: Root,
    under key: UnsafeRawPointer,
    as policy: objc_AssociationPolicy
  ) {
    objc_setAssociatedObject(root, key, value, policy)
  }

  /// Returns the value associated with a given object for a given key.
  ///
  /// - Parameters:
  ///   - object: The source `object` for the association.
  ///   - key: The `key` for the association.
  /// - Returns: The `value` associated with the `key` for `object`.
  @_transparent
  public static func value<Root: NSObjectProtocol, Value>(
    in root: Root,
    under key: UnsafeRawPointer
  ) -> Value? {
    objc_getAssociatedObject(root, key) as? Value
  }
}
