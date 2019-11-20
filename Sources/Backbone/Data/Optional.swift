import Swift

infix operator =? : AssignmentPrecedence // Optional assignment operator.

extension Optional {

  /// Creates an `Optional` from the given `Result`, keeping its `Success` and
  /// discarding its `Failure`.
  @inlinable
  init(_ result: Result<Wrapped, Swift.Error>) {
    switch result {
    case .success(let x):
      self = .some(x)
    case .failure:
      self = .none
    }
  }

  /// Creates a new Optional instance by evaluating a throwing closure,
  /// capturing the returned value, or consuming any thrown error.
  ///
  /// - Parameter body: A throwing closure to evaluate.
  @_transparent
  public init(catching body: () throws -> Wrapped) {
    do {
      self = .some(try body())
    } catch {
      self = .none
    }
  }

  @inlinable
  public func unwrap<Error: Swift.Error>(
    or failure: @autoclosure () throws -> Error
  ) throws -> Wrapped {
    return try self ?? { throw try failure() }()
  }

  /// Assigns `rvalue` to `lvalue` _iff_ `rvalue` is `.some`.
  ///
  /// - Important: Due to a [bug](https://bugs.swift.org/browse/SR-7257) in
  ///   Swift, property observers will get called for the sole reason that
  ///   `lvalue` is being passed as an `inout` value.
  ///
  /// - Parameters
  ///   - lvalue: An inout value of type `Wrapped` to assign `rvalue` to.
  ///   - rvalue: The value to assign to `lvalue` iff the value is not `nil`.
  @_transparent
  public static func =? (lvalue: inout Wrapped, rvalue: Wrapped?) {
    switch rvalue {
    case .some(let rvalue):
      lvalue = rvalue
    case .none:
      ()
     }
  }
}

// MARK: - Empty set

extension Optional where Wrapped == () {

  public static var some: Self {
    return .some(())
  }
}

// MARK: - KeyPath cons

public func ?? <Root, Wrapped>(
  path: KeyPath<Root, Wrapped?>,
  defaultPath: KeyPath<Root, Wrapped>
) -> (Root) -> Wrapped {
  { root in root[keyPath: path] ?? root[keyPath: defaultPath] }
}

public func ?? <Root, Wrapped>(
  path: KeyPath<Root, Wrapped?>,
  defaultValue: @escaping @autoclosure () -> Wrapped
) -> (Root) -> Wrapped {
  { root in root[keyPath: path] ?? defaultValue() }
}

infix operator <??> : NilCoalescingPrecedence

public func <??> <T, Wrapped>(
  transform: @escaping (T) -> Wrapped?,
  defaultValue: @escaping @autoclosure () -> Wrapped
) -> (T) -> Wrapped {
  return { x in transform(x) ?? defaultValue() }
}

public func <??> <T, Wrapped>(
  transform: @escaping (T) -> Wrapped?,
  defaultTransform: @escaping (T) -> Wrapped?
) -> (T) -> Wrapped? {
  return { x in transform(x) ?? defaultTransform(x) }
}

public func <??> <T, Wrapped>(
  transform: @escaping (T) -> Wrapped?,
  defaultTransform: @escaping (T) -> Wrapped
) -> (T) -> Wrapped {
  return { x in transform(x) ?? defaultTransform(x) }
}

// MARK: - Higher-order

extension Optional where Wrapped: AnyOptional {

  /// Returns this nested Optional instance (`Optional<Optional<•>>`),
  /// flattened: `Optional<•>`.
  @inlinable
  public func join() -> Wrapped  {
    switch some {
    case let x?:
      return x
    default:
      return nil
    }
  }
}

extension Optional {

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `fmap` method with a _non-throwiung_ closure that returns a
  /// non-optional value.
  ///
  /// - Note: This is a total variant of Swift's `Optional.map` partial
  ///   throwing function.
  /// - Parameter transform: A non-throwing closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  @inlinable
  public func fmap<Transformed>(
    _ transform: (Wrapped) -> Transformed
  ) -> Transformed? {
    map(transform)
  }

  /// Evaluates the given closure when both the closure and this `Optional`
  /// instance are not `nil`, passing the unwrapped value as a parameter.
  ///
  /// Use `apply` with an optionl closure that returns a non-optional value.
  ///
  /// - Note: This is the applicative functor's operation, and the only one
  ///   missing from Swift's stdlib that belongs to the core functor family:
  ///   - **functor**: `fmap` | `map` | `<•>`
  ///   - **applicative**: `apply` | `ap` | `<*>`
  ///   - **monad**: `bind` | `flatMap` | `>>-`
  /// - Parameter transform: An optional closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If the given closure or this
  ///   instance are `nil`, returns `nil`.
  @inlinable
  public func apply<Transformed>(
    _ transform: ((Wrapped) -> Transformed)?
  ) -> Transformed? {
    transform.flatMap(fmap)
  }

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use `bind` with a _non-throwing_ closure that returns an optional value.
  ///
  /// - Note: This is a total variant of Swift's `Optional.flatMap` partial
  ///   (throwing) function that preserves the original name convention.
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  @inlinable
  public func bind<Transformed>(
    _ transform: (Wrapped) -> Transformed?
  ) -> Transformed? {
    flatMap(transform)
  }

