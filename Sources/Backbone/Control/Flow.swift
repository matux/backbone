// Statements as expressions enabling the return of values.
// https://fsharpforfunandprofit.com/posts/expressions-vs-statements/
import Swift

// MARK: - Boolean (tacit)

// *when    (Bool) → (() → ()) → ()
// *unless ¬(Bool) → (() → ()) → ()
// *iff     (Bool) → (() → ()) → (() → ()) → ()
// when     (Bool,    () → ()) → ()
// unless  ¬(Bool,    () → ()) → ()
// *maybe   (() → ()) → (Bool) → ()
// choice   (() → (), () → ()) → (Bool) → ()
//
// iff:
//   ⁰ ᵉᵗʰᵉʳ (𝑓, 𝑔) → 𝔹 → ∅ ⦰ ⦱ ⦲ ⦳ ⦴
//   ¹ ᶠˡᵖ   (𝑔, 𝑓) → 𝔹 → ∅
//   ² ᶜᵘʳʳʸ 𝑔 → 𝑓 → 𝔹 → ∅
//   ³ ᶠˡᵖ   𝔹 → 𝑓 → 𝑔 → ∅

public let when = { b, f in b ? map(f)() : () }
public let unless = mapFst(!) >>> when

public let _when = curry(when)
public let _unless = curry(unless)
public let _maybe = flip(_when • isTrue)
public let _otherwise = { (f: @escaping () -> ()) in { $0 ?? f() } }
public let _either = { f, g in _when • isTrue >>> with(f) >>> otherwise(g) }
public let _iff = _either => flip => curry => flip

// MARK: - Proposition

public func given<T, U>(
  _ x: T?,
  suchThat p: (T) -> Bool,
  return y: @autoclosure () -> U,
  else z: @autoclosure () -> U
) -> U {
  x.map(p) == true ? y() : z()
}

public func given<A, B>(
  _ choice: Bool,
  _ a: @autoclosure () -> A,
  _ b: @autoclosure () -> B
) -> Either<A, B> {
  choice ? .left(a()) : .right(b())
}

public func given<T, U>(
  _ x: T?,
  suchThat p: (T) -> Bool,
  do f: @escaping (T) -> U
) -> U? {
  x.flatMap { x in when(x, p, f) }
}

public func either<U>(
  _ a: @escaping @autoclosure () -> U,
  or b: @escaping @autoclosure () -> U
) -> (Bool) -> U {
  { $0 ? a() : b() }
}

// MARK: - If expression

public func iff<T>(
  _ p: @escaping (T) -> Bool,
  _ f: @escaping (T) -> (),
  else g: @escaping (T) -> ()
) -> (T) -> () {
  { x in p(x) ? f(x) : g(x) }
}

public func iff<T, U>(
  _ p: @escaping (T) -> Bool,
  return y: @escaping @autoclosure () -> U,
  else z: @escaping @autoclosure () -> U
) -> (T?) -> U {
  { x in x.map(p) == true ? y() : z() }
}

public func iff<T, U>(
  _ p: @escaping (T) -> Bool,
  _ f: @escaping (T) -> U,
  else g: @escaping (T) -> U
) -> (T?) -> U? {
  { x in x.map { x in p(x) ? f(x) : g(x) } }
}

public func iff<T>(
  _ p: @escaping (T) -> Bool,
  _ f: @escaping () -> (),
  else g: @escaping () -> ()
) -> (T?) -> () {
  { x in x.map { x in p(x) ? f() : g() } }
}

public func iff<U>(
  _ choice: Bool,
  return x: @autoclosure () -> U,
  else y: @autoclosure () -> U
) -> U {
  choice ? x() : y()
}

// MARK: - Applying

//@discardableResult
//public func when<U>(_ p: Bool) -> (_ f: @escaping () -> U) -> U? { when& (p) }
//@discardableResult
//public func unless<U>(_ p: Bool) -> (_ f: @escaping () -> U) -> U? { unless& (p) }

//public func when     (_ b: Bool, _ f:              () -> ()) -> () { if b { f() } }
public func when<U>  (_ b: Bool, _ f: @autoclosure () -> U ) -> U? { b ? .some(f()) : .none }
//public func when<U>  (_ b: Bool, _ f:              () -> U ) -> U? { b ? .some(f()) : .none }
public func unless   (_ b: Bool, _ f:              () -> ()) -> () { if !b { f() } }
public func unless<U>(_ b: Bool, _ f: @autoclosure () -> U ) -> U? { !b ? .some(f()) : .none }
//public func unless<U>(_ b: Bool, _ f:              () -> U ) -> U? { !b ? .some(f()) : .none }

