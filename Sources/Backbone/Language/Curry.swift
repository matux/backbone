import Swift

/// Returns a series of **chained** **unary** functions that will collect
/// **each** argument of the given function `f` in order, deferring its
/// invocation until all arguments are collected.
///
/// - Parameters:
///   - x: The binary function's first argument.
///   - y: The binary function's second argument.
/// - Returns: A composition of two pure functions.
/// - Tag: Curry.swift
enum Curry {}

/// Binary with closure currying.
@inlinable
public func curry<A, B, Result>(
  _ f: @escaping (A, @escaping @autoclosure () -> B) -> Result
) -> (A) -> (@escaping @autoclosure () -> B) -> Result {
  { a in { b in f(a, b() ) } }
}

/// Ternary currying.
@inlinable
public func curry<A, B, C, Result>(
  _ f: @escaping ((A, B, C)) -> Result
) -> (A) -> (B) -> (C) -> Result {
  { a in { b in { c in f((a, b, c)) } } }
}

/// Swift instance method currying.
///
/// This overload is accepts Swift's statically-synthesized instance methods.
///
/// - SeeAlso: [Swift Instance Methods are Curried Functions][article]
///
/// [article]: https://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
@inlinable
public func curry<Instance, A, B, Result>(
  _ method: @escaping (Instance) -> (A, B) -> Result
) -> (Instance) -> (A) -> (B) -> Result {
  { instance in { a in { b in method(instance)(a, b) } } }
}

/// Returns an isomorphic Hom-set's left adjunct bijection of the given right
/// adjoint exponential object in a cartesian closed monoidal category.
@inlinable
public func uncurry<A, B, Result>(
  _ λ: @escaping (A) -> (B) -> Result
) -> ((a: A, b: B)) -> Result {
  { Π in λ (Π.a) (Π.b) }
}

/// Returns an isomorphic Hom-set's left adjunct bijection of the given right
/// adjoint exponential object in a cartesian closed monoidal category.
@inlinable
public func uncurry<A, B, C, Result>(
  _ λ: @escaping (A) -> (B) -> (C) -> Result
) -> ((a: A, b: B, c: C)) -> Result {
  { Π in λ (Π.a) (Π.b) (Π.c) }
}

/// Returns an isomorphic Hom-set's left adjunct bijection of the given right
/// adjoint exponential object in a cartesian closed monoidal category.
@inlinable
public func uncurry<A, B, C, Result>(
  _ λ: @escaping (A) -> (B, C) -> Result
) -> ((a: A, b: B, c: C)) -> Result {
  { Π in λ (Π.a) (Π.b, Π.c) }
}
