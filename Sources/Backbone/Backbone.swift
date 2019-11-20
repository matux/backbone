import Swift

/// # Style
///
/// ## 80 columns
///
/// We respect the fact that humans aren't good at scanning more than about 60
/// columns, 80 being the upper limit of what can be scanned properly. And yes,
/// when you write 120 column line, 𝑖𝑡'𝑠 𝑛𝑜𝑡 𝑟𝑒𝑎𝑑𝑎𝑏𝑙𝑒. This is not fashionable
/// retro-style, 𝑤𝑒 are retro because we have not had a chance to evolve to deal
/// with large screen capacities.
/// Web design, newspapers, books, magazines. It turns out humans have a
/// particular way of reading and it's not the way most programmers think it is.
///
/// # Types
///
/// ## Type correspondence
///
/// Swift's algebraic type system correspondence reference table.
///
///     Swift   ·   Algebra    ·    Notes
///     Never       0               bottom
///     ()          1               unit
///     (A, B)      𝒂 × 𝒃           multiplication
///     enum<A, B>  𝒂 + 𝒃           addition
///     (T) -> U    Uᵀ              exponentiation
///     [A]         1 + 𝒂 + 𝒂² + 𝒂ⁿ infinite series
///     zip([],[])  Δ/ΔT(1+𝒂+𝒂²+𝒂ⁿ) derivative
private enum Style { }

// MARK: - Operators
// MARK: ─╴Precedence Groups

//                               ┏╌╌┓
//              Assignment       │ʀ₋│  { associativity: right assignment: true ... }
///             FunctionArrow    │ʀ₀│  { associativity: right ... }
precedencegroup FunctionMap   /**┃ʟ₁┃*/{ associativity: left  higherThan: FunctionArrowPrecedence lowerThan: TernaryPrecedence }
precedencegroup Composition   /**┃ʀ₁┃*/{ associativity: right higherThan: FunctionMap             lowerThan: TernaryPrecedence }
//              Ternary          │ʀ₁│  { associativity: right ... }
//              Default          │ ₂│  { associativity: none  ... }
///             Disjunction      │ʟ₂│  { associativity: left  ... }
///             Conjunction      │ʟ₃│  { associativity: left  ... }
///             Comparison       │ ₄│  { associativity: none  ... }
///             NilCoalescing    │ʀ₄│  { associativity: right ... }
//              Casting          │ ₅│  { associativity: none  ... }
//              RangeFormation   │ ₅│  { associativity: none  ... }
precedencegroup Concatenation /**┃ʀ₅┃*/{ associativity: right higherThan: RangeFormationPrecedence lowerThan: AdditionPrecedence }
///             Addition         │ʟ₆│  { associativity: left  ... }
///             Multiplication   │ʟ₇│  { associativity: left  ... }
precedencegroup Exponentiation/**┃ʀ₈┃*/{ associativity: right higherThan: MultiplicationPrecedence lowerThan: BitwiseShiftPrecedence }
//              BitwiseShift     │ ₉│  { associativity: none  ... }
//                               ┗╌╌┛

// MARK: — Math

prefix operator ∑ // Sum, alt+w
prefix operator ∏ // Product, alt+shift+p

// MARK: — Higher-order

infix operator =>  : FunctionMap
infix operator =>> : FunctionMap
infix operator >>> : Composition
infix operator <<< : Composition
infix operator >=> : Composition
infix operator <=< : Composition
infix operator ++  : Concatenation
infix operator •   : Exponentiation // U+2218

// MARK: — High-fructose

prefix  operator ^ // Keypath as function, `^\.path`
prefix  operator * // Indirection/dereference operator.
postfix operator & // Curry/Partial application

// MARK: – Ref table

///** op   name     signature                      definition            imperative approximate**
///  `=> ` map     `(A, A -> B) -> B`             `x => f => g => h`    `{ (x: T) -> U in h(g(f(x))) }(x)`
///  `=>>` tap     `(A, A -> ()) -> A`            `x =>> f =>> g =>> h` `{ (x: T) -> T in h(g(f(x))); return x }(x)`
///  `>=>` chain   `(B -> C?,A -> B?) -> A -> C?` `x >>= f >=> g >=> h` `{ (x: M<T>) -> M<U> in x.flatMap(f).flatMap(g).flatMap(h) }(mx)`
///  `>>>` pipe    `(B -> C, A -> B) -> A -> C)`  `x >>= f >>> g >>> h` `{ (x: T) -> U in h(g(f(x))) }(x)`
///  ` • ` compose `(A -> B, B -> C) -> A -> C`   `(f • g • h)(x)`      `{ (x: T) -> U in f(g(h(x))) }(x)`
///  ` ⧺ ` cat     `([A], `[A]|A`) -> [A]`        `[xs] ++ `[ys]|y      `[xs] + [ys]` | `[xs].appending(y)`

// MARK: ╴Sig table
///
///```
///  `set` :: (A -> B)     -> S         ->  T
///  `fst` :: (A -> B)     -> ❬A, C❭    -> A ⊢  ⊦ ⊧  B, C
///  `snd` :: (C -> D)     -> ❬A, C❭    -> ❬A, D❭
/// `with` :: (A)          -> (A -> B)  ->  B
///  `map` :: (A -> B)     -> A         ->  B
/// `fmap` :: (A -> B)     -> <A>       -> <B>
///   `ap` :: <A -> B>     -> <A>       -> <B>
/// `bind` :: (A -> <B>)   -> <A>       -> <B>
///  `zap` :: <A -> B>     -> <A>       -> <B>
///  `zip` ::                 ❬<A>,<B>❭ -> ❬<A,B>❭
/// `zipW` :: (❬A,B❭ -> C) -> ❬<A>,<B>❭ -> <C>
/// ```
/// lml <J>
///
/// - Note:
/// __<𝑀>__ denotes a type M wrapped in a monad (eg. Optional, Array, Result,
///         etc.)
///__aka.__ `ap`   ⟺ `apply`
///         `bind` ⟺ `flatMap`
///         `zipW` ⟺ `zip(with:)`
///         `fmap` ⟺ `some Monad<Wrapped>.map`, _eg._ `Optional<String>.map`
private enum sigtable {}
// MARK: - Base Higher-order

/// The null function. A noop.
@_transparent
public func noop() {}

/// The void function. Discards its argument.
///
/// The generic parameter of an explicitly ignored parameter in the function
/// signature are denoted by the middle dot (`·`), ⸢⌥⇧9⸥
///
///     void :: Functor f => f a -> f ()
///     void x = () <$ x
@inlinable
public func void<·>(_: ·) -> () { }

/// The void function. Discards its argument.
///
/// A monomorphic variant of `void`.
@inlinable
public func discard(_: Any) -> () { }

//@inlinable
//public func discard<·, ··>(_: ·, _: ··) -> () { }