//public func when   (_ p: Bool, _ x: @autoclosure () -> ()) -> () { p ? x() : () }
//public func when<U>(_ p: Bool, _ x: @autoclosure () ->  U ) ->  U? { p ?  x()  : .none  }
//public func when<U>(_ p: Bool, _ x: @autoclosure () ->  U?) ->  U? { p ?  x()  : .none  }
//public func when<U>(_ p: Bool, _ x: @autoclosure () ->  U ) -> [U] { p ? [x()] : .empty }
//public func when<U>(_ p: Bool, _ x: @autoclosure () -> [U]) -> [U] { p ?  x()  : .empty }

//public func unless   (_ p: Bool, _ x: @escaping @autoclosure () -> ()) -> () { (λwhen • not) (p) (x) }
//public func unless<U>(_ p: Bool, _ x: @escaping @autoclosure () ->  U ) ->  U? { (*when • not) (p) (x) }
//public func unless<U>(_ p: Bool, _ x: @escaping @autoclosure () ->  U?) ->  U? { (*when • not) (p) (x) }
//public func unless<U>(_ p: Bool, _ x: @escaping @autoclosure () ->  U ) -> [U] { (*when • not) (p) (x) }
//public func unless<U>(_ p: Bool, _ x: @escaping @autoclosure () -> [U]) -> [U] { (*when • not) (p) (x) }

// MARK: - Predicate


public func when<T>   (_ x: T?, _ p:           (T) -> Bool, _ f:              ( ) -> ()) -> () { x.map(p) == true ? f() : () }
public func when<T>   (_ x: T?, _ p: @escaping (T) -> Bool, _ f:              (T) -> ()) -> () { const(())(x.map { if p($0) { f($0) } }) }
public func when<T>   (_ x: T?, _ p: @escaping (T) -> Bool, _ f:              (T) -> ()) -> T? { const(x)( x.map { if p($0) { f($0) } }) }
public func when<T, U>(_ x: T?, _ p:           (T) -> Bool, _ f: @autoclosure ( ) -> U ) -> U? { x.guard(p).map(const(f())) }
public func when<T, U>(_ x: T?, _ p:           (T) -> Bool, _ f:              (T) -> U ) -> U? { x.guard(p).map(f) }

public func unless<T>   (_ x: T?, _ p:           (T) -> Bool, _ f:              ( ) -> ()) -> () { x.map(p) == false ? f() : () }
public func unless<T>   (_ x: T?, _ p: @escaping (T) -> Bool, _ f:              (T) -> ()) -> () { const(())(x.map { if !p($0) { f($0) } }) }
public func unless<T>   (_ x: T?, _ p: @escaping (T) -> Bool, _ f:              (T) -> ()) -> T? { const(x)( x.map { if !p($0) { f($0) } }) }
public func unless<T, U>(_ x: T?, _ p:           (T) -> Bool, _ f: @autoclosure ( ) -> U ) -> U? { x.guard { !p($0) }.map(const(f())) }
public func unless<T, U>(_ x: T?, _ p:           (T) -> Bool, _ f:              (T) -> U ) -> U? { x.guard { !p($0) }.map(f) }


// MARK: - Side-effects

public func when  (_ p: Bool, do f: @escaping () -> ()) -> () { p ? f() : () }
public func unless(_ p: Bool, do f: @escaping () -> ()) -> () { when(!p, do: f) }

// MARK: - Side-effects (tacit)

public func when<T>(_ p: Bool, do f: @escaping (T) -> ()) -> (T) -> () { { p ? f($0) : () } }
//public func when<U>(_ p: Bool, do f: @escaping (U?) -> ()) -> (U?)  -> () { { p ? f($0) : () } }
//public func when<U>(_ p: Bool, do f: @escaping ([U]) -> ()) -> ([U]) -> () { { p ? f($0) : () } }

public func unless<T>(_ p: Bool, do f: @escaping (T) -> ()) -> (T) -> () { when(!p, do: f) }
//public func unless<U>(_ p: Bool, do f: @escaping (U?) -> ()) -> (U?)  -> () { when(!p, do: f) }
//public func unless<U>(_ p: Bool, do f: @escaping ([U]) -> ()) -> ([U]) -> () { when(!p, do: f) }

// MARK: - Predicate (tacit)

