import typealias Swift.AnyObject
import class Foundation.NSObject

public protocol PassableByWeakRef: AnyObject { }
public protocol PassableByUnownedRef: AnyObject { }

extension NSObject: PassableByWeakRef { }
extension NSObject: PassableByUnownedRef { }

extension PassableByWeakRef {

  /// Captures `self` weakly
  public func weak(_ body: @escaping (Self) -> ()) -> () -> () {
    return { [weak self] in self.map(body) }
  }

  public func weak<U>(_ body: @escaping (Self) -> U) -> () -> U? {
    return { [weak self] in self.map(body) }
  }

  public func weak<T>(_ body: @escaping (Self, T) -> ()) -> (T) -> () {
    return { [weak self] x in self.map(curry(body))?(x) }
  }

  public func weak<T>(_ body: @escaping (Self) -> (T) -> ()) -> (T) -> () {
    return { [weak self] x in self.map(body)?(x) }
  }

  public func weak<T, U>(_ body: @escaping (Self, T) -> U) -> (T) -> U? {
    return { [weak self] x in self.map(curry(body))?(x) }
  }

  public func weak<T, Tʹ>(_ body: @escaping (Self, T, Tʹ) -> ()) -> (T, Tʹ) -> () {
    return { [weak self] x, y in self.map(curry(body))?(x)(y) }
  }

  public func weak<T, Tʹ, U>(_ body: @escaping (Self, T, Tʹ) -> U) -> (T, Tʹ) -> U? {
    return { [weak self] x, y in self.map(curry(body))?(x)(y) }
  }
}

extension Optional where Wrapped: PassableByWeakRef {

  /// Captures `self` weakly
  public func weak(_ body: @escaping (Wrapped) -> ()) -> () -> () {
    return { [weak some] in some.map(body) }
  }

  public func weak<U>(_ body: @escaping (Wrapped) -> U) -> () -> U? {
    return { [weak some] in some.map(body) }
  }

  public func weak<A>(_ body: @escaping (Wrapped, A) -> ()) -> (A) -> () {
    return { [weak some] a in some.map(curry(body))?(a) }
  }

  public func weak<A>(_ body: @escaping (Wrapped) -> (A) -> ()) -> (A) -> () {
    return { [weak some] a in some.map(body)?(a) }
  }

  public func weak<A, U>(_ body: @escaping (Wrapped, A) -> U) -> (A) -> U? {
    return { [weak some] a in some.map(curry(body))?(a) }
  }

  public func weak<A, B>(_ body: @escaping (Wrapped, A, B) -> ()) -> (A, B) -> () {
    return { [weak some] a, b in some.map(curry(body))?(a)(b) }
  }

  public func weak<A, B, U>(_ body: @escaping (Wrapped, A, B) -> U) -> (A, B) -> U? {
    return { [weak some] a, b in some.map(curry(body))?(a)(b) }
  }
}

/// Captures `root` weakly
public func weak<Root: AnyObject>(
  _ root: Root,
  _ body: @escaping (Root) -> ()
) -> () -> () {
  return { [weak root] in root.map(body) }
}

public func weak<Root: AnyObject, U>(
  _ root: Root,
  _ body: @escaping (Root) -> U
) -> () -> U? {
  return { [weak root] in root.map(body) }
}

public func weak<Root: AnyObject, A>(
  _ root: Root,
  _ body: @escaping (Root, A) -> ()
) -> (A) -> () {
  return { [weak root] a in root.map { body($0, a) } }
}

public func weak<Root: AnyObject, A, U>(
  _ root: Root,
  _ body: @escaping (Root, A) -> U
) -> (A) -> U? {
  return { [weak root] a in root.map { body($0, a) } }
}

public func weak<Root: AnyObject, A, B>(
  _ root: Root,
  _ body: @escaping (Root, A, B) -> ()
) -> (A, B) -> () {
  return { [weak root] a, b in root.map { body($0, a, b) } }
}

public func weak<Root: AnyObject, A, B, U>(
  _ root: Root,
  _ body: @escaping (Root, A, B) -> U
) -> (A, B) -> U? {
  return { [weak root] a, b in root.map { body($0, a, b) } }
}

// MARK: Curried

/// Captures `root` weakly
public func weak<Root: AnyObject>(
  _ body: @escaping (Root) -> ()
) -> (Root) -> () -> () {
  { (root: Root) in { [weak root] in root.map(body) } }
}

public func weak<Root: AnyObject, U>(
  _ body: @escaping (Root) -> U
) -> (Root) -> () -> U? {
  { (root: Root) in { [weak root] in root.map(body) } }
}

public func weak<Root: AnyObject, A>(
  _ body: @escaping (Root, A) -> ()
) -> (Root) -> (A) -> () {
  { (root: Root) in { [weak root] a in root.map { body($0, a) } } }
}

