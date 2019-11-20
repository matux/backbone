import Swift

// MARK: - Ref<Value>

/// A class type capable of containing a value. `class` reference semantics
/// ensure the `value` contained won't be copied when passing the `Box`
/// instance around.
public class Box<Value> {

  /// The value contained inside this `Box` instance.
  fileprivate(set) var value: Value

  /// Creates a new `Box` that contains the given `value` inside.
  ///
  /// - Parameter value: The value to box.
  public init(_ value: Value) {
    self.value = value
  }

  /// Returns the value this instance refers to.
  public static prefix func * (_ this: Box) -> Value {
    return this.value
  }
}

/// A class type capable of containing a **mutable** value. `class` reference
/// semantics ensure the mutable `value` contained won't be copied when passing
/// the `MutBox` instance around.
public class MutBox<Value>: Box<Value> {

  /// The value contained inside this `Box` instance.
  public override var value: Value {
    get { return super.value }
    set { super.value = newValue }
  }
}

// MARK: - Value<Ref>

/// A `struct` type with a **strong** reference to a `class` instance.
public struct Ref<Object: AnyObject> {

  /// The value contained inside this `Ref` instance.
  public let object: Object

  /// Creates a new `Ref` with a **strong** reference to the given object.
  ///
  /// - Parameter value: The object to hold.
  public init(_ object: Object) {
    self.object = object
  }

  /// Returns the object this instance refers to.
  public static prefix func * (_ this: Ref) -> Object {
    return this.object
  }
}

/// A `value` type with a **weak** reference to a `class`.
public struct Weak<Object: AnyObject> {

  /// The value contained inside this `WeakRef` instance.
  private(set) public weak var object: Object?

  /// Creates a new `WeakRef` with the given **weak** reference.
  ///
  /// - Parameter value: The object to hold.
  public init(_ object: Object?) {
    self.object = object
  }

  /// Returns the object this instance refers to.
  public static prefix func * (_ this: Weak) -> Object? {
    return this.object
  }
}

/// A `value` type with an **unowned** reference to a `class`.
public struct Unowned<Object: AnyObject> {

  /// The value contained inside this `UnownedRef` instance.
  public unowned let object: Object

  /// Creates a new `UnownedRef` with the given **weak** reference.
  ///
  /// - Parameter value: The object to hold.
  public init(_ object: Object) {
    self.object = object
  }

  /// Returns the object this instance refers to.
  public static prefix func * (_ this: Unowned) -> Object {
    return this.object
  }
}