  /// Evaluates the given closure `f` when this `Optional` instance is not
  /// `nil`, passing the unwrapped value as a parameter; or evaluates the
  /// given closure `g`.
  ///
  /// - Note: A Bifunctor. `bimap` is an ad-hoc functorial implementation.
  /// - Parameters
  ///   - f: A closure that takes the unwrapped value of the instance.
  ///   - g: A closure that returns a value.
  /// - Returns: Either the value returned by `f` or the one returned by `g`.
  @inlinable
  public func bimap<U, Uʹ>(
    _ f: @escaping (Wrapped) -> U,
    _ g: @escaping () -> Uʹ
  ) -> Either<U, Uʹ> {
    switch self {
    case .some(let x):
      return .init(f(x))
    case .none:
      return .init(g())
    }
  }

  /// flap :: ∀ fab. Functor f => f (a → b) → a → f b
  /// fab `flap` a = fmap ($ a) fab
  @inlinable
  public func flap<A, B>(
    _ x: A
  ) -> B? where Wrapped == (A) -> B {
    Self.fmap(with(x))(self)
  }

  /// Mutates the inner value iff its .some with a closure in-place.
  @inlinable
  public mutating func alter(_ mutate: (inout Wrapped) -> ()) -> () {
    switch self {
    case .some(var x):
      mutate(&x)
      self = .some(x)
    case .none: ()
    }
  }

  /// Replaces the value in this `Optional` instance with the given value if
  /// the given predicate is satisfied.
  @_transparent
  public mutating func set(
    _ x: Wrapped,
    where p: @escaping (Wrapped) -> Bool = const(true)
  ) {
    if map(p) == true {
      self = x
    }
  }

  /// Assigns the value wrapped in this `Optional` instance to the property
  /// of an object instance.
  ///
  /// When this `Optional` instance is `nil`, no assignment is done.
  ///
  /// - Note: Dis a variant of `assign(to:)`, dawg. With a signature matching
  ///   the [assign(to:on:)][2] function in Apple's [Combine][1] library.
  ///
  /// [1]: https://developer.apple.com/documentation/combine
  /// [2]: https://developer.apple.com/documentation/combine/publisher/3235801-assign
  public func assign<Object: AnyObject>(
    to path: ReferenceWritableKeyPath<Object, Wrapped>,
    on root: Object
  ) {
    switch self {
    case .some(let value):
      root[keyPath: path] = value
    case .none:
      ()
    }
  }

  /// Assigns the value wrapped in this `Optional` instance to the given
  /// mutable value.
  public func assign(to lvalue: inout Wrapped) {
    switch self {
    case .some(let x):
      lvalue = x
    case .none:
      ()
    }
  }

  /// Sets this `Optional` instance to `.none` and returns `.none`. Any wrapped
  /// value in this `Optional` instance is thereby lost.
  @discardableResult
  public mutating func drop() -> Self {
    const(.none)(self = .none)
  }

  /// Returns the wrapped value if this Optional instance is `.some`, leaving
  /// a `.none` in its stead; otherwise returns `.none` and leaves the
  /// `Optional` instance untouched.
  @discardableResult
  public mutating func remove() -> Self {
    const(some)(self = .none)
  }

  /// Returns this `Optional` instance value unwrapped when it is not `nil`,
  /// otherwise, returns the value computed by the given alternate function.
  ///
  /// - Parameter alternative: A value to return if this `Optional` is `nil`.
  /// - Returns: The unwrapped value or the given alternative in case of `nil`.
  @inlinable
  public func otherwise(
    _ alternate: () -> Wrapped
  ) -> Wrapped {
    return self ?? alternate()
  }

  /// Returns the value computed by the given `alternative` iff this `Optional`
  /// instance is `nil`, otherwise, returns its unwrapped value shortcircuiting
  /// before ever computing `alternative`.
  ///
  /// - Parameter alternative: A value to return if this `Optional` is `nil`.
  /// - Returns: The unwrapped value or the given alternative in case of `nil`.
  @inlinable
  public func `else`(
    _ alternative: @autoclosure () -> Wrapped
  ) -> Wrapped {
    return self ?? alternative()
  }

  /// Returns the value computed by the given `alternative` iff this `Optional`
  /// instance is `nil`, otherwise, returns its unwrapped value shortcircuiting
  /// before ever computing `alternative`.
  ///
  /// - Parameter alternative: A value to return if this `Optional` is `nil`.
  /// - Returns: The unwrapped value or the given alternative in case of `nil`.
  @inlinable
  public func or(
    _ alternative: @autoclosure () -> Wrapped?
  ) -> Wrapped? {
    return self ?? alternative()
  }