public func weak<Root: AnyObject, A, U>(
  _ body: @escaping (Root, A) -> U
) -> (Root) -> (A) -> U? {
  { (root: Root) in { [weak root] a in root.map { body($0, a) } } }
}

public func weak<Root: AnyObject, A, B>(
  _ body: @escaping (Root, A, B) -> ()
) -> (Root) -> (A, B) -> () {
  { (root: Root) in { [weak root] a, b in root.map { body($0, a, b) } } }
}

public func weak<Root: AnyObject, A, B, U>(
  _ body: @escaping (Root, A, B) -> U
) -> (Root) -> (A, B) -> U? {
  { (root: Root) in { [weak root] a, b in root.map { body($0, a, b) } } }
}
// MARK: - Unowned

extension PassableByUnownedRef {

  /// Captures `self` weakly
  public func unowned(_ body: @escaping (Self) -> ()) -> () -> () {
    return { [unowned self] in body(self) }
  }

  public func unowned<U>(_ body: @escaping (Self) -> U) -> () -> U {
    return { [unowned self] in body(self) }
  }

  public func unowned<T>(_ body: @escaping (Self, T) -> ()) -> (T) -> () {
    return { [unowned self] x in body(self, x) }
  }

  public func unowned<T>(_ body: @escaping (Self) -> (T) -> ()) -> (T) -> () {
    return { [unowned self] x in body(self)(x) }
  }

  public func unowned<T, U>(_ body: @escaping (Self, T) -> U) -> (T) -> U {
    return { [unowned self] x in body(self, x) }
  }

  public func unowned<T, Tʹ>(_ body: @escaping (Self, T, Tʹ) -> ()) -> (T, Tʹ) -> () {
    return { [unowned self] x, y in body(self, x, y) }
  }

  public func unowned<T, Tʹ, U>(_ body: @escaping (Self, T, Tʹ) -> U) -> (T, Tʹ) -> U {
    return { [unowned self] x, y in body(self, x, y) }
  }
}

//extension Optional where Wrapped: PassableByUnownedRef {
//
//  /// Captures `self` unownedly
//  public func unowned(_ body: @escaping (Wrapped) -> ()) -> () -> () {
//    return { [unowned some] in some.map(body) }
//  }
//
//  public func unowned<U>(_ body: @escaping (Wrapped) -> U) -> () -> U? {
//    return { [unowned some] in some.map(body) }
//  }
//
//  public func unowned<A>(_ body: @escaping (Wrapped, A) -> ()) -> (A) -> () {
//    return { [unowned some] a in some.map(body&)?(a) }
//  }
//
//  public func unowned<A>(_ body: @escaping (Wrapped) -> (A) -> ()) -> (A) -> () {
//    return { [unowned some] a in some.map(body)?(a) }
//  }
//
//  public func unowned<A, U>(_ body: @escaping (Wrapped, A) -> U) -> (A) -> U? {
//    return { [unowned some] a in some.map(body&)?(a) }
//  }
//
//  public func unowned<A, B>(_ body: @escaping (Wrapped, A, B) -> ()) -> (A, B) -> () {
//    return { [unowned some] a, b in some.map(body&)?(a)(b) }
//  }
//
//  public func unowned<A, B, U>(_ body: @escaping (Wrapped, A, B) -> U) -> (A, B) -> U? {
//    return { [unowned some] a, b in some.map(body&)?(a)(b) }
//  }
//}

/// Captures `root` unownedly
public func unowned<Root: AnyObject>(
  _ root: Root,
  _ body: @escaping (Root) -> ()
) -> () -> () {
  return { [unowned root] in body(root) }
}

public func unowned<Root: AnyObject, U>(
  _ root: Root,
  _ body: @escaping (Root) -> U
) -> () -> U? {
  return { [unowned root] in body(root) }
}

public func unowned<Root: AnyObject, A>(
  _ root: Root,
  _ body: @escaping (Root, A) -> ()
) -> (A) -> () {
  return { [unowned root] a in body(root, a) }
}

public func unowned<Root: AnyObject, A, U>(
  _ root: Root,
  _ body: @escaping (Root, A) -> U
) -> (A) -> U? {
  return { [unowned root] a in body(root, a) }
}

public func unowned<Root: AnyObject, A, B>(
  _ root: Root,
  _ body: @escaping (Root, A, B) -> ()
) -> (A, B) -> () {
  return { [unowned root] a, b in body(root, a, b) }
}

public func unowned<Root: AnyObject, A, B, U>(
  _ root: Root,
  _ body: @escaping (Root, A, B) -> U
) -> (A, B) -> U? {
  return { [unowned root] a, b in body(root, a, b) }
}
