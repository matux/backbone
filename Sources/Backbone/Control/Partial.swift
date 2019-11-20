import Swift

/// Ad-hoc partial function application that will make you the envy of friends
/// and family, and everyone except your coworkers. They'll just hate you.
///
/// Partial Application™
///   "𝑻𝒉𝒆 𝒑𝒐𝒘𝒆𝒓 𝒐𝒇 𝒂 𝒇𝒖𝒏𝒄𝒕𝒊𝒐𝒏 𝒄𝒂𝒍𝒍, 𝒃𝒖𝒕 𝒋𝒖𝒔𝒕 𝒂 𝒑𝒂𝒓𝒕 𝒐𝒇 𝒊𝒕."
///
/// http://rosettacode.org/wiki/Partial_function_application

// MARK: Parting binaries

/// Returns a function accepting the missing parameters of the given partially
/// applied function `ƒ`.
///
/// The application of the given function `ƒ` is deferred until all arguments
/// are provided.
///
/// ### Definition
///
///     𝑝𝑎𝑝𝑝𝑙𝑦 𝒇 𝑎 𝑏 𝑐 ∷ 𝐶ᴬˣᴮ × 𝐴 =̃ (𝐶ᴮ)ᴬ × 𝐴 → 𝐶ᴮ
///
/// This is all the documentation you need to understand this concept.
@_transparent
public func partial<A, B, C>(
  _ ƒ   : @escaping (A, B) -> C,
  _ arg₁: A,
  _     : ·
) -> (B) -> C {
  return { arg₂ in ƒ(arg₁, arg₂) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C>(
  _ ƒ   : @escaping (A, B) -> C,
  _     : ·,
  _ arg₂: B
) -> (A) -> C {
  return { arg₁ in ƒ(arg₁, arg₂) }
}

// MARK: Throwing binaries

/// Returns a function accepting the missing parameters of the given partially
/// applied function `ƒ`.
///
/// The application of the given function `ƒ` is deferred until all arguments
/// are provided.
///
/// ### Definition
///
///     𝑝𝑎𝑝𝑝𝑙𝑦 𝒇 𝑎 𝑏 𝑐 ∷ 𝐶ᴬˣᴮ × 𝐴 =̃ (𝐶ᴮ)ᴬ × 𝐴 → 𝐶ᴮ
///
/// This is all the documentation you need to understand this concept.
@_transparent
public func partial<A, B, C>(
  _ ƒ   : @escaping (A, B) throws -> C,
  _ arg₁: A,
  _     : ·
) -> (B) throws -> C {
  return { arg₂ in try ƒ(arg₁, arg₂) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C>(
  _ ƒ   : @escaping (A, B) throws -> C,
  _     : ·,
  _ arg₂: B
) -> (A) throws -> C {
  return { arg₁ in try ƒ(arg₁, arg₂) }
}

// MARK: - Infixed parting

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C>(
  _ arg₁: A,
  _ ƒ   : @escaping (A, B) -> C,
  _     : ·
) -> (B) -> C {
  return { arg₂ in ƒ(arg₁, arg₂) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C>(
  _     : ·,
  _ ƒ   : @escaping (A, B) -> C,
  _ arg₂: B
) -> (A) -> C {
  return { arg₁ in ƒ(arg₁, arg₂) }
}

// MARK: - Parting ternaries

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _ arg₁: A,
  _     : ·,
  _     : ·
) -> (B, C) -> D {
  return { arg₂, arg₃ in ƒ(arg₁, arg₂, arg₃) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _     : ·,
  _ arg₂: B,
  _     : ·
) -> (A, C) -> D {
  return { arg₁, arg₃ in ƒ(arg₁, arg₂, arg₃) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _     : ·,
  _     : ·,
  _ arg₃: C
) -> (A, B) -> D {
  return { arg₁, arg₂ in ƒ(arg₁, arg₂, arg₃) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·
) -> (C) -> D {
  return { arg₃ in ƒ(arg₁, arg₂, arg₃) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C
) -> (B) -> D {
  return { arg₂ in ƒ(arg₁, arg₂, arg₃) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D>(
  _ ƒ   : @escaping (A, B, C) -> D,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C
) -> (A) -> D {
  return { arg₁ in ƒ(arg₁, arg₂, arg₃) }
}

// MARK: - Parting quaternaries

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _     : ·
) -> (B, C, D) -> E {
  return { arg₂, arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _     : ·
) -> (A, C, D) -> E {
  return { arg₁, arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _     : ·
) -> (A, B, D) -> E {
  return { arg₁, arg₂, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _     : ·,
  _     : ·,
  _ arg₄: D
) -> (A, B, C) -> E {
  return { arg₁, arg₂, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _     : ·
) -> (C, D) -> E {
  return { arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C,
  _     : ·
) -> (B, D) -> E {
  return { arg₂, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _ arg₄: D
) -> (B, C) -> E {
  return { arg₂, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·
) -> (D) -> E {
  return { arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D
) -> (C) -> E {
  return { arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D
) -> (B) -> E {
  return { arg₂ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _ arg₄: D
) -> (A) -> E {
  return { arg₁ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D
) -> (A, B) -> E {
  return { arg₁, arg₂ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D
) -> (A, C) -> E {
  return { arg₁, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E>(
  _ ƒ   : @escaping (A, B, C, D) -> E,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·
) -> (A, D) -> E {
  return { arg₁, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄) }
}

// MARK: - Parting quinaries

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _     : ·,
  _     : ·
) -> (B, C, D, E) -> F {
  return { arg₂, arg₃, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _     : ·,
  _     : ·
) -> (A, C, D, E) -> F {
  return { arg₁, arg₃, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _     : ·,
  _     : ·
) -> (A, B, D, E) -> F {
  return { arg₁, arg₂, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _     : ·,
  _ arg₄: D,
  _     : ·
) -> (A, B, C, E) -> F {
  return { arg₁, arg₂, arg₃, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _     : ·,
  _     : ·,
  _ arg₅: E
) -> (A, B, C, D) -> F {
  return { arg₁, arg₂, arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _     : ·,
  _     : ·
) -> (C, D, E) -> F {
  return { arg₃, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C,
  _     : ·,
  _     : ·
) -> (B, D, E) -> F {
  return { arg₂, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _ arg₄: D,
  _     : ·
) -> (B, C, E) -> F {
  return { arg₂, arg₃, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _     : ·,
  _ arg₅: E
) -> (B, C, D) -> F {
  return { arg₂, arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·,
  _     : ·
) -> (D, E) -> F {
  return { arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D,
  _     : ·
) -> (C, E) -> F {
  return { arg₃, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D,
  _     : ·
) -> (B, E) -> F {
  return { arg₂, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _     : ·,
  _ arg₅: E
) -> (C, D) -> F {
  return { arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _ arg₃: C,
  _ arg₄: D,
  _     : ·
) -> (E) -> F {
  return { arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·,
  _ arg₅: E
) -> (D) -> F {
  return { arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _ arg₄: D,
  _     : ·
) -> (A, E) -> F {
  return { arg₁, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·,
  _ arg₅: E
) -> (A, D) -> F {
  return { arg₁, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D,
  _     : ·
) -> (A, B, E) -> F {
  return { arg₁, arg₂, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _     : ·,
  _ arg₅: E
) -> (A, B, D) -> F {
  return { arg₁, arg₂, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _     : ·,
  _ arg₄: D,
  _ arg₅: E
) -> (A, B, C) -> F {
  return { arg₁, arg₂, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D,
  _ arg₅: E
) -> (A, B) -> F {
  return { arg₁, arg₂ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D,
  _ arg₅: E
) -> (A, C) -> F {
  return { arg₁, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _     : ·,
  _ arg₄: D,
  _ arg₅: E
) -> (B, C) -> F {
  return { arg₂, arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _ arg₄: D,
  _ arg₅: E
) -> (A) -> F {
  return { arg₁ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _     : ·,
  _ arg₃: C,
  _ arg₄: D,
  _ arg₅: E
) -> (B) -> F {
  return { arg₂ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _ arg₁: A,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D,
  _ arg₅: E
) -> (C) -> F {
  return { arg₃ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _ arg₃: C,
  _     : ·,
  _     : ·
) -> (A, D, E) -> F {
  return { arg₁, arg₄, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _ arg₄: D,
  _     : ·
) -> (A, C, E) -> F {
  return { arg₁, arg₃, arg₅ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

/// Takes a function ƒ and fewer than the normal arguments to ƒ, and returns a
/// new function that takes a variable number of additional arguments. When
/// called, the returned function calls ƒ with arguments × additional arguments.
@_transparent
public func partial<A, B, C, D, E, F>(
  _ ƒ   : @escaping (A, B, C, D, E) -> F,
  _     : ·,
  _ arg₂: B,
  _     : ·,
  _     : ·,
  _ arg₅: E
) -> (A, C, D) -> F {
  return { arg₁, arg₃, arg₄ in ƒ(arg₁, arg₂, arg₃, arg₄, arg₅) }
}

// MARK: - Operator sections

// MARK: Equality

public func == <A: Equatable>(lhs: A, _: ·) -> (A) -> Bool {
  return partial(lhs, ==, __)
}

public func == <A: Equatable>(__: ·, rhs: A) -> (A) -> Bool {
  return partial(__, ==, rhs)
}

public func != <A: Equatable>(_: ·, rhs: A) -> (A) -> Bool {
  return partial(__, !=, rhs)
}

public func != <A: Equatable>(lhs: A, _: ·) -> (A) -> Bool {
  return partial(lhs, !=, __)
}

public func == (_: ·, _: Nil) -> (Any?) -> Bool {
  return partial(__, ==, nil)
}

public func != (_: ·, _: Nil) -> (Any?) -> Bool {
  return partial(__, !=, nil)
}

public func == (_: Nil, _: ·) -> (Any?) -> Bool {
  return partial(nil, ==, __)
}

public func != (_: Nil, _: ·) -> (Any?) -> Bool {
  return partial(nil, !=, __)
}

// MARK: Identity

public func === <A: AnyObject>(_: ·, rhs: A) -> (A) -> Bool {
  return partial(__, ===, rhs)
}

public func === <A: AnyObject>(lhs: A, _: ·) -> (A) -> Bool {
  return partial(lhs, ===, __)
}

public func !== <A: AnyObject>(_: ·, rhs: A) -> (A) -> Bool {
  return partial(__, !==, rhs)
}

public func !== <A: AnyObject>(lhs: A, _: ·) -> (A) -> Bool {
  return partial(lhs, !==, __)
}

// MARK: Composition

public func >>> <A, B, C>(
  _  : ·,
  _ g: @escaping (B) -> C)
  -> (_ ƒ: @escaping (A) -> B)
  -> (A) -> C {
    return partial(__, >>>, g)
}

public func >>> <A, B, C>(
  _ ƒ: @escaping (A) -> B,
  _  : ·)
  -> (_ g: @escaping (B) -> C)
  -> (A) -> C {
    return partial(ƒ, >>>, __)
}

public func <<< <A, B, C>(
  _  : ·,
  _ ƒ: @escaping (A) -> B)
  -> (_ g: @escaping (B) -> C)
  -> (A) -> C {
    return partial(__, <<<, ƒ)
}

public func <<< <A, B, C>(
  _ g: @escaping (B) -> C,
  _  : ·)
  -> (_ ƒ: @escaping (A) -> B)
  -> (A) -> C {
    return partial(g, <<<, __)
}

@_transparent
public func • <A, B, C>(
  _ ƒ: @escaping (B) -> C,
  _  : ·)
  -> (_ g: @escaping (A) -> B)
  -> (A) -> C {
    return partial(ƒ, •, __)
}

@_transparent
public func • <A, B, C>(
  _  : ·,
  _ g: @escaping (A) -> B)
  -> (_ ƒ: @escaping (B) -> C)
  -> (A) -> C {
    return partial(__, •, g)
}