  /// Returns an Optional pair with the results of mapping the unwrapped
  /// value in this Optional instance to the given functions; or  `nil` if this
  /// `Optional` instance is `nil`.
  ///
  /// Use this function to "fan-out" values to multiple functions, wherein a
  /// single input (the argument) is "spread out" to several consumers (the
  /// functions):
  ///
  ///     let hello = "comma,separated"
  ///     let pair = firstIndex(of: ",")
  ///       .spread(prefix(upTo:), suffix(following:))
  ///     print(String(pair.0)) // prints "comma"
  ///     print(String(pair.1)) // prints "separated"
  ///
  /// - Note: For a variant that has its returning pair unzipped, that is,
  ///   each value is an Optional instead of the pair itself being Optional,
  ///   see the overloaded function with the appropriate signature.
  /// - Parameters:
  ///   - f: A polymorphic function on `T`.
  ///   - g: A polymorphic function on `T`.
  /// - Returns: A pair holding the results of applying each function to the
  ///   unwrapped value of this Optional or `nil` if this instance of Optional
  ///   is `nil`.
  @inlinable
  public func split<U, U´>(
    _ f: @escaping (Wrapped) -> U,
    _ g: @escaping (Wrapped) -> U´
  ) -> (U, U´)? {
    switch self {
    case let .some(x):
      return (f(x), g(x))
    case .none:
      return .none
    }
  }

  /// Evaluates the given side-effect closure when this `Optional` instance is
  /// **not** `nil`, passing the unwrapped value as a parameter without returning
  /// a value.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public func forSome(
    _ f: (Wrapped) -> ()
  ) -> () {
    switch self {
    case .some(let x): f(x)
    case .none: ()
    }
  }

  /// Evaluates a given side-effect when this `Optional` instance **is** `nil`.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public func forNone(
    _ f: (Wrapped) -> ()
  ) -> () {
    switch self {
    case .some(let x): f(x)
    case .none: ()
    }
  }

  /// Evaluates the given side-effect closure when this `Optional` instance is
  /// not `nil`, passing the unwrapped value as a parameter without returning
  /// a value.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public func when(
    some: (Wrapped) -> (),
    none: () -> () = noop
  ) -> () {
    switch self {
    case .some(let x): some(x)
    case .none: _ = none()
    }
  }

  /// (`|||`) Fanin: Merge the input passing it to the type-corresponding arrow.
  ///
  /// A mathematical representation of choice within a computation.
  /// ```
  /// f ||| g
  ///          ┌──╸f a → c'╺─┒
  /// Either(a + b)       (c'+c")?╺─╴c
  ///          └──╸g b → c"╺─┚
  /// ```
  @inlinable
  public func either<Transformed>(
    _ f: @escaping (Wrapped) -> Transformed,
    or g: @escaping @autoclosure () -> Transformed
  ) -> Transformed {
    switch self {
      case .some(let x):
        return f(x)
      case .none:
        return g()
    }
  }

  /// Returns the instance of this functor with its associated value(s)
  /// discarded and replaced by ().
  @inlinable
  public __consuming func discard() -> ()? {
    return map(const(()))
  }

  /// A functional variant of the `guard` statement that returns `nil` if this
  /// Optional instance is `nil` or the given predicate `p` evaluates to
  /// `false`.
  ///
  /// This function works similar to `Sequence.filter(_:)`. You can imagine
  /// `Optional` being an iterator over _one_ (`.some`) or _zero_ (`.none`)
  /// elements. `filter(_:)` lets you decide which elements to keep:
  ///
  ///     fn is_even(n: &i32) -> bool {
  ///       n % 2 == 0
  ///     }
  ///
  ///     assert_eq!(None.filter(is_even), None);
  ///     assert_eq!(Some(3).filter(is_even), None);
  ///     assert_eq!(Some(4).filter(is_even), Some(4));
  ///
  /// - Parameter predicate: A closure that takes the unwrapped value of the
  ///   `Optional` as its argument and returns a Boolean value indicating
  ///   whether it should be returned or not.
  /// - Returns: The value wrapped in this `Optional` iff this `Optional` is
  ///   not `nil` and the predicate evaluates to `true`, otherwise returns `nil`.
  @_transparent
  public __consuming func `guard`(
    _ predicate: (Wrapped) -> Bool
  ) -> Wrapped? {
    fmap(predicate) == true ? self : .none
  }

  /// Asserts whether this instance of `Optional` satisfies the given predicate,
  /// raising a runtime assertion on debug targets if it does not satisfy.
  ///
  /// - Parameters:
  ///   - predicate: The predicate this `Optional` instance should satisfy.
  ///   - message: A message to display if it does not satisfy.
  /// - Returns: This instance of `Optional`.
  @_transparent
  public __consuming func assert(
    _ p: (Wrapped?) -> Bool,
    _ message: @autoclosure () -> String = .empty,
    fl: StaticString = #file,
    ln: UInt = #line
  ) -> Wrapped? {
    const(self)(Swift.assert(p(self), message(), file: fl, line: ln))
  }

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter, discarding the result and
  /// returning this Optional instance.
  ///
  /// Use the `tap` method when you want to branch out of a composition
  /// chain to evaluate side-effects, eg. print debugging information to the
  /// console.
  ///
  /// - Note: In *nix, Ruby and some FP libraries, "tee" is the co-opted term
  ///   for this operation, shortened from [Hot tapping](https://en.wikipedia.org/wiki/Hot_tapping)
  ///   a piping technique.
  /// - Note: In *nix shells, it is known as the [tee command](https://en.wikipedia.org/wiki/Tee_(command))
  ///   and it is named after the T-splitter used in plumbing.
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: This `Optional` instance.
  @inlinable
  public func tap(
    sink: (Wrapped) -> ()
  ) -> Wrapped? {
    const(self)(map(sink))
  }

  /// Flattens this `Optional<(Optional<•>, Optional<•>)>`) instance down to
  /// `(Optional<•>, Optional<•>)`
  @inlinable
  public func unzip<A, B>() -> (A?, B?) where Wrapped == (A?, B?)  {
    switch self {
    case let (a, b)?:
      return (a, b)
    default:
      return (.none, .none)
    }
  }

  @inlinable
  public func fmapFirst<A, Aʹ, B>(
    _ transform: (A) -> Aʹ
  ) -> (Aʹ, B)? where Wrapped == (A, B) {
    return fmap { (transform($0.0), $0.1) }
  }

  @inlinable
  public func fmapSecond<A, B, Bʹ>(
    _ transform: (B) -> Bʹ
  ) -> (A, Bʹ)? where Wrapped == (A, B) {
    return fmap { ($0.0, transform($0.1)) }
  }

  /// Returns the result of calling the function wrapped in this Optional
  /// passing the given argument iff this Optional is not `nil`, otherwise
  /// returns `nil`.
  ///
  /// - Parameter argument: The function argument.
  /// - Returns: The result of the function call or `nil` if this Optional
  ///   instance is `nil`.
  @inlinable
  public func call<T, U>(
    with argument: T
  ) -> U? where Wrapped == (T) -> U {
    return some?(argument)
  }
}

