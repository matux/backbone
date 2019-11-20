import Swift

/// Pair formation for pointfree contexts.
///
///     ($0 ⁎ 𝜈₂)(𝜈₁) = (𝜈₁, 𝜈₂)
///     (𝜈₁ ⁎ $0)(𝜈₂) = (𝜈₁, 𝜈₂)
infix operator .*. : BitwiseShiftPrecedence

@_transparent
public func .*. <A, B>(_ a: A, _: ·) -> (B) -> (A, B) {
  return { b in (a, b) }
}

@_transparent
public func .*. <A, B>(_: ·, _ b: B) -> (A) -> (A, B) {
  return { a in (a, b) }
}

// Heterogenous tuple cons
prefix operator ‹
postfix operator ›

// Homogenous tuple cons
prefix operator |
postfix operator |

public /*namespace*/ enum Tuple {

  public static func fst<A, B>(_ Π: (A, B)) -> A { Π.0 }
  public static func snd<A, B>(_ Π: (A, B)) -> B { Π.1 }

  public static func fst3<A, B, C>(_ Π: (A, B, C)) -> A { Π.0 }
  public static func snd3<A, B, C>(_ Π: (A, B, C)) -> B { Π.1 }
  public static func þrd3<A, B, C>(_ Π: (A, B, C)) -> C { Π.2 }

  public static func swap<A, B>(_ Π: (A, B)) -> (B, A) { (Π.1, Π.0) }
}

// MARK: -

public func == <A: Equatable, B: Equatable>(
  x: (A, B),
  y: (A, B)
) -> Bool {
  x.0 == y.0 && x.1 == y.1
}

public func == <A: Equatable, B: Equatable, C: Equatable>(
  x: (A, B, C),
  y: (A, B, C)
) -> Bool {
  x.0 == y.0 && x.1 == y.1 && x.2 == y.2
}

public func == <A: Equatable, B: Equatable, C: Equatable, D: Equatable>(
  x: (A, B, C, D),
  y: (A, B, C, D)
) -> Bool {
  x.0 == y.0 && x.1 == y.1 && x.2 == y.2 && x.3 == y.3
}

// MARK: - Pattern

// Unfortunately, even if (a, b) ~= works just fine, `case` patterns complain
// with `Tuple pattern cannot match values of the non-tuple type.`

public func ~= <T: Equatable>(Π: (T, T), x: T) -> Bool {
  Π.0 == x || Π.1 == x
}

public func ~= <T: Equatable>(Π: (T, T, T), x: T) -> Bool {
  Π.0 == x || Π.1 == x || Π.2 == x
}

public func ~= <T: Equatable>(Π: (T, T, T, T), x: T) -> Bool {
  Π.0 == x || Π.1 == x || Π.2 == x || Π.3 == x
}

public func ~= <T: Equatable>(Π: (T, T, T, T, T), x: T) -> Bool {
  Π.0 == x || Π.1 == x || Π.2 == x || Π.3 == x || Π.4 == x
}


public func ~= <T: RawRepresentable>(
  Π: (T, T),
  x: T.RawValue
) -> Bool where T.RawValue: Equatable {
  *Π.0 == x || *Π.1 == x
}

public func ~= <T: RawRepresentable>(
  Π: (T, T, T),
  x: T.RawValue
) -> Bool where T.RawValue: Equatable {
  *Π.0 == x || *Π.1 == x || *Π.2 == x
}

public func ~= <T: RawRepresentable>(
  Π: (T, T, T, T),
  x: T.RawValue
) -> Bool where T.RawValue: Equatable {
  *Π.0 == x || *Π.1 == x || *Π.2 == x || *Π.3 == x
}

public func ~= <T: RawRepresentable>(
  Π: (T, T, T, T, T),
  x: T
) -> Bool where T.RawValue: Equatable {
  *Π.0 == x || *Π.1 == x || *Π.2 == x || *Π.3 == x || *Π.4 == x
}

// MARK: - Tuple formation

@_transparent
public func .*. <A, B>(a: A, b: B) -> (A, B) {
  (a, b)
}

@_transparent
public func .*. <A, B, C>(
  ab: (a: A, b: B),
  c: C
) -> (A, B, C) {
  (ab.a, ab.b, c)
}

@_transparent
public func .*. <A, B, C, D>(
  ab: (a: A, b: B),
  cd: (c: C, d: D)
) -> (A, B, C, D) {
  (ab.a, ab.b, cd.c, cd.d)
}

@_transparent
public func .*. <A, B, C, D, E>(
  ab: (a: A, b: B),
  cde: (c: C, d: D, e: E)
) -> (A, B, C, D, E) {
  (ab.a, ab.b, cde.c, cde.d, cde.e)
}

@_transparent
public func .*. <A, B, C, D>(
  abc: (a: A, b: B, c: C),
  d: D
) -> (A, B, C, D) {
  (abc.a, abc.b, abc.c, d)
}

extension Tuple {

  @inlinable
  public static func append<A, B>(
    _ b: B
  ) -> (A) -> (A, B) {
    { a in a .*. b }
  }

  @inlinable
  public static func append<A, B, C>(
    _ c: C
  ) -> ((A, B)) -> (A, B, C) {
    { ab in ab .*. c }
  }

  @inlinable
  public static func append<A, B, C, D>(
    _ cd: (C, D)
  ) -> ((A, B)) -> (A, B, C, D) {
    { ab in ab .*. cd }
  }

  @inlinable
  public static func append<A, B, C, D, E>(
    _ cde: (C, D, E)
  ) -> ((A, B)) -> (A, B, C, D, E) {
    { ab in ab .*. cde }
  }

  @inlinable
  public static func append<A, B, C, D>(
    _ d: D
  ) -> ((A, B, C)) -> (A, B, C, D) {
    { abc in abc .*. d }
  }
}

//  MARK: - Tuple application

extension Tuple {

  @inlinable
  public static func hoist<T, A, B>(
    _ f: @escaping (T) -> A,
    _ g: @escaping (T) -> B
  ) -> (T) -> (A, B) {
    { x in (f(x), g(x)) }
  }

  @inlinable
  public static func hoist<T, A, B, C>(
    _ f: @escaping (T) -> A,
    _ g: @escaping (T) -> B,
    _ h: @escaping (T) -> C
  ) -> (T) -> (A, B, C) {
    { x in (f(x), g(x), h(x)) }
  }

  @inlinable
  public static func hoist<T, A, B, C, D>(
    _ f: @escaping (T) -> A,
    _ g: @escaping (T) -> B,
    _ h: @escaping (T) -> C,
    _ i: @escaping (T) -> D
  ) -> (T) -> (A, B, C, D) {
    { x in (f(x), g(x), h(x), i(x)) }
  }
}
