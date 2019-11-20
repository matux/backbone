import Swift

/// Precedence of logical operators:
///
/// ↓ `¬` NOT
/// ↓ `∧` AND
/// ↓ `∨` OR/XOR
/// ↓ `⊢` IMPLY
/// ↓ `≡` XNOR

prefix operator ¬ // Logical NOT
prefix operator ⊨ // Tautology
prefix operator ⊭ // Contradiction

infix operator ∧ : LogicalConjunctionPrecedence // Logical AND
infix operator ≡ : LogicalConjunctionPrecedence // Logical XNOR
infix operator ∨ : LogicalDisjunctionPrecedence // Logical OR
infix operator ≢ : LogicalDisjunctionPrecedence // Logical XOR

public let not = (¬)
public let and = (∧)
public let or  = (∨)
public let xor = (≢)
public let xnor = (≡)

public let isTrue = curry(==)(true)
public let isFalse = curry(==)(false)
public let insist = (¬)•(¬)

extension Bool {

  /// Initialize a boolean with an integer type using standard semantics
  /// across C-like languages, logic and mathematics; deriving the boolean
  /// from the truncated product of verity and the integer where any number
  /// will yield the multiplicative identity of the truth or the absorbing
  /// element shall annhiliate the truth and render falsity in its stead.
  ///
  /// True unless zero.
  ///
  /// - Parameter value: Integer to derive the boolean from.
  @_transparent
  public init<T: BinaryInteger>(_ value: T) {
    self = value != .zero
  }
}

extension Bool: ExpressibleByIntegerLiteral {

  /// Initialize a boolean with an integer type using standard semantics
  /// across C-like languages, logic and mathematics; deriving the boolean
  /// from the truncated product of verity and the integer where any number
  /// will yield the multiplicative identity of the truth or the absorbing
  /// element shall annhiliate the truth and render falsity in its stead.
  ///
  /// True unless zero.
  ///
  /// - Parameter value: Integer to derive the boolean from.
  @_transparent
  public init(integerLiteral value: Int) {
    self.init(value)
  }
}

extension Bool {

  /// Performs a logical `NOT` operation on a Boolean value.
  ///
  /// The logical `NOT` operator (`¬`) inverts a Boolean value. If the value is
  /// `⊤`, the result of the operation is `⊥`; if the value is `⊥`,
  /// the result is `⊤`.
  ///
  ///     var truth = ¬false
  ///     // truth is true
  ///
  /// - Parameter a: The Boolean value to negate.
  @_transparent
  public var not: Bool {
    ¬self
  }

  /// Performs a logical AND operation on two Boolean values.
  ///
  /// The logical AND operator (`&&`) combines two Boolean values and returns
  /// `true` if both of the values are `true`. If either of the values is
  /// `false`, the operator returns `false`.
  ///
  /// This operator uses short-circuit evaluation: The left-hand side (`lhs`) is
  /// evaluated first, and the right-hand side (`rhs`) is evaluated only if
  /// `lhs` evaluates to `true`.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the operation.
  ///   - rhs: The right-hand side of the operation.
  @_transparent
  public func and(_ b: @autoclosure () -> Bool) -> Bool {
    self && b()
  }

  /// Performs a logical OR operation on two Boolean values.
  ///
  /// The logical OR operator (`||`) combines two Boolean values and returns
  /// `true` if at least one of the values is `true`. If both values are
  /// `false`, the operator returns `false`.
  ///
  /// This operator uses short-circuit evaluation: The left-hand side (`lhs`) is
  /// evaluated first, and the right-hand side (`rhs`) is evaluated only if
  /// `lhs` evaluates to `false`.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the operation.
  ///   - rhs: The right-hand side of the operation.
  @_transparent
  public func or(_ b: @autoclosure () -> Bool) -> Bool {
    self || b()
  }

  /// Performs a logical XOR operation on two Boolean values.
  ///
  /// The logical XOR operator (`!=`) combines two Boolean values and returns
  /// `true` if at least one of the values is `true`, but not both. Or,
  /// equivalently, returns `true` when the values are distinct from each other.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the operation.
  ///   - rhs: The right-hand side of the operation.
  @_transparent
  public func xor(_ b: @autoclosure () -> Bool) -> Bool {
    self != b()
  }
}

extension Bool {

  /// Performs a logical `NOT` operation on a Boolean value.
  ///
  /// The logical `NOT` operator (`¬`) inverts a Boolean value. If the value is
  /// `true`, the result of the operation is `false`; if the value is `false`,
  /// the result is `true`.
  ///
  ///     var truth = ¬false
  ///     // truth is true
  ///
  /// - Parameter a: The Boolean value to negate.
  @_transparent
  public static prefix func ¬ (_ value: Bool) -> Bool {
    !value
  }