extension Optional where Wrapped: Equatable {

  public mutating func replace(_ x: Self, with y: Self) {
    if case x = self {
      self = y
    }
  }
}

/// Returns a new function composing two functions whose return values are
/// wrapped in Optionals.
///
/// Kleisli composition allows monadic computations to be composed same as
/// (`>>>`) allows bare functions to be composed. (`>=>`) achieves this by
/// binding (`>>=`) the monads returned by the given functions sequentially,
/// yielding result of the last computation.
///
/// This type of composition is _syntactically_ equivalent to binding a
/// sequence of monadic mappings:
///
///     list.flatMap(compute).flatMap(otherCompute).flatMap(anotherCompute)
///
/// _is syntactically equivalent to:_
///
///     let compute = firstCompute >=> otherCompute >=> anotherCompute
///     list.flatMap(compute)
///
/// - Important: Kleisli composition is **not** _semantically_ equivalent to
/// chaining a sequence of monadic bindings. In the above example, there are
/// two key differences:
///
/// 1. Like (`>>>`), (`>=>`) yields a composable unit of its parts which can
///    be memoized, reused and/or further composed.
/// 2. The first example traverses the list 3 times, whereas (`>=>`)
///    guarantees one and one only traversal.
///
/// ### Syntax matters
///
/// (`>=>`) helps form the structure of an expression, but it should not be
/// seen as part of its content. Like any higher-order function or combinator,
/// this is a code equivalent of a preposition or, perhaps more appropriately,
/// a punctuation mark. The symbolic nature further deemphasizes the structure
/// allowing readers to focus on the core of the expression it glues together,
/// while breaking it into visually distinct parts.
///
/// - Parameters:
///     - f: A monadic computation.
///     - g: The monadic computation that will follow `f`.
/// - Returns: A function composing `f` and `g`.
@_transparent
public func >=> <A, B, C>(
  f: @escaping (A) -> B?,
  g: @escaping (B) -> C?
) -> (A) -> C? {
  return bind(g) • f
}

@_transparent
public func <=< <A, B, C>(
  f: @escaping (B) -> C?,
  g: @escaping (A) -> B?
) -> (A) -> C? {
  return bind(f) • g
}

@_transparent
public func >=> <T, Tʹ, U, Result>(
  f: @escaping ((T, Tʹ)) -> U?,
  g: @escaping (U) -> Result?
) -> ((T, Tʹ)) -> Result? {
  return bind(g) • f
}

// MARK: - Comparable

extension Optional /*: Comparable*/ where Wrapped: Comparable {

  public static func > (
    lhs: Wrapped?,
    rhs: @autoclosure () -> Wrapped
  ) -> Bool {
    switch lhs {
    case let lhs?:
      return lhs > rhs()
    case _:
      return false
    }
  }

  @available(*, unavailable, message: "Only greater-than (>) comparisons between Optionals and non-Optional are allowed.")
  public static func > (lhs: Wrapped?, rhs: Wrapped?) -> Bool { return false  }

  @available(*, unavailable, message: "Only greater-than (>) comparisons between Optionals and non-Optional are allowed.")
  public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool { return false }
}

// MARK: - DefaultStringInterpolation

extension DefaultStringInterpolation {

  /// Interpolates the textual representation of the unwrapped value of the
  /// given `Optional` instance into the string literal being created.
  ///
  /// Use this type of interpolation to silence warnings related to
  /// interpolating optional instances by making the case explicit.
  ///
  /// Do not call this method directly. It is used by the compiler when
  /// interpreting string interpolations. Instead, use string interpolation to
  /// create a new string by including values, literals, variables, or
  /// expressions enclosed in parentheses, prefixed by a backslash (`\(…)`).
  ///
  /// - Parameter value: The Optional instance to interpolate.
  @inlinable
  public mutating func appendInterpolation<T>(optional: T?) {
    switch optional {
    case let .some(value):
      appendInterpolation(#"⩻\#(value)⩼"#) 
    case .none:
      appendInterpolation("⩻␀⩼")
    }
  }
}

extension Optional: CustomStringConvertible
  where Wrapped: CustomStringConvertible
{
  /// Describes Optionals as 'value?' instead of 'Optional(value)'.
  public var description: String {
    switch self {
    case .some(let x):
      return #""\#(x.description)"?"#
    case .none:
      return "nil"
    }
  }
}

// MARK: -
// MARK: - Static thunks

extension Optional {

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `map` method with a closure that returns a non-optional value.
  ///
  /// - Note: A Functor. `map` is an ad-hoc functorial implementation.
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  @inlinable
  public static func fmap<Transformed>(
    _ transform: @escaping (Wrapped) -> Transformed
  ) -> (Wrapped?) -> Transformed? {
    return { $0.map(transform) }
  }

