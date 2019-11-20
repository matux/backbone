import Swift

/// Returns a binary function that calls 𝑓 passing its arguments in reverse
/// order.
///
/// `flip(λ)` will take its arguments in the reverse order of λ as denoted
/// by `flip(λ)(x, y) → λ(y, x)`. For example:
///
///       1> flip(+)("hello", "world")
///     $R0: String = "worldhello"
///
/// - Parameter λ: A binary function.
/// - Returns: A binary function taking the same arguments in reverse order.
/// - Tag: Flip.swift
enum Flip {}

// MARK: -
// MARK: - ⠀• ⠀non-throwing⠀ •

// MARK: - closure

public func flip<A, B, R>(_ λ: @escaping (A?, () -> B) -> R) -> (() -> B, A?) -> R { { f, a in λ(a, f) } }

public func flip<A, B, R>(_ λ: @escaping (A?) -> (@escaping @autoclosure () -> B) -> R) -> (@escaping @autoclosure () -> B) -> (A?) -> R { { f in { a in λ(a)(f()) } } }

// MARK: - uncurried

//@inlinable public func flip<A, B,       R>(_ λ: @escaping ((A, B      )) -> R) -> (      B, A) -> R { {       b, a in λ((a, b      )) } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping ((A, B, C   )) -> R) -> (   C, B, A) -> R { {    c, b, a in λ((a, b, c   )) } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping ((A, B, C, D)) -> R) -> (D, C, B, A) -> R { { d, c, b, a in λ((a, b, c, d)) } }

// MARK: - curried

@inlinable public func flip<A,          R>(_ λ: @escaping (A) -> ()                -> R) ->                      (A) -> R { {                      a in λ (a) ()          } }
@inlinable public func flip<A, B,       R>(_ λ: @escaping (A) -> (B)               -> R) ->               (B) -> (A) -> R { {               b in { a in λ (a) (b)         } } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping (A) -> (B) -> (C)        -> R) ->        (C) -> (B) -> (A) -> R { {        c in { b in { a in λ (a) (b) (c)     } } } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping (A) -> (B) -> (C) -> (D) -> R) -> (D) -> (C) -> (B) -> (A) -> R { { d in { c in { b in { a in λ (a) (b) (c) (d) } } } } }

// MARK: - inout

@inlinable public func flip<A,          R>(_ λ: @escaping (inout A) -> ()        -> R) ->              (inout A) -> R { {              a in λ (&a) ()        } }
@inlinable public func flip<A, B,       R>(_ λ: @escaping (inout A) -> (B)       -> R) -> (      B) -> (inout A) -> R { {       b in { a in λ (&a) (b)       } } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping (inout A) -> (B, C)    -> R) -> (   C, B) -> (inout A) -> R { {    c, b in { a in λ (&a) (b, c)    } } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping (inout A) -> (B, C, D) -> R) -> (D, C, B) -> (inout A) -> R { { d, c, b in { a in λ (&a) (b, c, d) } } }

// MARK: - instance

@inlinable public func flip<Self, A, B,    R>(_ λ: @escaping (Self) -> ((A, B   )) -> R) -> (   B, A) -> (Self) -> R { { b, a    in { `self` in λ (self) ((a, b)) } } }
@inlinable public func flip<Self, A, B, C, R>(_ λ: @escaping (Self) -> ((A, B, C)) -> R) -> (C, B, A) -> (Self) -> R { { c, b, a in { `self` in λ (self) ((a, b, c)) } } }

// MARK: - instance inout

@inlinable public func flip<Self, A, B,    R>(_ λ: @escaping (inout Self) -> ((A, B   )) -> R) -> (   B, A) -> (inout Self) -> R { { b, a    in { `self` in λ (&self) ((a, b   )) } } }
@inlinable public func flip<Self, A, B, C, R>(_ λ: @escaping (inout Self) -> ((A, B, C)) -> R) -> (C, B, A) -> (inout Self) -> R { { c, b, a in { `self` in λ (&self) ((a, b, c)) } } }

// MARK: -
// MARK: - ⠀•⠀⠀⠀throwing⠀ ⠀•

// MARK: - uncurried

@inlinable public func flip<A, B,       R>(_ λ: @escaping ((A, B      )) throws -> R) -> (      B, A) throws -> R { {       b, a in try λ((a, b      )) } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping ((A, B, C   )) throws -> R) -> (   C, B, A) throws -> R { {    c, b, a in try λ((a, b, c   )) } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping ((A, B, C, D)) throws -> R) -> (D, C, B, A) throws -> R { { d, c, b, a in try λ((a, b, c, d)) } }

// MARK: - curried

@inlinable public func flip<A,          R>(_ λ: @escaping (A) -> ()                throws -> R)                      -> (A) throws -> R {                      { a in try λ (a) ()          } }
@inlinable public func flip<A, B,       R>(_ λ: @escaping (A) -> (B)               throws -> R)               -> (B) -> (A) throws -> R {               { b in { a in try λ (a) (b)         } } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping (A) -> (B) -> (C)        throws -> R)        -> (C) -> (B) -> (A) throws -> R {        { c in { b in { a in try λ (a) (b) (c)     } } } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping (A) -> (B) -> (C) -> (D) throws -> R) -> (D) -> (C) -> (B) -> (A) throws -> R { { d in { c in { b in { a in try λ (a) (b) (c) (d) } } } } }

// MARK: - inout

@inlinable public func flip<A,          R>(_ λ: @escaping (inout A) -> ()        throws -> R) ->              (inout A) throws -> R { {              a in try λ (&a) ()        } }
@inlinable public func flip<A, B,       R>(_ λ: @escaping (inout A) -> (B)       throws -> R) -> (      B) -> (inout A) throws -> R { {       b in { a in try λ (&a) (b)       } } }
@inlinable public func flip<A, B, C,    R>(_ λ: @escaping (inout A) -> (B, C)    throws -> R) -> (   C, B) -> (inout A) throws -> R { {    c, b in { a in try λ (&a) (b, c)    } } }
@inlinable public func flip<A, B, C, D, R>(_ λ: @escaping (inout A) -> (B, C, D) throws -> R) -> (D, C, B) -> (inout A) throws -> R { { d, c, b in { a in try λ (&a) (b, c, d) } } }

// MARK: - instance

@inlinable public func flip<Self, A, B,    R>(_ λ: @escaping (Self) -> ((A, B   )) throws -> R) -> (   B, A) -> (Self) throws -> R { { b, a    in { `self` in try λ (self) ((a, b)) } } }
@inlinable public func flip<Self, A, B, C, R>(_ λ: @escaping (Self) -> ((A, B, C)) throws -> R) -> (C, B, A) -> (Self) throws -> R { { c, b, a in { `self` in try λ (self) ((a, b, c)) } } }

// MARK: - instance inout

@inlinable public func flip<Self, A, B,    R>(_ λ: @escaping (inout Self) -> ((A, B   )) throws -> R) -> (   B, A) -> (inout Self) throws -> R { { b, a    in { `self` in try λ (&self) ((a, b)) } } }
@inlinable public func flip<Self, A, B, C, R>(_ λ: @escaping (inout Self) -> ((A, B, C)) throws -> R) -> (C, B, A) -> (inout Self) throws -> R { { c, b, a in { `self` in try λ (&self) ((a, b, c)) } } }