/// The identity function. Returns its argument.
@inlinable
public func id<T>(_ x: T) -> T { x }

/// The constant function. Returns a unary function fixed on its argument `x`
/// that discards any arguments, returning the fixed argument.
///
/// The Konstanzfunktion, as referred to by its discoverer, Herr Schönfinkel.
///
/// - Parameter x: A value.
/// - Returns: The function constant on `x`.
@inlinable
public func const<T, ·>(_ x: T) -> (·) -> T { { _ in x } }

/// A variant of `const` for nullary functions.
@inlinable
public func const<T>(_ x: T) -> () -> T { { () in x } }

/// Returns a series of **chained** **unary** functions that will collect
/// **each** argument of the given function `f` in order, deferring its
/// invocation until all arguments are collected.
///
/// The first function takes the first argument, stores it and returns a
/// function that takes the second argument and returns the result of calling
/// the wrapped function with both arguments.
///
/// See [Curry.swift][1] for more overloads.
///
/// - Parameters:
///   - f: A binary function.
///   - x: The binary function's first argument.
///   - y: The binary function's second argument.
/// - Returns: A composition of two pure functions.
/// - SeeAlso: [Curry.swift][1]
///
/// [1]: x-source-tag://Curry.swift
@inlinable
public func curry<A, B, Result>(
  _ f: @escaping ((A, B)) -> Result
) -> (A) -> (B) -> Result {
  { a in { b in f((a, b)) } }
}

/// Returns a binary function that calls 𝑓 passing its arguments in reverse
/// order.
///
/// `flip(λ)` will take its arguments in the reverse order of λ as denoted
/// by `flip(λ)(x, y) → λ(y, x)`. For example:
///
///       1> flip(+)("hello", "world")
///     $R0: String = "worldhello"
///
/// See [Flip.swift][1] for more overloads.
///
/// - Parameter λ: A binary function.
/// - Returns: A binary function taking the same arguments in reverse order.
/// - SeeAlso: [Flip.swift][1]
///
/// [1]: x-source-tag://Flip.swift
@inlinable
public func flip<A, B, R>(
  _ λ: @escaping ((A, B)) -> R
) -> (B, A) -> R {
  { b, a in λ((a, b)) }
}

/// A nominal type that represents `nil` values. A trivial generalization
/// of `_OptionalNilComparisonType`.
///
/// `Nil` can enable pattern matching and equality operations against `nil`
/// for any `ExpressibleByNilLiteral` even if such type isn't `Equatable`.
public typealias Nil = _OptionalNilComparisonType

extension Nil: SelfAware { }

// MARK: - Map

/// Pipe the value on the left-hand side to the function on the right-hand side.
///
/// A reverse application operator providing notational convenience, analogous
/// to the [shell pipe](https://en.wikipedia.org/wiki/Pipeline_(Unix)).
///
///      x => ƒ₁ => ƒ₂ => ƒ₃      x => ƒ₁ >>> ƒ₂ >>> ƒ₃
///     └───────┘     │     │    │    │      └─────────┘
///     └─────────────┘     │    │    └────────────────┘
///     └───────────────────┘    └─────────────────────┘
///
/// - Note: Precedence is higher than the application operator allowing both
///   operators to be nested.
///
/// - Note: Use a function parameter names to disambiguate between functions
///   with the same name and signature:
///
///       4 => "some text".prefix
///       // ambiguous: prefix(upTo:) or prefix(through:)
///
///       4 => "some text".prefix(upTo:)
///       // not ambiguous
///
/// - Parameters:
///   - value: A value to map into the `transform` function.
///   - transform: A function that takes `T` and returns a value of the same
///     or a different type.
/// - Returns: The result of applying `transform` to `value`.
@_transparent
public func => <T, U>(value: T, transform: (T) -> U) -> U {
  return transform(value)
}

/// Evaluates a closure expecting void when invoked, returning its result.
@inlinable
public func map<U>(
  _ f: @escaping (()) -> U
) -> () -> U {
  return { f(()) }
}

/// Returns a function that applies the given function to values.
@inlinable
public func map<T, U>(
  _ f: @escaping (T) -> U
) -> (T) -> U {
  return { x in f(x) }
}

/// Returns a function that applies the given function to a 2-tuple, or "pair".
@inlinable
public func map<T, Tʼ, Result>(
  _ f: @escaping ((T, Tʼ)) -> Result
) -> (T, Tʼ) -> Result {
  return { x, y in f((x, y)) }
}

/// Returns a function that applies the given function `f` to a 3-tuple.
@inlinable
public func map<T, Tʼ, Tˮ, Result>(
  _ f: @escaping ((T, Tʼ, Tˮ)) -> Result
) -> (T, Tʼ, Tˮ) -> Result {
  return { x, y, z in f((x, y, z)) }
}

/// Returns a function that applies the given nested function to a value.
///
/// Adds support to nullary [static instance methods][1] to `map`.
///
/// - Parameter f: A function that returns a nullary function of type `() -> U`
///   that will return the expected result once called.
///
/// ### See also
/// - [Swift Evolution #42][2] · _Flattening [...] unapplied method references._
///
/// [1]: https://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
/// [2]: https://github.com/apple/swift-evolution/blob/master/proposals/0042-flatten-method-types.md
@inlinable
public func map<T, U>(
  _ f: @escaping (T) -> () -> U
  ) -> (T) -> U {
  return { x in f(x)() }
}

// MARK: - With

/// Returns a function that maps the given values into a given function.
@inlinable
public func with<T, U>(_ x: T, do f: (T) -> U) -> U {
  return f(x)
}

/// Returns a function that maps the given values into a given function.
@inlinable
public func with<T, U>(_ x: T) -> ((T) -> U) -> U {
  return { f in f(x) }
}

/// Splats a tuple on a function's arguments.
///
/// - Parameter Π: The tuple. Π alludes to the product-type.
@inlinable
public func splat<T, Tʹ, U>(
  _ Π: (T, Tʹ)
) -> (_ f: (T, Tʹ) -> U) -> U {
  return { f in f(Π.0, Π.1) }
}

// MARK: ─╴ Invariant

/// Returns a function that will evaluate the given closure passing any value
/// it is given as a parameter, then returning the value unchanged.
///
/// Use the `tap` method when you want to temporarily split a composition
/// chain to evaluate a closure only for its side-effects, eg. print debugging
/// information to the console.
///
/// - Note: In *nix, Ruby and some FP libraries, "tap" is the co-opted term
///   for this operation, shortened from the piping technique known as
///   [Hot tapping](https://en.wikipedia.org/wiki/Hot_tapping).
/// - Note: In *nix shells, it is known as the [tee command](https://en.wikipedia.org/wiki/Tee_(command))
///   and it is named after the T-splitter used in plumbing.
///
/// - Parameters:
///   - a: A value.
///   - eff: A function to take `a` and return void.
/// - Returns: The original value `a`.
public func tap<T>(
  _ sink: @escaping (T) -> ()
) -> (T) -> T {
  return { const($0)(sink($0)) }
}