  /// Evaluates the given closure when it is not `nil` and this `Optional`
  /// instance is not `nil` either, passing the unwrapped value as a parameter.
  ///
  /// Use the `apply` method with an optionl closure that returns a non-optional
  /// value.
  ///
  /// - Note: An Applicative. This is an ad-hoc applicative implementation
  ///   defined in monadic terms.
  /// - Parameter transform: An optional closure that takes the unwrapped
  ///   value of the instance.
  /// - Returns: The result of the given closure. If the given closure or this
  ///   instance are `nil`, returns `nil`.
  @inlinable
  public static func apply<Transformed>(
    _ transform: ((Wrapped) -> Transformed)?
  ) -> (Wrapped?) -> Transformed? {
    return { $0.apply(transform) }
  }

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `flatMap` method with a closure that returns an optional value.
  ///
  /// - Note: A Monad. `flatMap` is an ad-hoc monadic implementation of `bind`.
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  @inlinable
  public static func bind<Transformed>(
    _ transform: @escaping (Wrapped) -> Transformed?
  ) -> (Wrapped?) -> Transformed? {
    return { $0.flatMap(transform) }
  }

  /// Evaluates the given closure `f` when this `Optional` instance is not
  /// `nil`, passing the unwrapped value as a parameter; or evaluates the
  /// given closure `g`.
  ///
  /// - Note: A Bifunctor. `bimap` is an ad-hoc functorial implementation.
  /// - Parameters
  ///   - f: A closure that takes the unwrapped value of the instance.
  ///   - g: A closure that returns a value.
  /// - Returns: Either the value returned by `f` or the one returned by `g`.
  @inlinable
  public static func bimap<U, Uʹ>(
    _ f: @escaping (Wrapped) -> U,
    _ g: @escaping () -> Uʹ
  ) -> (Wrapped?) -> Either<U, Uʹ> {
    return { $0.bimap(f, g) }
  }

  /// Assigns the value wrapped in this `Optional` instance to the property
  /// of an object instance.
  ///
  /// When this `Optional` instance is `nil`, no assignment is done.
  ///
  /// - Note: Dis a variant of `assign(to:)`, dawg. With a signature matching
  ///   the [assign(to:on:)][2] function in Apple's [Combine][1] library.
  ///
  /// [1]: https://developer.apple.com/documentation/combine
  /// [2]: https://developer.apple.com/documentation/combine/publisher/3235801-assign
  public static func assign<Object: AnyObject>(
    to path: ReferenceWritableKeyPath<Object, Wrapped>,
    on root: Object
  ) -> (Wrapped?) -> () {
    { $0.assign(to: path, on: root) }
  }

  /// Evaluates the given side-effect closure when this `Optional` instance is
  /// **not** `nil`, passing the unwrapped value as a parameter without returning
  /// a value.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public static func forSome(
    _ f: @escaping (Wrapped) -> ()
  ) -> (Wrapped?) -> () {
    return { $0.forSome(f) }
  }