//public func when<T>   (_ p: @escaping (T) -> Bool, _ f: @escaping ( ) -> ()) -> (T) -> () { { x in p(x) ? f( ) : () } }
public func when<T>   (_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> ()) -> (T) -> () { { x in p(x) ? f(x) : () } }
public func when<T, U>(_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> U ) -> (T) -> U? { { x in p(x) ? .some(f(x)) : .none } }

//public func unless<T>   (_ p: @escaping (T) -> Bool, _ f: @escaping ( ) -> ()) -> (T) -> () { when(not • p, f) }
public func unless<T>   (_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> ()) -> (T) -> () { when(not • p, f) }
public func unless<T, U>(_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> U ) -> (T) -> U? { { x in p(x) ? .none : .some(f(x)) } }

////public func when<T>   (_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () -> ()) -> (T) -> () { with(x) • λwhen • p }
//public func when<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U ) -> (T) ->  U? { { p($0) ? .some(x()) : .none } }
////public func when<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U?) -> (T) ->  U? { with(x) • *when • p  }
////public func when<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U ) -> (T) -> [U] { with(x) • *when • p  }
////public func when<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () -> [U]) -> (T) -> [U] { with(x) • *when • p  }
//
////public func unless<T>   (_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () -> ( )) -> (T) -> () { with(x) • λunless • p }
//public func unless<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U ) -> (T) ->  U? { { p($0) ? .none : .some(x()) } }
////public func unless<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U?) -> (T) ->  U? { with(x) • *unless • p }
////public func unless<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () ->  U ) -> (T) -> [U] { with(x) • *unless • p }
////public func unless<T, U>(_ p: @escaping (T) -> Bool, _ x: @escaping @autoclosure () -> [U]) -> (T) -> [U] { with(x) • *unless • p }

// MARK: - Matching

public func when<T: Equatable>(_ x: T, _ f: @escaping () -> ()) -> (T) -> () { with(f) • curry(when) • equals(x) }
public func when<T: Equatable>(_ x: T, _ f: @escaping () -> (), otherwise g: @escaping () -> ()) -> (T) -> () { with(f) • curry(when) • equals(x) >>> otherwise(g) }

//public func when  <T: Equatable>(its a: T, _ aʹ: @escaping @autoclosure () ->  T) -> (T) ->  T  { with(aʹ) • *when • equals(a) >>> otherwise(a) }
//public func unless<T: Equatable>(its a: T, _ aʹ: @escaping @autoclosure () ->  T) -> (T) ->  T  { with(aʹ) • *unless • equals(a) >>> otherwise(a) }

// MARK: - Array Predicative (flat)

//public func when<T, U>(_ xs: [T]?, _ p: ([T]) -> Bool, _ f: @escaping (T) ->  U ) -> [U] { xs.map(p) == true ? xs.flatMap(Array.fmap(f)) ?? .empty : .empty }
//public func when<T, U>(_ xs: [T]?, _ p: ([T]) -> Bool, _ f: @escaping (T) -> [U]) -> [U] { xs.map(p) == true ? xs.flatMap(Array.bind(f)) ?? .empty : .empty }

// MARK: - Array Predicative (tacit)

//public func when<T, U>(_ p: @escaping ([T]) -> Bool, _ f: @escaping (T) ->  U ) -> ([T]?) -> [U] { flip(*when)(f)(p) }
//public func when<T, U>(_ p: @escaping ([T]) -> Bool, _ f: @escaping (T) -> [U]) -> ([T]?) -> [U] { flip(*when)(f)(p) }

// MARK: -
// MARK: - (obsolete)

//@available(*, unavailable, message: "Use optional.guard(p).when(some: f)")
//public func when<T>   (_ x: T?, _ p: (T) -> Bool, _ f: (T) -> ()) -> () { x.guard(p).when(some: f) }
//@available(*, unavailable, message: "Use optional.guard(p).map(f)")
//public func when<T, U>(_ x: T?, _ p: (T) -> Bool, _ f: (T) -> U ) -> U? { x.guard(p).map(f) }
//@available(*, unavailable, message: "Use optional.guard(p).flatMap(f)")
//public func when<T, U>(_ x: T?, _ p: (T) -> Bool, _ f: (T) -> U?) -> U? { x.guard(p).flatMap(f) }

//@available(*, unavailable, message: "Use optional.guard(p).map(f)")
//public func when<T, U>(_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> U ) -> (T?) -> U? { { x in x.guard(p).map(f) } }
//@available(*, unavailable, message: "Use optional.guard(p).flatMap(f)")
//public func when<T, U>(_ p: @escaping (T) -> Bool, _ f: @escaping (T) -> U?) -> (T?) -> U? { { x in x.guard(p).flatMap(f) } }