public func tap<T>(
  _ sink: @escaping () -> ()
) -> (T) -> T {
  return { const($0)(sink()) }
}

/// Returns the given value after evaluates the given closure only for its
/// side-effects, passing the value as a parameter, discarding the result and
/// returning the original value.
@_transparent
public func =>> <T>(value: T, perform: (T) throws -> ()) rethrows -> T {
  return const(value)(try perform(value))
}

// MARK: ─╴ Transform

// MARK: ─╴ Mutate

/// Mutates a value in-place.
///
/// - Parameters:
///   - x: A value.
///   - transmute: An effectful function to take an `inout` copy of `x`.
/// - Returns: The mutated copy.
@inlinable
@discardableResult
public func mutate<T>(
  _ x: inout T,
  with transform: (inout T) throws -> ()
) rethrows -> T {
  try transform(&x)
  return x
}

/// Returns a **copy** of the given value mutated by the given closure.
///
/// - Parameters:
///   - x: A value.
///   - mutator: A closure that takes `inout` instances of `T`.
/// - Returns: The mutated copy.
@inlinable
public func mutating<T>(
  _ x: T,
  with mutator: (inout T) throws -> ()
) rethrows -> T {
  var x = x
  return try mutate(&x, with: mutator)
}

/// Returns a copy of the given value transformed by the given closure.
///
/// - Parameter mutate: An effectful function to take an `inout` copy of `T`.
/// - Returns: The transformed copy.
@inlinable
public func mutating<T>(
  _ transform: @escaping (inout T) -> ()
) -> (T) -> T {
  return { x in mutating(x, with: transform) }
}

// MARK: - Tuple

public func first <Fst, Snd>(_ Π: (Fst, Snd)) -> Fst { Π.0 }
public func second<Fst, Snd>(_ Π: (Fst, Snd)) -> Snd { Π.1 }

public func first <Fst, Snd, Trd>(_ Π: (Fst, Snd, Trd)) -> Fst { Π.0 }
public func second<Fst, Snd, Trd>(_ Π: (Fst, Snd, Trd)) -> Snd { Π.1 }
public func third <Fst, Snd, Trd>(_ Π: (Fst, Snd, Trd)) -> Trd { Π.2 }

public func duplicate<T>(_ x: T) -> (T, T) { (x, x) }
public func triplicate<T>(_ x: T) -> (T, T, T) { (x, x, x) }

public func swap<A, B>(_ a: A, _ b: B) -> (B, A) { (b, a) }

/// Returns a triple by flattening the nested pair in the second component of
/// the given pair.
@inlinable
public func flatten3<A, B, C>(_ Π: (A, (B, C))) -> (A, B, C) {
  (first(Π), (first • second)(Π), (second • second)(Π))
}

/// Returns a triple by flattening the nested pair in the first component of
/// the given pair.
@inlinable
public func flatten3<A, B, C>(_ Π: ((A, B), C)) -> (A, B, C) {
  ((first • first)(Π), (second • first)(Π), (second)(Π))
}

/// Applies the given function to each component of a pair.
@inlinable
public func both<T, U>(_ f: @escaping (T) -> U) -> (T, T) -> (U, U) {
  join(cross)(f)
}

// instance Monoid a => Monad ((,) a) where
//   (>>=) :: (a, a0) -> (a0 -> (a, b)) -> (a, b)
//   (a, c) >>= k = case k a of (v, b) -> (u <> v, b)
public func flatMap<A: Monoid, B, Aʼ>(
  _ transform: @escaping (Aʼ) -> (A, B)
) -> (A, Aʼ) -> (A, B) {
  return { a, aʼ in transform(aʼ) => { aʼ, b in (a ++ aʼ, b) } }
}

// MARK: · Zip2

/// Elemental pair formation.
@_transparent
public func zip<A, B>(_ a: A, b: B) -> (A, B) {
  (a, b)
}

@inlinable
public func zip<A, B>(_ a: A, _: Unbound$0) -> (B) -> (A, B) {
  return { b in (a, b) }
}

@inlinable
public func zip<A, B>(_: Unbound$0, _ b: B) -> (A) -> (A, B) {
  return { a in (a, b) }
}

@inlinable
public func zip<A, B, C>(with f: @escaping ((A, B)) -> C) -> (A, B) -> C {
  return map(f • zip)
}

// MARK: · Zip3

public func zip3<A, B, C, D>(
  with f: @escaping ((A, B, C)) -> D
) -> (A, B, C) -> D {
  return map(map(f) • zip3)
}

public func zip3<A, B, C>(_ a: A, _ b: B, _ c: C) -> (A, B, C) {
  return (a, b, c)
}

public func zip3<A, B, C>(_: Unbound$0, _ b: B, _ c: C) -> (A) -> (A, B, C) {
  return { a in (a, b, c) }
}

public func zip3<A, B, C>(_ a: A, _: Unbound$0, _ c: C) -> (B) -> (A, B, C) {
  return { b in (a, b, c) }
}

public func zip3<A, B, C>(_ a: A, _ b: B, _: Unbound$0) -> (C) -> (A, B, C) {
  return { c in (a, b, c) }
}

public func zip3<A, B, C>(_ a: A, _: Unbound$0, _: Unbound$1) -> (B, C) -> (A, B, C) {
  return { b, c in (a, b, c) }
}

public func zip3<A, B, C>(_: Unbound$0, _ b: B, _: Unbound$1) -> (A, C) -> (A, B, C) {
  return { a, c in (a, b, c) }
}

public func zip3<A, B, C>(_: Unbound$0, _: Unbound$1, _ c: C) -> (A, B) -> (A, B, C) {
  return { a, b in (a, b, c) }
}

// MARK: - Arrow

// An Arrow is a structure that contains a function and that has a bunch of
// tiny helper functions to connect it to other functions in order to create
// computations that are type-safe, have no side-effects,
// and are inherently testable by sticking little functions together to
// create a big one, like if they were a bunch of fucking legos.
//
// The cool thing is that these connections are mathematically sound and can be
// reasoned in familiar equational ways, which makes them highly modular,
// predictable, and testable, able to be understood, used and debugged across
// different programming languages, problem domains, even human disciplines,
// while guaranteeing the compatibility only the universal language that is
// mathematics can only offer.
//
// You may be wondering what concrete things will you be able to do with such
// an awesome amount of power, wonder no more, because you'll finally be able
// to answer questions like: Given two functions, `f` and `g`, what would be
// the result of adding `f + g`? What about multiplication? What does `f AND g`,
// `f OR g` mean?
//
// Ain't that neat?! Huh—Uh? Where did everybody go?