  /// Evaluates a given side-effect when this `Optional` instance **is** `nil`.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public static func forNone(
    _ f: @escaping (Wrapped) -> ()
  ) -> (Wrapped?) -> () {
    return { $0.forNone(f) }
  }

  /// Evaluates the given side-effect closure when this `Optional` instance is
  /// not `nil`, passing the unwrapped value as a parameter without returning
  /// a value.
  ///
  /// Use the `whenSome` method with a closure that doesn't return any value,
  /// eg: the last call in a `UIView` composition chain
  ///
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance but doesn't return anything.
  @inlinable
  public static func when(
    some: @escaping (Wrapped) -> (),
    none: @escaping () -> () = noop
  ) -> (Wrapped?) -> () {
    return { $0.when(some: some, none: none) }
  }

  /// (`|||`) Fanin: Merge the input passing it to the type-corresponding arrow.
  ///
  /// A mathematical representation of choice within a computation.
  /// ```
  /// f ||| g
  ///          ┌──╸f a → c'╺─┒
  /// Either(a + b)       (c'+c")?╺─╴c
  ///          └──╸g b → c"╺─┚
  /// ```
  @inlinable
  public static func either<Transformed>(
    _ f: @escaping (Wrapped) -> Transformed,
    or g: @escaping @autoclosure () -> Transformed
  ) -> (Wrapped?) -> Transformed {
    { $0.either(f, or: g()) }
  }

  /// Evaluates the given predicate when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter and returning said value iff
  /// the give predicate returns `true`, otherwise returns `nil`.
  ///
  /// This function works similar to `Sequence.filter(_:)`. You can imagine
  /// `Optional` being an iterator over _one_ (`.some`) or _zero_ (`.none`)
  /// elements. `filter(_:)` lets you decide which elements to keep:
  ///
  ///     fn is_even(n: &i32) -> bool {
  ///       n % 2 == 0
  ///     }
  ///
  ///     assert_eq!(None.filter(is_even), None);
  ///     assert_eq!(Some(3).filter(is_even), None);
  ///     assert_eq!(Some(4).filter(is_even), Some(4));
  ///
  /// - Returns: The value wrapped in this `Optional` iff this `Optional` is
  ///   not `nil` and the predicate evaluates to `true`, otherwise returns `nil`.
  @inlinable
  public static func `guard`(
    _ p: @escaping (Wrapped) -> Bool
  ) -> (Wrapped?) -> Wrapped? {
    return { $0.guard(p) }
  }

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter, discarding the result and
  /// returning this Optional instance.
  ///
  /// Use the `tap` method when you want to branch out of a composition
  /// chain to evaluate side-effects, eg. print debugging information to the
  /// console.
  ///
  /// - Note: In *nix, Ruby and some FP libraries, "tee" is the co-opted term
  ///   for this operation, shortened from [Hot tapping](https://en.wikipedia.org/wiki/Hot_tapping)
  ///   a piping technique.
  /// - Note: In *nix shells, it is known as the [tee command](https://en.wikipedia.org/wiki/Tee_(command))
  ///   and it is named after the T-splitter used in plumbing.
  /// - Parameter effect: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: This `Optional` instance.
  @inlinable
  public static func tap(
    sink: @escaping (Wrapped) -> ()
  ) -> (Wrapped?) -> Wrapped? {
    return { $0.tap(sink: sink) }
  }

  /// Returns this `Optional` instance value unwrapped when it is not `nil`,
  /// otherwise, returns the value computed by the given alternate function.
  ///
  /// - Parameter alternative: A value to return if this `Optional` is `nil`.
  /// - Returns: The unwrapped value or the given alternative in case of `nil`.
  @inlinable
  public static func otherwise(
    _ alternate: @escaping () -> Wrapped
  ) -> (Wrapped?) -> Wrapped {
    return { $0.otherwise(alternate) }
  }

  /// Returns this `Optional` instance value unwrapped when it is not `nil`,
  /// otherwise, returns the value computed by the given alternate function.
  ///
  /// - Parameter alternative: A value to return if this `Optional` is `nil`.
  /// - Returns: The unwrapped value or the given alternative in case of `nil`.
  @inlinable
  public static func `else`(
    _ alternative: @escaping @autoclosure () -> Wrapped
  ) -> (Wrapped?) -> Wrapped {
    return { $0.else(alternative()) }
  }

  /// Flattens this Optional instance when its wrapped value is another Optional.
  ///
  /// Use `join` to remove one level of monadic structure from this monad.
  ///
  ///     join :: (Monad m) => m (m a) -> m a
  ///     join x = x >>= id
  @inlinable
  public static func join<Wrapped>(_ x: Wrapped??) -> Wrapped? {
    return x.join()
  }
}

/// (`|||`) Fanin: Merge the input passing it to the type-corresponding arrow.
///
/// A mathematical representation of choice within a computation.
/// ```
/// f ||| g
///    ┌─────╸f a → c'╺─┒
/// a ||| b           (c'+c")?╺─╴c
///    └─────╸g b → c"╺─┚
/// ```
@inlinable
public func ?? <Wrapped, U>(
  f: @escaping (Wrapped) -> U,
  g: @escaping @autoclosure () -> U
) -> (Wrapped?) -> U {
  { $0.map(f) ?? g() }
}

// MARK: -
// MARK: - Tacit thunks

/// Maps `.some` value to the given function.
///
/// Using fmap (as in _functor_ map) to avoid clashing with the global map.
///
///     (<$>) ∷ Functor f => (a -> b) -> f a -> f b
///     (<$>) = fmap
@inlinable
public func fmap<Wrapped, U>(
  _ λ: @escaping (Wrapped) -> U
) -> (Wrapped?) -> U? {
  return Optional.fmap(λ)
}

/// Maps `.some` value to `.some` function.
///
/// Allows for the sequential application of curried functions.
///
///     liftA2 ∷ Applicative f => (a -> b -> c) -> f a -> f b -> f c
///     liftA2 f x = (<*>) (fmap f x)
///
///     (<*>) ∷ f (a -> b) -> f a -> f b
///     (<*>) = liftA2 id
@inlinable
public func apply<Wrapped, U>(
  _ λ: ((Wrapped) -> U)?
) -> (Wrapped?) -> U? {
  return Optional.apply(λ)
}

/// Maps `.some` value to the given Kleisli function.
///
/// Allows multiple Kleisli functions to be bound without nesting its results.
///
///     (>>=) ∷ Monad m => ∀ ab. m a -> (a -> m b) -> m b
@inlinable
public func bind<Wrapped, U>(
  _ λ: @escaping (Wrapped) -> U?
) -> (Wrapped?) -> U? {
  return Optional.bind(λ)
}