  /// Performs a logical AND operation on two Boolean values.
  ///
  /// The logical AND operator (`∧`) combines two Boolean values and returns
  /// `⊤` if both of the values are `⊤`. If either of the values is
  /// `⊥`, the operator returns `⊥`.
  ///
  /// This operator uses short-circuit evaluation: The left-hand side (`p`) is
  /// evaluated first, and the right-hand side (`q`) is evaluated only if
  /// `p` evaluates to `⊤`. For example:
  ///
  ///     let xs = [7.44, 6.51, 4.74, 5.88, 6.27, 6.12, 7.76]
  ///     let sum = xs.reduce(0, +)
  ///     when(xs ≠ ø ∧ sum ÷ xs.count < 6.5, print("Average is less than 6.5"))
  ///     // Prints "Average measurement is less than 6.5"
  ///
  /// In this example, `p` tests whether `measurements.count` is greater than
  /// zero. Evaluation of the `∧` operator is one of the following:
  ///
  /// - When `measurements.count` is equal to zero, `p` evaluates to `⊥`
  ///   and `q` is not evaluated, preventing a divide-by-zero error in the
  ///   expression `sum / Double(measurements.count)`. The result of the
  ///   operation is `⊥`.
  /// - When `measurements.count` is greater than zero, `p` evaluates to
  ///   `⊤` and `q` is evaluated. The result of evaluating `q` is the
  ///   result of the `∧` operation.
  ///
  /// - Parameters:
  ///   - p: The left-hand side of the operation.
  ///   - q: The right-hand side of the operation.
  @_transparent
  public static func ∧ (
    p: Bool,
    q: @autoclosure () throws -> Bool
  ) rethrows -> Bool {
    try p && q()
  }

  /// Performs a logical OR operation on two Boolean values.
  ///
  /// The logical OR operator (`∨`) combines two Boolean values and returns
  /// `⊤` if at least one of the values is `⊤`. If both values are
  /// `⊥`, the operator returns `⊥`.
  ///
  /// This operator uses short-circuit evaluation: The left-hand side (`p`) is
  /// evaluated first, and the right-hand side (`q`) is evaluated only if
  /// `p` evaluates to `⊥`. For example:
  ///
  ///     let (error, errors) = ("", { "An error.", "Another error." })
  ///     error == ø ∨ error !∈ errors
  ///       ? print("No errors detected")
  ///       : print("Error: \(error)")
  ///     // Prints "No errors detected"
  ///
  /// In this example, `p` tests whether `error` is an empty string.
  /// Evaluation of the `∨` operator is one of the following:
  ///
  /// - When `error` is an empty string, `p` evaluates to `⊤` and `q` is
  ///   not evaluated, skipping the call to `majorErrors.contains(_:)`. The
  ///   result of the operation is `⊤`.
  /// - When `error` is not an empty string, `p` evaluates to `⊥` and
  ///   `q` is evaluated. The result of evaluating `q` is the result of the
  ///   `∨` operation.
  ///
  /// - Parameters:
  ///   - p: The left-hand side of the operation.
  ///   - q: The right-hand side of the operation.
  @_transparent
  public static func ∨ (
    p: Bool,
    q: @autoclosure () throws -> Bool
  ) rethrows -> Bool {
    return try p || q()
  }