/// Evaluates the given closure when the function `f` is applied, passing the
/// result value as a parameter.
///
/// A functor defined on functions `(A) -> B` is [function composition][1].
///
/// - Parameters:
///   - f: The outer function.
///   - g: The inner function.
/// - Returns: A function composing `f` and `g`.
/// ### SeeAlso:
///   - [•][x-source-tag://Category.•]
///
/// [1]: https://en.wikipedia.org/wiki/Function_composition
@_transparent
@inlinable
public func map<Arg, Wrapped, U>(
  transform: @escaping (Wrapped) -> U
) -> (_ f: @escaping (Arg) -> Wrapped
) -> (Arg) -> U {
    return curry(•)(transform) // { f in transform • f }
}

/// (`<*>`): The applicative binary operation on bare functions, where one
/// morphism (`g`) acts as the lifting functor on `A` that maps values into
/// the function "wrapped" in the "functor"-function `f`.
@inlinable
public func apply <A, B, C>(
  _ f: @escaping (A) -> (B) -> C,
  _ g: @escaping (A) -> B
) -> (A) -> C {
  return { a in f(a)(g(a)) }
}

public func flatMap<A, B, C>(
  _ f: @escaping (B) -> (A) -> C,
  _ g: @escaping (A) -> B
) -> (A) -> C {
  return { a in f(g(a))(a) }
}

/// Returns the result of mapping the equivalent of a join operation on nested
/// Sequences or nested Optionals but when defined on Functions.
public func join<A, B>(
  _ f: @escaping (A, A) -> B
) -> (A) -> B {
  return f • duplicate
}

// MARK: · Category

/// Returns a new function composing two functions by passing the output of the
/// inner function `g` to the input of the outer function `f`.
///
/// Right-to-left composition, although seemingly unintuitive, it is the
/// essence of declarative code:
///
///     let totalPoints = sum • map(Point.init) • filter(isValid)
///     // let the total points be the sum of the points that are valid.
///
/// As opposed to a set of instructions:
///
///     let totalPoints = { entries in entries.filter(isValid).map(Point.init).sum() }
///     // let "totalPoints" take entries, keep the ones that are valid,
///     // transform them to points and return the sum."
///
/// ### See Also
///   - Function composition at [Wikipedia][1]
///
/// - Parameters:
///   - f: The outer function.
///   - g: The inner function.
/// - Returns: A function composing `f` and `g`.
/// - Tag: Category.•
///
/// [1]: https://en.wikipedia.org/wiki/Function_composition
@_transparent
public func • <T, U, Result>(
  f: @escaping (U) -> Result,
  g: @escaping (T) -> U
) -> (T) -> Result {
  { x in f(g(x)) }
}

/// Returns a new function composing two **throwing** partial functions.
///
/// Composes two partial functions `try`ing to pass the output of the inner
/// partial function `g` to the input of the outer partial function `f` or
/// throwing if `f` or `g` `throws`.
public func • <T, U, Result>(
  f: @escaping (U) throws -> Result,
  g: @escaping (T) throws -> U
) -> (T) throws -> Result {
  { x in try f(g(x)) }
}

infix  operator •! : Exponentiation

/// Returns a new function composing two `nonescaping` functions.
///
/// - Important: This style of composition **cannot** be used to generate new
///   functions, only 
public func •! <T, U, Result>(
  f: (U) -> Result,
  g: (T) -> U
) -> (T) -> Result {
  withoutActuallyEscaping(f) { f in
    withoutActuallyEscaping(g) { g in
      f • g
    }
  }
}