/// Evaluates the given closure `f` when this `Optional` instance is not
/// `nil`, passing the unwrapped value as a parameter; or evaluates the
/// given closure `g`.
///
/// - Note: A Bifunctor. `bimap` is an ad-hoc functorial implementation.
/// - Parameters
///   - f: A closure that takes the unwrapped value of the instance.
///   - g: A closure that returns a value.
/// - Returns: Either the value returned by `f` or the one returned by `g`.
@inlinable
public func bimap<Wrapped, U, Uʹ>(
  _ f: @escaping (Wrapped) -> U,
  _ g: @escaping () -> Uʹ
) -> (Wrapped?) -> Either<U, Uʹ> {
  return Optional.bimap(f, g)
}

/// Assigns the value wrapped in this `Optional` instance to the property
/// of an object instance.
///
/// When this `Optional` instance is `nil`, no assignment is done.
///
/// - Note: Dis a variant of `assign(to:)`, dawg. With a signature matching
///   the [assign(to:on:)][2] function in Apple's [Combine][1] library.
///
/// [1]: https://developer.apple.com/documentation/combine
/// [2]: https://developer.apple.com/documentation/combine/publisher/3235801-assign
public func assign<Object: AnyObject, Wrapped>(
  to path: ReferenceWritableKeyPath<Object, Wrapped>,
  on root: Object
) -> (Wrapped?) -> () {
  { $0.assign(to: path, on: root) }
}

/// Evaluates the given side-effect closure when this `Optional` instance is
/// not `nil`, passing the unwrapped value as a parameter without returning
/// a value.
///
/// - Parameter f: A closure that takes the unwrapped value
///   of the instance but doesn't return anything.
@inlinable
public func forSome<Wrapped>(
  _ f: @escaping (Wrapped) -> ()
) -> (Wrapped?) -> () {
  return flip(Optional.forSome)(f)
}

/// Evaluates a given side-effect when this `Optional` instance **is** `nil`.
///
/// - Parameter f: A closure that takes the unwrapped value
///   of the instance but doesn't return anything.
@inlinable
public func forNone<Wrapped>(
  _ f: @escaping (Wrapped) -> ()
) -> (Wrapped?) -> () {
  return flip(Optional.forNone)(f)
}

/// Evaluates the given side-effect closure when this `Optional` instance is
/// not `nil`, passing the unwrapped value as a parameter without returning
/// a value.
///
/// Use the `when` method with a closure that doesn't return any value.
@inlinable
public func when<Wrapped>(
  some: @escaping (Wrapped) -> (),
  none: @escaping () -> () = noop
) -> (Wrapped?) -> () {
  Optional.when(some: some, none: none)
}

/// (`|||`) Fanin: Merge the input passing it to the type-corresponding arrow.
///
/// A mathematical representation of choice within a computation.
/// ```
/// f ||| g
///          ┌──╸f a → c'╺─┒
/// Either(a + b)       (c'+c")?╺─╴c
///          └──╸g b → c"╺─┚
/// ```
@inlinable
public func either<Wrapped, Transformed>(
  _ f: @escaping (Wrapped) -> Transformed,
  or g: @escaping () -> Transformed
) -> (Wrapped?) -> Transformed {
  Optional.either(f, or: g())
}

/// Returns this `Optional` instance value unwrapped when it is not `nil`,
/// otherwise, returns the value computed by the given alternate function.
///
/// - Parameter alternative: A value to return if this `Optional` is `nil`.
/// - Returns: The unwrapped value or the given alternative in case of `nil`.
@inlinable
public func otherwise<Wrapped>(
  _ alternate: @escaping () -> Wrapped
) -> (Wrapped?) -> Wrapped {
  Optional.otherwise(alternate)
}

/// Returns this `Optional` instance value unwrapped when it is not `nil`,
/// otherwise, returns the value computed by the given alternate function.
///
/// - Parameter alternative: A value to return if this `Optional` is `nil`.
/// - Returns: The unwrapped value or the given alternative in case of `nil`.
@inlinable
public func `else`<Wrapped>(
  _ alternative: @escaping @autoclosure () -> Wrapped
) -> (Wrapped?) -> Wrapped {
  Optional.else(alternative())
}

/// Flattens this Optional instance when its wrapped value is another Optional.
///
/// Use `join` to remove one level of monadic structure from this monad.
///
///     join :: (Monad m) => m (m a) -> m a
///     join x = x >>= id
@inlinable
public func join<Wrapped>(_ x: Wrapped??) -> Wrapped? {
  return .join(x)
}

/// Evaluates the given predicate when this `Optional` instance is not `nil`,
/// passing the unwrapped value as a parameter and returning said value iff
/// the give predicate returns `true`, otherwise returns `nil`.
///
/// This function works similar to `Sequence.filter(_:)`. You can imagine
/// `Optional` being an iterator over _one_ (`.some`) or _zero_ (`.none`)
/// elements. `filter(_:)` lets you decide which elements to keep:
///
///     fn is_even(n: &i32) -> bool {
///       n % 2 == 0
///     }
///
///     assert_eq!(None.filter(is_even), None);
///     assert_eq!(Some(3).filter(is_even), None);
///     assert_eq!(Some(4).filter(is_even), Some(4));
///
/// - Returns: The value wrapped in this `Optional` iff this `Optional` is
///   not `nil` and the predicate evaluates to `true`, otherwise returns `nil`.
@inlinable
public func `guard`<Wrapped>(
  _ p: @escaping (Wrapped) -> Bool
) -> (Wrapped?) ->  Wrapped? {
  return Optional.guard(p)
}

