import Swift

infix operator ⊢ : TernaryPrecedence // IMPLY

public let imply = (⊢)

extension Bool {

  /// Performs a logical `IMPLY` operation on two Boolean values.
  ///
  /// A logical consequence describes the relationship between statements that
  /// hold true when one statement logically follows from one or more
  /// statements.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side of the operation.
  ///   - rhs: The right-hand side of the operation.
  @_transparent
  public func implies(_ q: @autoclosure () -> Bool) -> Bool {
    !self || q()
  }

  /// Performs a logical `IMPLY` operation on two Boolean values, equivalent
  /// by DeMorgan's to: `!p || q`.
  ///
  /// A logical implication describes the relationship between statements that
  /// hold `true` when **antecedent** (the statement on the left-hand side `p`)
  /// is **sufficient** to conclude that the **consequent** (the statement on
  /// the right-hand side `q`), without necessarily stating a causal relation
  /// between the statement.
  ///
  /// Equivalently, it can be stated as a relationship where the *consequent*
  /// is a **requirement** of the *antecedent*.
  ///
  /// ### Truth table
  ///
  /// The truth table associated with the material implication `p ⊢ q` is
  /// identical to that of `¬p v q`.
  ///
  ///     ┏───┳───┳───────┓
  ///     │ p │ q │ p ⊢ q │
  ///     ┣───╋───╋───────┫
  ///     │ T │ T │   T   │
  ///     │ T │ F │   F   │
  ///     │ F │ T │   T   │
  ///     │ F │ F │   T   │
  ///     ┗───┻───┻───────┛
  ///
  /// ### Example
  ///
  /// In the context of a URL request, we can express:
  ///
  ///     assert(httpMethod == .PUT |- body != nil)
  ///
  /// The example above clearly expresses the expectation that a `.PUT` HTTP
  /// method **must entail** the existence of a body, but a body does **not**
  /// require that the HTTP method be `.PUT`.
  ///
  /// The non-`IMPLY` equivalent is:
  ///
  ///     assert(httpMethod != .PUT || body != nil)
  ///
  /// The statement above very clearly expresses agony and despair, ain't
  /// nobody got time for that, nor to mentally decode this logical perversion,
  /// with the exception of perhaps a mathematician.
  ///
  /// Use `⊢` and find solace in that at least something in your life makes
  /// sense.
  ///
  /// - See also:
  ///   https://en.wikipedia.org/wiki/Material_conditional
  @_transparent
  public static func ⊢ (p: Bool, q: Bool) -> Bool {
    p.implies(q)
  }
}