/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func >>> <T, U, Result>(
  f: @escaping (T) -> U,
  g: @escaping (U) -> Result
) -> (T) -> Result {
  { x in g(f(x)) }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `g` to the input of the outer function `f`.
@_transparent
public func <<< <T, U, Result>(
  f: @escaping (U) -> Result,
  g: @escaping (T) -> U
) -> (T) -> Result {
  { x in f(g(x)) }
}

// MARK: Composition overloads

// Unfortunate overloads required to circumvent Swift's tuple design issues.

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func >>> <T, Tʹ, U, Result>(
  f: @escaping ((T, Tʹ)) -> U,
  g: @escaping (U) -> Result
) -> (T, Tʹ) -> Result {
  return { x, y in g(f((x, y))) }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `g` to the input of the outer function `f`.
@_transparent
public func <<< <T, Tʹ, U, Result>(
  f: @escaping (U) -> Result,
  g: @escaping ((T, Tʹ)) -> U
) -> (T, Tʹ) -> Result {
  return { x, y in f(g((x, y))) }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func >>> <U, Result>(
  f: @escaping () -> U,
  g: @escaping (U) -> Result
) -> () -> Result {
  return { g(f()) }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func <<< <U, Result>(
  f: @escaping () -> U,
  g: @escaping (U) -> Result
) -> () -> Result {
  return { g(f()) }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func >>> (
  f: @escaping () -> (),
  g: @escaping () -> ()
) -> () -> () {
  return { f(); g() }
}

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
@_transparent
public func <<< (
  f: @escaping () -> (),
  g: @escaping () -> ()
) -> () -> () {
  return { f(); g() }
}

@_transparent
public func <<< (
  f: @escaping () -> () -> (),
  g: @escaping (() -> ()) -> ()
) -> () -> () {
  return { g(f()) }
}

// MARK: ─ Binary composition

/// Returns the result of a binary function `ƒ` applied to the result of
/// `g` applied to each one of the components in a given a pair of values of
/// type `A`
///
/// This is just `map` applied to binary functions instead of values, of which
/// its resulting signature allows for one and only one possible operation:
/// function composition.
///
/// Use `on` to transform two inputs and map them into a combining function:
///
///     on(+, g) = { x, y in g(x) + g(y) }
///     combine′on′g = { x, y in combine(g(x), g(y)) }
///
/// Use `on` to compare structures by their properties:
///
///     let arr = [(2, "Second"), (1, "First"), (4, "Fourth"), (3, "Third")]
///         .sorted(by: (<)′on′fst)
///     print(arr)
///     // Prints "[(1, "First"), (2, "Second"), (3, "Third"), (4, "Fourth")]"
///
/// ## Haskell definition
///     on :: (b -> b -> c) -> (a -> b) -> a -> a -> c
///     (.*.) `on` g = \x y -> g x .*. g y
///     infixl 0 `on`
///
/// - Parameters:
///     ƒ: A function taking two values of type `B`.
///     g: A function taking values of type `A`.
///     a: A a pair of values of type `A`.
/// - Returns: The result of `ƒ` applied to the result of `g` applied to `a`.
public func compose<Root, Transient, Transformed>(
  _ f: @escaping (Transient, Transient) -> Transformed,
  on g: @escaping (Root) -> Transient
) -> (Root, Root) -> Transformed {
  return { root, root´ in f(g(root), g(root´)) } // ƒ • (g *** g)
}

// Variant of `compose(_:on:)` for curried functions.
public func compose<Root, Transient, Transformed>(
  _ f: @escaping (Transient) -> (Transient) -> Transformed,
  on g: @escaping (Root) -> Transient
) -> (Root) -> (Root) -> Transformed {
  return { root in { root´ in f(g(root))(g(root´)) } }
}

/// reduce(0, combining(^\count, by: +)
public func combining<Root, Transient, Result>(
  _ f: @escaping (Root) -> Transient,
  by g: @escaping (Transient, Transient) -> Result
) -> (Transient, Root) -> Result {
  return { trans, root in g(trans, f(root)) }
}

// MARK: · Kleisli

/// Returns a new function composing two functions by passing the output of the
/// inner function `f` to the input of the outer function `g`.
public func >=> <A, B, C, D>(
  f: @escaping (A) -> (D) -> B,
  g: @escaping (B) -> (D) -> C
) -> (A) -> (D) -> C {
  return { a in flatMap(g, f(a)) }
}

// MARK: · Arrow Category

// ? releative complement (aka. (∖), (-))
// ? symmetric difference (aka. (∆), (^) or (⨁))

/// (`&&&`): Returns a polymorphic function that will pass any given value to
/// the two initial functions.
///
/// Use this function to "fan-out" values to functions, wherein a single input
/// (the argument) is "spread out" to several consumers (the functions):
///
/// ```swift
/// a => merge(f, g) = (f(a), g(a))
///
///      ┎─╼ f a -> b ╾─╖
///  a ━━┫              ╠═╸(b, c)
///      ┖─╼ g a -> c ╾─╜
/// ```
///
/// ### Example
///
///     let dict: [String: String]? = ...
///     let pair = dict.map(spread(^"someKey", ^"anotherKey"))
///     // pair: (String, String)? = ("valueOfSomeKey", "valueOfAnotherKey")
///
/// ### Definition
///
///     (&&&) :: Arrow Λ => Λ a b -> Λ a b' -> Λ a (b,b')
///     f &&& g = arr(\b -> (b, b)) >>> f *** g
///
/// - Parameters:
///   - f: A polymorphic function over `T`.
///   - g: A polymorphic function over `T`.
/// - Returns: A polymorphic function over `T` that fans out its input between
///   the given functions.
/// - SeeAlso:
///   https://en.wikipedia.org/wiki/Distributive_property
///   http://hackage.haskell.org/package/distributive-0.6/docs/Data-Distributive.html
@inlinable
public func fork<A, B, C>( // intersect/factorize (ie. (∩), (&) or (AND))
  _ f: @escaping (A) -> B,
  _ g: @escaping (A) -> C
) -> (A) -> (B, C) { // 𝐴 × 𝐵 + 𝐴 × 𝐶 => 𝐴 × (𝐵 + 𝐶)
  return duplicate >>> cross(f, g)
}

/// (`***`): Returns a tuple with the result of applying the first function to
/// the first component in the given tuple and the second function to the second
/// component in the given pair.
///
/// This is effectively the mathematical result of multiplying two functions,
/// which results in the covariant mapping over both functions at the same time.
///
///     (***) :: (a → b) → (c → d) → p a c → p b d
///     (***) f g = first f . second g
@inlinable
public func cross<A, B, C, D>( // cartesian/cross product (ie. (×) or (*))
  _ f: @escaping (A) -> B,
  _ g: @escaping (C) -> D
) -> (A, C) -> (B, D) {
  return { a, c in (f(a), g(c)) }
}

/// (`***`): Returns a tuple with the result of applying the first function to
/// the first component in the given tuple and the second function to the second
/// component in the given pair.
///
/// This is effectively the mathematical result of multiplying two functions,
/// which results in the covariant mapping over both functions at the same time.
///
///     (***) :: (a → b) → (c → d) → p a c → p b d
///     (***) f g = first f . second g
@inlinable
public func cross<A, B, C, D, E, F>( // cartesian/cross product (ie. (×) or (*))
  _ f: @escaping (A) -> B,
  _ g: @escaping (C) -> D,
  _ h: @escaping (E) -> F
) -> (A, C, E) -> (B, D, F) {
  return { a, c, e in (f(a), g(c), h(e)) }
}

// MARK: ·  Choice

/// (`|||`) Fanin: Merge the input passing it to the type-corresponding arrow.
///
/// A mathematical representation of choice within a computation.
/// ```
/// f ||| g
///          ┌──╸f a -> c'╺─┒
/// Either(a + b)       (c'+c")?╺─╴c
///          └──╸g b -> c"╺─┚
/// ```
public func either<A, B, C>( // union/factorize (ie. (∪), (|) or (OR))
  _ f: @escaping (A) -> C,
  or g: @escaping (B) -> C
) -> (Either<A, B>) -> C {
  return { switch $0 {
    case let .left(x): return f(x)
    case let .right(y): return g(y)
  } }
}

/// (`+++`) Returns a new function over the given argument arrows `f` and `g`
/// that multiplexes any givenm coproduct of the domains of `f` and `g`
/// yielding the transformed result as the coproduct of `f` and `g`'s codomains.
///
/// This is the dual notion of the product function (`***`), giving rise to
/// distributive coproducts as arrows encoded with choice.
///
/// - Note: This is a categorical generalization of a sum when  operation on arrows,operation "multiplexing", "fan-in",
///   "merge", "combine", "coproduct", "sum" in arithmetic, operation is usually referred as "dij
///
/// ```
/// f +++ g
///          ┌──╸f a -> b╺──┒
/// Either(a + c)        (b + d)
///          └──╸g c -> d╺──┚
/// ```
@inlinable
public func choose<A, B, C, D>( // disjoint union (ie. (⊔) or (+))
  _ f: @escaping (A) -> B,
  _ g: @escaping (C) -> D
) -> (Either<A, C>) -> (Either<B, D>) {
  return either(Either.left • f, or: Either.right • g) // Left • f ||| Right • g
}

// MARK: · Profunctor

/// Maps contravariantly over the first argument and covariantly over
/// the second.
///
///     dimap ∷ (b ⟶ a) ⟶ (c ⟶ d) ⟶ p a c ⟶ p b d
///     dimap f g ≡ lmap f • rmap g
///     dimap f g h = g • h • f
@inlinable
public func dimap<A, B, C, D>(
    _ f: @escaping (B) -> A,
    _ g: @escaping (C) -> D)
-> (_ h: @escaping (A) -> C)
-> (B) -> D {
  return { h in g • h • f } // g(h(f(b))) or b => f >>> h >>> g
}

// MARK: · Strong

/// Maps covariantly over the fst component in a pair.
///
///     fst :: (a → b) → (a, c) → (b, c)
///     fst f ≡ bimap f id
@inlinable
public func mapFst<A, Aʹ, B>(_ f: @escaping (A) -> Aʹ) -> ((A, B)) -> (Aʹ, B) {
  return { (f($0.0), $0.1) }
}

/// Maps covariantly over the snd component in a pair.
///
///     snd :: (b → c) → (a, b) → (a, c)
///     snd g ≡ split id
@inlinable
public func mapSnd<A, B, Bʹ>(_ g: @escaping (B) -> Bʹ) -> ((A, B)) -> (A, Bʹ) {
  return { ($0.0, g($0.1)) }
}

/// Maps covariantly over the first component in a 3-tuple.
///
///     first :: (a → b) → (a, c) → (b, c)
///     first f ≡ bimap f id
@inlinable
public func mapFst<A, Aʹ, B, C>(
  _ f: @escaping (A) -> Aʹ
) -> ((A, B, C)) -> (Aʹ, B, C) {
  return { (f($0.0), $0.1, $0.2) } //cross(f, id, id)
}

/// Maps covariantly over the second component in a 3-tuple.
///
///     snd :: (b → c) → (a, b) → (a, c)
///     snd g ≡ split id
@inlinable
public func mapSnd<A, B, Bʹ, C>(
  _ g: @escaping (B) -> Bʹ
) -> ((A, B, C)) -> (A, Bʹ, C) {
  return { ($0.0, g($0.1), $0.2) } //cross(id, g, id)
}

/// Maps covariantly over the third component in a 3-tuple.
///
///     snd :: (b → c) → (a, b) → (a, c)
///     snd g ≡ split id
@inlinable
public func mapTrd<A, B, C, Cʹ>(
  _ h: @escaping (C) -> Cʹ
) -> ((A, B, C)) -> (A, B, Cʹ) {
  return { ($0.0, $0.1, h($0.2)) } //cross(id, id, h)
}

// MARK: - Transducers

/// Lifts a morphism from `A` to `B` to a transducer from `B` to `A`.
///
///     let xs = Array(1...100)
///     xs.reduce(into: [], Array.append
///       >>> filtering(isPrime)
///       >>> mapping(increment)
///       >>> mapping(square)
public func mapping<T, T´, U>(
    _ f: @escaping (T) -> T´)
-> (_ reduce: @escaping (U, T´) -> U)
-> (U, T) -> U {
  return { reduce in { result, x in
    reduce(result, f(x))
  } }
}

/// Lifts a predicate on `A` to a filter transducer.
public func filtering<T, U>(
    _ isIncluded: @escaping (T) -> Bool)
-> (_ reduce: @escaping (_ result: U, _ element: T) -> U)
-> (U, T) -> U {
  return { reduce in { result, element in
    isIncluded(element) ? reduce(result, element) : result
  } }
}

// MARK: - KeyPaths
// MARK: · KeyPaths: Declarative

infix operator ~ : NilCoalescingPrecedence
infix operator .= : NilCoalescingPrecedence
infix operator ∖= : NilCoalescingPrecedence

@inlinable
public func .= <Root, Value>(
  lpath: WritableKeyPath<Root, Value>,
  value: Value
) -> (inout Root) -> () {
  { root in
    var root = root
    root[keyPath: lpath] = value
  }
}

@inlinable
public func ~ <Root, Value>(
  lvalue: WritableKeyPath<Root, Value>,
  rvalue: Value
) -> (Root) -> Root {
  mutating { root in root[keyPath: lvalue] = rvalue }
}

@inlinable
public func .= <Object: AnyObject, Value>(
  property: ReferenceWritableKeyPath<Object, Value>,
  x: Value
) -> (Object) -> () {
  { rootObj in rootObj[keyPath: property] = x }
}

@inlinable
public func .= <Object: AnyObject, Value>(
  lvalue: ReferenceWritableKeyPath<Object, Value>,
  rvalue: KeyPath<Object, Value>
) -> (Object) -> () {
  { rootObj in rootObj[keyPath: lvalue] = rootObj[keyPath: rvalue] }
}

@inlinable
public func ~ <Object: AnyObject, Value>(
  lvalue: ReferenceWritableKeyPath<Object, Value>,
  rvalue: KeyPath<Object, Value>
) -> (Object) -> Object {
  { root in
    root[keyPath: lvalue] = root[keyPath: rvalue]
    return root
  }
}

/// Returns the value associated with the given `KeyPath` on the given `Root`.
///
/// A very turing incomplete implementation of lenses.
@inlinable
public func get<Root, Value>(
  _ path: KeyPath<Root, Value>
) -> (Root) -> Value {
  { root in root[keyPath: path] }
}

@inlinable
public func set<Root, Value>(
  _ path: WritableKeyPath<Root, Value>
) -> (Value) -> (inout Root) -> () {
  { value in path .= value }
}

@inlinable
public func assign<Root, Value>(
  _ value: Value,
  to path: WritableKeyPath<Root, Value>
) -> (inout Root) -> () {
  { root in root[keyPath: path] = value }
}

@inlinable
public func assign<Root, Value>(
  _ value: Value,
  to path: ReferenceWritableKeyPath<Root, Value>
) -> (Root) -> () {
  { root in root[keyPath: path] = value }
}

@inlinable
public func assign<Root, Value>(
  _ rpath: KeyPath<Root, Value>,
  to lpath: ReferenceWritableKeyPath<Root, Value>
) -> (Root) -> () {
  { root in root[keyPath: lpath] = root[keyPath: rpath] }
}

@inlinable
public func over<Root, Value>(
  _ ωkp: WritableKeyPath<Root, Value>
) -> (_ transform: @escaping (Value) -> Value
) -> (Root) -> Root {
  return { λ in duplicate >>> uncurry(curry(~)(ωkp) • λ • get(ωkp)) }
}

// MARK: · KeyPaths: Tupled

@inlinable
public func biset<Root, Value₁, Value₂>(
  _ path₁: WritableKeyPath<Root, Value₁>,
  _ path₂: WritableKeyPath<Root, Value₂>
) -> (Value₁, Value₂) -> (Root) -> Root {
  { (value₁, value₂) in mutating { root in
    root[keyPath: path₁] = value₁
    root[keyPath: path₂] = value₂
  } }
}

// MARK: · KeyPaths: Imperative

@inlinable
public func set<RootObject: AnyObject, Value>(
  _ path: ReferenceWritableKeyPath<RootObject, Value>,
  to value: Value
) -> (RootObject) -> () {
  return path .= value
}

@inlinable
public func over<Root, Value>(
  _ path: WritableKeyPath<Root, Value>,
  with transform: @escaping (Value) -> Value
) -> (Root) -> () {
  return ((path, transform) => uncurry(over)) >>> discard
}

// MARK: · KeyPaths: Prefix

/// Returns a getter function over a given `KeyPath`.
///
/// Returns a function that when applied to a value of the root type for
/// the given `KeyPath`, will return the value stored in the root.
///
/// - Parameter path: A key path.
/// - Returns: A getter function pointing at `path` that takes `Root` values.
@_transparent
public prefix func ^ <Root, Value>(
  path: KeyPath<Root, Value>
) -> (Root) -> Value {
  return get(path)
}

// MARK: · KeyPaths: Subscripts

/// Returns a Dictionary lookup function over a given `Hashable` key.
///
/// Returns a function that when applied to a dictionary with keys of type
/// `Key`, it will return the value associated with the given key or `nil` if
/// no value was found.
///
/// - Parameter key: A `Hashable` value.
/// - Returns: A lookup function for `key` taking `Dictionary` values.
public prefix func ^ <Key: Hashable, Value>(
  _ key: Key
) -> ([Key: Value]) -> Value? {
  return { dict in dict[key] }
}

// MARK: - Sequence

/// Returns a repetition function that will produce an `Array` repeating the
/// given value **eagerly**.
///
/// This is a fliped, curried and eager function, for a lazy variant refer to
/// `repeatElement(_:count:)`.
///
///     let elements = 0.0 / 0 => replicate(10)
///     elements.forEach { print($0, terminator: "") }
///     print("batman!")
///     // prints "nannannannannannannannannannan batman!"
///
/// - Parameters:
///   - n: The number of times to repeat `element`.
///   - element: The element to repeat.
/// - Returns: An `Array` that contains `count` elements that are all
///   `element`.
@inlinable
public func replicate<Element>(
  _ n: Int
) -> (Element) -> [Element] {
  return (1...n).fmap • const
}

/// Returns an infinite lazy sequence with the repeated evaluations of an
/// expression.
///
/// - Parameter expr: An expression.
/// - Returns: return value description
@inlinable
public func iterate<U>(
  _ expr: @escaping @autoclosure () -> U
//) -> LazyMapSequence<Repeated<() -> U>, U>.Iterator {
) -> () -> U {
  var it = repeatElement(expr, count: .max)
    .lazy
    .map { expr in expr() }
    .makeIterator()
  return { it.next()! }
}

/// Returns an infinite lazy sequence with the repeated applications of the
/// given function `f` to a value `x`.
///
/// - Parameters:
///   - f: A function.
///   - x: A generic value.
/// - Returns: return value description
@inlinable
public func iterate<T, U>(
  _ f: @escaping (T) -> U,
  _ x: @autoclosure () -> T
) -> LazyMapSequence<Repeated<(T) -> U>, U>.Iterator {
  return repeatElement(f, count: .max).lazy.map(with(x())).makeIterator()
}

/// Returns an infinite (lazy) sequence of repeated applications of a given
/// function `f` to a given value `x`.
///
/// - Parameter f: A function.
/// - Returns: return value description
@inlinable
public func __iterate<T>(
  _ f: @escaping (T) -> T
) -> (T) -> [T] {
  return { x in [x] ++ __iterate(f)(f(x)) }
}

// MARK: - Recursion

// https://github.com/skynx/y-combinator-notes/blob/master/src/y_combinator_notes/core.clj
// https://gist.github.com/ahoy-jon/85a9b8d4bb300e93126e
// Ymemoizer
// http://matt.might.net/articles/implementation-of-recursive-fixed-point-y-combinator-in-javascript-for-memoization/

/// Returns a recursive function that will repeatedly apply the given closure
/// `ƒ` on any polymorphic argument `T` its provided until the given pedicate
/// `ρ` is satisfied.
///
/// - Complexity: O(n)
@inlinable
public func until<T>(
  _ ρ: @escaping (T) -> Bool,
  _ ƒ: @escaping (T) -> T
) -> (T) -> T {
  return { x in until(x, satisfies: ρ, do: ƒ) }
}

/// Returns a recursive function that will repeatedly apply the given closure
/// `ƒ` on any polymorphic argument `T` its provided until the given pedicate
/// `ρ` is satisfied.
@inlinable
public func until<T>(_ x: T, satisfies ρ: (T) -> Bool, do ƒ: (T) -> T) -> T {
  return ρ(x) ? x : until(ƒ(x), satisfies: ρ, do: ƒ)
}

/// The Y-Combinator returns the least fixed point of a function `ƒ`.
///
/// The least defined `x` such that `ƒ(x) = x`, as denoted by the λ-calculus:
///
///     λf.(λx.f(xx))(λx.f(xx))
///
/// Got it? No? Me neither.
///
/// For example, we can write the factorial function:
///
///     120 = 5! = f,n => (n ≤ 1 -> 1) ∧ (n > 1 -> n • f(n-1))
///
/// using direct recursion:
///
///     let fact = fix { f, n in n ≤ 1 ? 1 : n * f(n-1) }
///     let result = fact(5)
///     // result = 120
///
/// - Parameter f: A function which takes a parameter function, and returns a
///   result function. The result function may recur by calling the parameter
///   function.
@inlinable
public func fix<A, B>(
  _ λ: @escaping (@escaping (A) -> B) -> (A) -> B
) -> (A) -> B {
  return { x in λ(fix(λ))(x) }
}

/// Z Combinator ∎ Strict fixed point combinator, also known as the Applicative
/// Order Y combinator.
///
/// The Z combinator will work in strict languages (also called eager languages,
/// where applicative evaluation order is applied). The Z combinator has the
/// next argument defined explicitly, preventing the expansion of Z g in the
/// right hand side of the definition:
///
///     Z g v = g(Z g) v
///
/// And in λ calculus it is an η-expansion of the Y combinator:
///
///     Z = λf.(λx.f(λv.xxv))(λx.f(λv.xxv))
@inlinable
public func fixS<A, B>(
  _ f: @escaping (@escaping (A) -> B) -> (A) -> B
) -> (A) -> B {
  return
    { (g: @escaping (Any) -> (A) -> B) in f(g(g)) }(
    { (g: @escaping (Any) -> (A) -> B) in f(g(g)) }
      => T.reinterpretCast)
}

/// The `Z·` combinator is only a pointful variant of `Z` that demonstrates
/// the η-expansion of the Y combinator.
///
///     Z⋅ = λf.(λx.f(λv.xxv))(λx.f(λv.xxv))
@inlinable
public func fixS2<A, B>(
  _ f: @escaping (@escaping (A) -> B) -> (A) -> B
) -> (A) -> B {
  return
    { (x: @escaping (Any) -> (A) -> B) in { v in f(x(x))(v) } }(
    { (x: @escaping (Any) -> (A) -> B) in { v in f(x(x))(v) } }
      => T.reinterpretCast)
}

/// Z Combinator ∎ Strict fixed point combinator, also known as the Applicative
/// Order Y combinator.
///
/// The Z combinator will work in strict languages (also called eager languages,
/// where applicative evaluation order is applied). The Z combinator has the
/// next argument defined explicitly, preventing the expansion of Z g in the
/// right hand side of the definition:
///
///     𝑍 𝑔 𝑣 = 𝑔(𝑍 𝑔) 𝑣
///
/// And in λ calculus it is an η-expansion of the Y combinator:
///
///     𝑍 = λ𝑓.(λx.𝑓(λ𝑣.xx𝑣))(λx.𝑓(λ𝑣.xx𝑣))
@inlinable
public func fixZ<A, B>(
  _ λ: @escaping (@escaping (A) -> B) -> (A) -> B
) -> (A) -> B {
  return { λ in λ.recurse(λ) }(
    _Recursion { x in λ { v in x.recurse(x)(v) } })
}

@usableFromInline
internal struct _Recursion<λ> {

  @usableFromInline
  let recurse: (_Recursion<λ>) -> λ

  @usableFromInline
  init(_ recurse: @escaping (_Recursion<λ>) -> λ) {
    self.recurse = recurse
  }
}

// MARK: - Void

/// The uninhabited type is the type that has no types.
///
/// The uninhabited type represents the number 0 in type form. It is an
/// intrinsic part of any type system, whether the type system exposes it or
/// not.
///
/// ### Type hierarchy
///
///         𝐒𝐘𝐌 ⏐ 𝒏  ⏐  𝐓𝐘𝐏𝐄  ⏐  𝐒𝐓𝐃𝐋𝐈𝐁  ⏐  𝐏𝐑𝐄𝐋𝐔𝐃𝐄
///         ⊥ ∀   0     Void     Never      Nothing
///           ∅   1     Unit     ()         Unit
///     ^ ⊻ ⊔ +   2...  Sum      enum       Either
///     | ∨ ∪     3                         These
///     & ∧ ∩ ×   4...  Product  tuple      Tuple
///             ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅
///           𝑆           ℭ𝔬𝔪𝔭𝔬𝔰𝔦𝔱𝔢 𝔗𝔶𝔭𝔢𝔰
///             ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅
///         ⊤ ∃   ∞     Any      Any       Anything
///
/// ⁽¹⁾ `Bool` _type would qualify, but it is a struct._
///
/// ### Nomenclature names
/// 
/// In type theory, it is known as the bottom type, or sometimes as the zero or
/// empty type and denoted as `⟘`, or _falsum_.
///
/// In **functional languages** it is typically represented as the `Void` or
/// `Nothing` type, **imperative languages** prefer not to expose it, instead
/// a _pseudo_-`Unit` type posing as `Void` is exposed type (eg. in C, it is
/// `void`).
///
/// Swift exposes both `Void` types and `Unit` types non-nominally. The `Void`
/// type is called `Never` and `Unit` is called `Void`, a typealias of `()`. If
/// this seems confusing, it may be because you still haven't considered that
/// `Never` has nothing to do with time nor something that cannot end; This
/// should have any confusion removed and replaced by plain indignation.
///
/// - Experiment: Unimplemented functions that could be interesting
///   implementing or at the very least fun, provided you never had it before
///   and don't know what it is.
///
///     Fractal<A> = Int → (A ⨁ Foo<A>)
///     Source<A> = 1 → (1 ⨁ (A ⨂ Source<A>))
///     Transformer<A, B> = (1 ⨁ (A ⨂ (A ⨂ Source<A>)) → (1 ⨁ (B ⨂ Source<B>))
///     Sink<A> = (1 ⨁ (A ⨂ Source<A>)) → IO
///
/// - SeeAlso:
/// [Strange.swift](Strange.swift) for some weird and fun exercises.
/// [Swift Evolution](https://github.com/apple/swift-evolution/blob/master/proposals/0102-noreturn-bottom-type.md)
public typealias Nothing = Never

/// A nominal representation of Swift's structural [Unit-type][1].
///
/// Swift [Unit-type][1] is represented by the `Void` type, and its unique
/// instance as the _0-tuple_ `()`, which is also the type itself, therefore
/// `Void` is the instanced representation of the instance type of the self
/// type instance selved on the typed instance.
///
/// [1]: https://en.wikipedia.org/wiki/Unit_type
public typealias Unit = ()

/// A nominal representation of Swift's structural [Top-type][1].
/// A typealias mirror of `Nothing`.
///
/// [1]: https://en.wikipedia.org/wiki/Top_type
public typealias Anything = Any

/// The verum, a _type-theoretic_ top. A `typealias` of `Any`.
public typealias ꓔ = Anything

/// The empty set, a _type-theoretic_ unit. A `typealias` of `()`.
public typealias Ø = Unit

/// The falsum, a _type-theoretic_ bottom. A `typealias` of `Never`.
public typealias ꓕ = Nothing

/// A typealias to Swift's existential type, `Any`.
///
/// The non-noiminal type `Whatever` is the supertype of all the types in the
/// typeverse. It represents the values whose type is unknown and therefore,
/// could be anything; an Array, a String, a shoe, your dog, your mom, or an
/// Int are examples of what an instance of `Whatever` **is** up to the point of
/// reification. The possibilities are endless within the limits:
///
///     let it: Whatever = 👠 // a shoe
///     print("it is \(type(of: it)), dude. \(type(of: it)).")
///     // prints "it is Whatever, dude. Whatever."
///
/// Or in a declaration:
///
///     func function(with x: Whatever) { ... }
///     // John: What do I pass to the function `function`?
///     // Swift: Just pass Whatever, dude. Whatever.
///
/// You can erase type information from a value by employing the following
/// algebraic algorithm formula:
///
///     let whatever = "whatever"
///     let it: Whatever = whatever
///
public typealias Whatever = Any
public typealias _­ = Whatever

/// Since `Never` values logically don't exist, this witnesses the logical
/// reasoning tool of [ex falso quodlibet](1) (aka. _Principle of explosion_)
/// which states that anything can be derived from a contradiction, including
/// its negation:
///
/// 1. Let "All lemons be yellow".
/// 2. And let "All lemons are yellow" OR "your dumb" be true.
/// 3. Except "Not all lemons are yellow"; therefore:
///   a. your dumb bro.
///   b. And, you explode as a side-effect.
///
/// While in academic circles this is formally known as the **Principle of
/// Explosion**, programmers refer to it as the stop wasting my time principle.
///
/// - Remark: The _absurd function_ also acts as a reminder to **Parmenides**
///   great insight that "Nothing comes from nothing."
///
///   Or, in idiomatic Swift: "Never comes from never."
///
///     Swift™
///     𝑌𝑜𝑢'𝑙𝑙 𝑙𝑒𝑎𝑟𝑛 𝑡𝑜 𝑙𝑜𝑣𝑒 𝑚𝑒.
///
/// - Parameter nothing: An instance of `Never`.
/// - Returns: The result of transforming `nothing` into `T`.
///
/// [1]: https://en.wikipedia.org/wiki/Principle_of_explosion
//public let absurd = { (_: Nothing) -> Whatever in }
#if swift(>=5.1)
public func absurd<T>(_ null: Nothing) -> T { }
#else
public func absurd<T>(_ null: Nothing) -> T { switch null {} }
#endif