/// Returns an Optional tuple with the unwrapped values of the given Optional
/// instances; or returns `nil` if any if the instances is `nil`.
///
/// - Parameters:
///   - a: An Optional instance with a value of type `A`.
///   - b: An Optional instance with a value of type `A` or `B`.
/// - Returns: An Optional pair with the unwrapped values of `a` and `b` or
///   `.none` if `a` _or_ `b` were `nil`.
@inlinable
public func zip<A, B>(
  _ a: A?, _ b: B?
) -> (A, B)? {
  guard case let (a?, b?) = (a, b) else { return .none }
  return (a, b)
}

/// Zips with the given function.
///
/// This is an uncurried, impure variant of zip(with:).
@inlinable
public func zip<A, B, C>(
  _ a: A?,
  _ b: B?,
  with f: (A, B) -> C
) -> C? {
  return zip(a, b).map(f)
}

/// Zips with the given function as the first argument, instead of a tupling
/// function.
///
/// For example, `zip(with: +)` is applied to two lists to produce
/// the list of corresponding sums.
///
///     zipWith :: (a → b → c) → [a] → [b] → [c]
///     zipWith f = go
///       where
///         go [] _ = []
///         go _ [] = []
///         go (x:xs) (y:ys) = f x y : go xs ys
///
///     zipWithM ∷ (Applicative m) ⟹ (a → b → m c) → [a] → [b] → m [c]
///     zipWithM f xs ys = sequenceA (zipWith f xs ys)
///
/// - Note: `zip(with:)` further generalises zip to arbitrary applicative
///   functors.
@inlinable
public func zip<A, B, C>(
  with f: @escaping (A, B) -> C
) -> (A?, B?) -> C? {
  return zip >>> fmap(f)
}

/// Returns an Optional tuple with the unwrapped values of the given Optional
/// instances; or returns `nil` if any if the instances is `nil`.
///
/// - Parameters:
///   - a: An Optional instance with a value of type `A`.
///   - b: An Optional instance with a value of type `A` or `B`.
/// - Returns: An Optional pair with the unwrapped values of `a` and `b` or
///   `.none` if `a` _or_ `b` were `nil`.
@inlinable
public func zip3<A, B, C>(
  _ a: A?, _ b: B?, _ c: C?
) -> (A, B, C)? {
  guard case let (a?, b?, c?) = (a, b, c) else { return .none }
  return (a, b, c)
}

/// `zip(with:)` generalises zip by zipping with the given function as the
/// first argument, instead of a tupling function.
@inlinable
public func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
) -> (A?, B?, C?) -> D? {
  return map(fmap(f) • zip3)
}

/// zip-like 'map'
///
///     zipWith ∷ (Functor f) ⟹ (a → b → c) → f a → f b → f c
///     zipWith f a b = uncurry f <$> zip a b
@inlinable
public func zip<A, B, C>(
  with f: @escaping (A) -> (B) -> C
) -> (A?) -> (B?) -> C? {
  return { a in { b in fmap(uncurry(f))(zip(a, b)) } } // <1ms
}

/// zip-like 'ap'
///
///     zap ∷ (Functor f) ⟹ f (a → b) → f a → f b
///     zap = zipWith id
@inlinable
public func zap<A, B>(_ f: ((A) -> B)?) -> (A?) -> B? {
  return zip(with: id)(f)
}

/// Unzips a zipped Optional pair.
@inlinable
public func unzip<A, B>(_ Π: (A, B)?) -> (A?, B?) {
  return (Π?.0, Π?.1)
}

/// Returns an `Optional` pair (2-tuple) with the unwrapped values of the given
/// `KeyPath`; or `nil` if any if the values is `nil`.
///
/// - Parameters:
///   - path₁: An `Optional<Value₁>` instance.
///   - path₂: An `Optional<Value₂>` instance.
/// - Returns: An `Optional` pair with the unwrapped values of `a` and `b` or
///   `.none` if `a` _or_ `b` were `nil`.
@_transparent
public func zip<Root, Value₁, Value₂>(
  _ path₁: KeyPath<Root, Value₁?>,
  _ path₂: KeyPath<Root, Value₂?>
) -> (Root) -> (Value₁, Value₂)? {
  return { root in zip(root[keyPath: path₁], root[keyPath: path₂]) }
}

/// Returns an `Optional` triple (3-tuple) with the unwrapped values of the
/// given `KeyPath`; or `nil` if any if the values is `nil`.
///
/// - Parameters:
///   - path₁: An `Optional<Value₁>` instance.
///   - path₂: An `Optional<Value₂>` instance.
///   - path₃: An `Optional<Value₃>` instance.
/// - Returns: An Optional triple with the unwrapped values of `a` and `b` or
///   `.none` if `a` _or_ `b` were `nil`.
@_transparent
public func zip<Root, Value₁, Value₂, Value₃>(
  _ path₁: KeyPath<Root, Value₁?>,
  _ path₂: KeyPath<Root, Value₂?>,
  _ path₃: KeyPath<Root, Value₃?>
) -> (Root) -> (Value₁, Value₂, Value₃)? {
  return { r in zip3(r[keyPath: path₁], r[keyPath: path₂], r[keyPath: path₃]) }
}