  /// Performs a logical XOR operation on two Boolean values.
  ///
  /// The logical XOR operator (`^^`) combines two Boolean values and returns
  /// `true` if either one of the values are `true`, but not both.
  ///
  /// - Note:
  /// There are both historical and practical reasons why there is no `^^`
  /// operator.
  ///
  /// ## The practical is:
  /// There's not much use for the operator. The main point of `&&` and `||`
  /// is to take advantage of their short-circuit evaluation not only for
  /// efficiency reasons, but more often for expressiveness and correctness.
  /// For example, in--
  ///
  ///     if (cond1() && cond2()) ...
  ///
  /// -- it is often important that `cond1()` is done first, because if it's
  /// false `cond2()` may not be well defined, or because `cond1()` is cheap
  /// and `cond2()` is expensive. Syntax to handle the situation has made it
  /// into lots of languages; compare Ada's `and then'.
  ///
  /// By contrast, an `^^` operator would always force evaluation of both arms
  /// of the expression, so there's no efficiency gain. Furthermore,
  /// situations in which `^^` is really called for are pretty rare, though
  /// examples can be created. These situations get rarer and stranger as you
  /// stack up the operator--
  ///
  ///     if (cond1() ^^ cond2() ^^ cond3() ^^ ...) ...
  ///
  /// -- does the consequent exactly when an odd number of the `condx()s` are
  /// `true`. By contrast, the `&&` and `||` analogs remain fairly plausible
  /// and useful.
  ///
  /// ## Historical:
  /// C's predecessors (B and BCPL) had only the bitwise versions of `|` `&`
  /// `^`. They also had a special rule, namely that in a statement like--
  ///
  ///     if (a & b) ...
  ///
  /// -- the `&`, being at the _top level_ of the expression occurring in
  /// _truth-value context_ (inside the `if()`) was interpreted just like C's
  /// `&&`. Similarly for `|`. But not so for `^`.
  ///
  /// One of the early bits of C evolution was the creation of separate `&&`
  /// and `||` operators. This was better than the special rule, which was
  /// hard to explain.
  ///
  /// In other words, the whole question arises because of the particular
  /// method of symmetry-breaking that C chose. Suppose I had reacted to the
  /// situation of BCPL and B taking their notion of `if (a & b) ...` and had
  /// people say `if (a) andif (b) ...` (and similarly with `orif`). One can
  /// make a case that this kind of syntax is better than `&&` and `||`. If
  /// it had happened, would people be asking for `xorif`? Probably not.
  ///
  /// My guess is that `&`, `&&`; `|`, `||`; `^`, `^^` is a _false symmetry_.
  /// But it's one that people seem to want, and, though it's not much help,
  /// adding it wouldn't do much harm.
  ///
  ///     - Dennis Ritchie, July 1995
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the operation.
  ///   - rhs: The right-hand side of the operation.
  /// - Returns: The result of the logical XOR operation;
  ///     `𝑝 ≠ 𝑞 ⟺ 𝑝 ⊻ 𝑞 ⟺ (¬𝑝 ∨ ¬𝑞) ∧ (𝑝 ∨ 𝑞)`
  @_transparent
  public static func ≢ (_ p: Bool, _ q: Bool) -> Bool {
    return p != q //(¬p ∨ ¬q) ∧ (p ∨ q)
  }

  @_transparent
  public static func ≡ (_ p: Bool, _ q: Bool) -> Bool {
    return p == q //(¬p ∧ ¬q) ∨ (p ∧ q)
  }
}

// MARK: - Comparable

extension Bool: Comparable {

  public static func < (lhs: Bool, rhs: Bool) -> Bool {
    return lhs == false && rhs == true
  }
}

// MARK: - KeyPath

extension KeyPath where Value == Bool {

  // MARK: And

  public static func && (
    path: KeyPath,
    value: Bool
  ) -> (Root) -> Bool {
    return { root in root[keyPath: path] && value }
  }

  public static func && (
    value: Bool,
    path: KeyPath
  ) -> (Root) -> Bool {
    return { root in value && root[keyPath: path] }
  }

  public static func && (
    pathₗ: KeyPath,
    pathᵣ: KeyPath
  ) -> (Root) -> Bool {
    return { root in root[keyPath: pathₗ] && root[keyPath: pathᵣ] }
  }

  public static func && (
    path: KeyPath,
    g: @escaping (Root) -> Bool
  ) -> (Root) -> Bool {
    return { root in root[keyPath: path] && g(root) }
  }

  public static func && (
    f: @escaping (Root) -> Bool,
    path: KeyPath
  ) -> (Root) -> Bool {
    return { root in f(root) && root[keyPath: path] }
  }

  // MARK: Or

  public static func || (
    path: KeyPath,
    value: Bool
  ) -> (Root) -> Bool {
    return { root in root[keyPath: path] || value }
  }

  public static func || (
    value: Bool,
    path: KeyPath
  ) -> (Root) -> Bool {
    return { root in value || root[keyPath: path] }
  }

  public static func || (
    pathₗ: KeyPath,
    pathᵣ: KeyPath
  ) -> (Root) -> Bool {
    return { root in root[keyPath: pathₗ] || root[keyPath: pathᵣ] }
  }

  public static func || (
    path: KeyPath,
    g: @escaping (Root) -> Bool
  ) -> (Root) -> Bool {
    return { root in root[keyPath: path] || g(root) }
  }

  public static func || (
    f: @escaping (Root) -> Bool,
    path: KeyPath
  ) -> (Root) -> Bool {
    return { root in f(root) || root[keyPath: path] }
  }
}

// MARK: - Function

public func && <Root>(
  f: @escaping (Root) -> Bool,
  g: @escaping (Root) -> Bool
) -> (Root) -> Bool {
  return { x in f(x) && g(x) }
}

public func || <Root>(
  f: @escaping (Root) -> Bool,
  g: @escaping (Root) -> Bool
) -> (Root) -> Bool {
  return { x in f(x) || g(x) }
}
