// Set algebraic operations for equational reasoning.
import Foundation
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGPoint

/// ╌╌╌───────────────────────────────────────╌───────────┳────┳───┳────────────────────┓
///  Fundamental operations                            uni│ mx │op.│notes               │
infix operator × : MultiplicationPrecedence    // ʟ₇    ⌥P│ ⌥X │ * │cartesian product   │
infix operator ⊔ : AdditionPrecedence          // ʟ₆ ⌥2294│ ⌥U │ + │disjoint union      │
infix operator ∖ : AdditionPrecedence          // ʟ₆ ⌥2216│ ⌥\ │ - │relative complement │
infix operator ∩ : LogicalConjunctionPrecedence// ʟ₃ ⌥2229│ ⌥i │ & │intersection        │
infix operator ∪ : LogicalDisjunctionPrecedence// ʟ₂ ⌥222A│ ⌥u │ | │union               │
infix operator ∆ : LogicalDisjunctionPrecedence// ʟ₂    ⌥J│ ⌥D │ ^ │symmetric difference│
/// Assignment  ╌╌╌───────────────────────────╌───────────╋────╋───╋────────────────────┫
infix operator ∩=: AssignmentPrecedence        // ʀ₀      │ ⌥i │&= │form intersection   │
infix operator ∪=: AssignmentPrecedence        // ʀ₀      │ ⌥u │|= │form union          │
infix operator ∆=: AssignmentPrecedence        // ʀ₀      │ ⌥D │^= │form symmetric diff.│
infix operator ∖=: AssignmentPrecedence        // ʀ₀      │ ⌥\ │-= │substract           │
/// Relation    ╌╌╌───────────────────────────╌───────────╋────╋───╋────────────────────┫
infix operator<=>: ComparisonPrecedence        //  ₄      │    │<=>│2-way comparison    │
infix operator ⊂ : ComparisonPrecedence        //  ₄ ⌥2282│^⌥< │ < │strict subset       │
infix operator ⊆ : ComparisonPrecedence        //  ₄ ⌥2286│⌥_⊂ │ ≤ │subset              │
infix operator ⊃ : ComparisonPrecedence        //  ₄ ⌥2283│^⌥> │ > │strict superset     │
infix operator ⊇ : ComparisonPrecedence        //  ₄ ⌥2287│⌥_⊃ │ ≥ │superset            │
/// Membership  ╌╌╌───────────────────────────╌───────────╋────╋───╋────────────────────┫
prefix operator ∈                              //    ⌥2208│⌥ee │   │element of          │
infix operator  ∈ : ComparisonPrecedence       //  ₄ ⌥2208│⌥ee │   │element of          │
infix operator !∈ : ComparisonPrecedence       //  ₄ ⌥2208│⌥/e │   │not an element of   │
prefix operator ∋                              //    ⌥2208│⌥c  │   │element of          │
infix operator  ∋ : ComparisonPrecedence       //  ₄ ⌥2208│⌥eE │   │contains            │
infix operator !∋ : ComparisonPrecedence       //  ₄ ⌥2208│⌥/c │   │does not contain    │
/// Quantification   ╌╌╌──────────────────────╌───────────╋────╋───╋────────────────────┫
prefix operator ∀                              //    ⌥2200│ ⌥A │   │for all             │
prefix operator ∃                              //    ⌥2203│ ⌥E │   │for any/some        │
prefix operator ∃!                             //    ⌥2203│ ⌥E │   │for only one        │
prefix operator ∄                              //    ⌥2204│⌥/E │   │for none            │
/// ╌╌╌───────────────────────────────────────╌───────────┻────┻───┻────────────────────┛

infix operator ∙ : ComparisonPrecedence

// MARK: - Quantifiers

/// Annotates a given function as a predicate.
///
/// Annotate the predicate portion of the quantification formula denoted by
/// `∀α∈A ∙ 𝑃(α)` where ∀ is any quantifier and P a predicate on the set of
/// values of type `A`.
///
///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
///     ∀names ∙ P { $0.count >= 5 } // == true
///
/// - Remark: The function generic annotation may also provide more context
///   in cases where the type of the collection to quantify can't be inferred.
/// - Parameter ρ: The predicate being annotated.
/// - Returns: The predicate as is, for evaluation by a quantifier.
@_transparent
public func P <T>(
  _ ρ: @escaping (T) -> Bool
) -> (T) -> Bool {
  return ρ
}

@_transparent
public func ∙ <T>(
  _ map: ((T) -> Bool) -> Bool,
  _ ρ: @escaping (T) -> Bool
) -> Bool {
  return map(ρ)
}

///// ∃Type.self∈sequence
//@inlinable
//public prefix func ∃<S: Membership>(
//  x: S.Element
//) -> (S) -> (S.Element) -> Bool {
//  return map(S.contains)
//}
//
//@inlinable
//public prefix func ∃<S: Collection, A>(
//  x: S.Element
//) -> (S) -> (A.Type) -> Bool where S.Element == A {
//  return { xs in { _ in xs.contains(where: T<A>.is) } }
//}
//
///// ∀Type.self∈sequence
//@inlinable
//public prefix func ∃<S: Sequence>(
//  x: S.Element
//) -> (S) throws -> (S.Element) throws -> Bool {
//  return map(S.allSatisfy)
//}

extension Sequence {


  /// Returns the number of elements in the sequence that satisfy the given
  /// predicate.
  ///
  /// You can use this method to count the number of elements that pass a test.
  /// For example, this code finds the number of names that are fewer than
  /// five characters long:
  ///
  ///     let names = ["Jacqueline", "Ian", "Amy", "Juan", "Soroush", "Tiffany"]
  ///     let shortNameCount = names.count(where: { $0.count < 5 })
  ///     // shortNameCount == 3
  ///
  /// To find the number of times a specific element appears in the sequence,
  /// use the equal-to operator (`==`) in the closure to test for a match.
  ///
  ///     let birds = ["duck", "duck", "duck", "duck", "goose"]
  ///     let duckCount = birds.count(where: { $0 == "duck" })
  ///     // duckCount == 4
  ///
  /// The sequence must be finite.
  ///
  /// - Parameter predicate: A closure that takes each element of the sequence
  ///   as its argument and returns a Boolean value indicating whether
  ///   the element should be included in the count.
  /// - Returns: The number of elements in the sequence that satisfy the given
  ///   predicate.
  @inlinable
  public func count(
    where P: (Element) -> Bool
  ) -> Int {
    return reduce(into: 0) { xs, x in xs += Int(P(x)) }
  }
}

extension Int {

  /// Counting quantifier
  @inlinable
  public static prefix func ∃<S: Collection>(
    k: Int
  ) -> (_ xs: S
  ) -> (_ ρ: @escaping (S.Element) -> (Bool)
  ) -> Bool where S: Monoid, S.Element: Monoid {
    return { xs in equals(k) • xs.count }
  }
}

extension Sequence {

  /// ∀ ∎ Returns a Boolean value indicating whether every element of a
  /// sequence satisfies a given predicate.
  ///
  /// Pronounced "such that all", "for all", or simply "all", the universal
  /// quantfier `∀` evaluates every element of a given set such that:
  ///
  ///     ∀𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// The following code uses this method to test whether all the names in an
  /// array have at least five characters:
  ///
  ///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
  ///     ∀names ∙ 𝑃 { $0.count >= 5 } // == true
  ///
  /// - Parameters:
  ///   - η: Eta ascribes the indiscernible identity of themselves through
  ///        the extensionality principle, or, the sequence to check.
  ///   - ρ: A closure that takes an element of the sequence as its argument
  ///        and returns a `Boolean` value that indicates whether the passed
  ///        element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static prefix func ∀(xs: Self) -> ((Element) -> Bool) -> Bool  {
    return { xs.allSatisfy($0) }
  }

  /// ∃ ∎ Returns a Boolean value indicating whether the sequence contains an
  /// element that satisfies the given predicate.
  ///
  /// Pronounced "there exists", "for some/any", or simply "any", the
  /// existential quantfier `∃` evaluates every element of a given set such
  /// that:
  ///
  ///     ∃𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// Read as "there exists an 𝑎 in 𝐴 that satisfies the predicate P".
  ///
  /// You can use the predicate to check for an element of a type that
  /// doesn't conform to the `Equatable` protocol, such as the `HTTPResponse`
  /// enumeration in this example.
  ///
  ///     enum HTTPResponse {
  ///         case ok
  ///         case error(Int)
  ///     }
  ///
  ///     let responses = [.ok, .ok, .error(404)] as [HTTPResponse]
  ///     ∃responses ∙ P { if case .error = $0 { true } else { false } }
  ///     // ∃ evaluates to true
  ///
  /// Read as "for some response that is .error".
  ///
  /// Alternatively, a predicate can be satisfied by a bounded quantification,
  /// such as a range of `Equatable` elements or a general condition. This
  /// example shows how you can check an array for an expense greater than
  /// $100.
  ///
  ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
  ///     ∃expenses > 100 // true
  ///
  /// Read as "any expense greater than 100".
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static prefix func ∃(xs: Self) -> ((Element) -> Bool) -> Bool  {
    return { xs.contains(where: $0) }
  }

  /// ∃! ∎ Returns a Boolean value indicating whether one and only one
  /// element of a sequence satisfies a given predicate.
  ///
  /// Pronounced "there is one and only one", "for exactly one", or simply
  /// "only one", the uniqueness quantfier `∃!` evaluates every element of a
  /// given set such that:
  ///
  ///     ∃x(P(x) ∧ ∄y(P(y) ∧ x ≠ y)
  ///
  /// The following code uses this method to test whether any of the names in
  /// the array repeats:
  ///
  ///     let names = ["Sofia", "Camilla", "Sofia", "Mateo", "Nicolás"]
  ///     let distinct = (∀names ∙ { name in ∃!names ∙ { $0 == name } }
  ///     // distinct == false
  ///
  /// - Parameters:
  ///   - xs: Ascribes extensionality as the principle over the indiscernible
  ///     identity of the individual entity in its universe; is what a
  ///     mathematician would probably say instead of "an array."
  ///   - predicate: A closure that takes an element of the sequence as its
  ///     argument and returns a `Boolean` value that indicates whether the
  ///     passed element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static prefix func ∃!(xs: Self) -> ((Element) -> Bool) -> Bool  {
    return { ρ in
      var it = xs.lazy.filter(ρ).makeIterator()
      return it.next().hasSome && it.next().isNil
    }
  }

  /// ∄ ∎ Returns a Boolean value indicating whether no element of a sequence
  /// satisfies a given predicate.
  ///
  /// Pronounced "such that none", "for no", or simply "no", the negation of
  /// the universal quantfier `∄` evaluates every element of a given set such
  /// that:
  ///
  ///     ∄𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// The following code uses this method to test that none of the names in an
  /// array are longer than some character limit:
  ///
  ///     let characterLimit = 10
  ///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
  ///     ∄names ∙ P { $0.count > characterLimit } // == true
  ///
  /// - Parameters:
  ///   - η: Eta ascribes the indiscernible identity of themselves through
  ///        the extensionality principle, or, the sequence to check.
  ///   - ρ: A closure that takes an element of the sequence as its argument
  ///        and returns a `Boolean` value that indicates whether the passed
  ///        element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static prefix func ∄(xs: Self) -> ((Element) -> Bool) -> Bool  {
    return { ρ in not(xs.contains(where: ρ)) }
  }

  /// ∀ ∎ Returns a Boolean value indicating whether every element of a
  /// sequence satisfies a given predicate.
  ///
  /// Pronounced "such that all", "for all", or simply "all", the universal
  /// quantfier `∀` evaluates every element of a given set such that:
  ///
  ///     ∀𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// The following code uses this method to test whether all the names in an
  /// array have at least five characters:
  ///
  ///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
  ///     ∀names ∙ P { $0.count >= 5 } // == true
  ///
  /// - Parameters:
  ///   - η: Eta ascribes the indiscernible identity of themselves through
  ///        the extensionality principle, or, the sequence to check.
  ///   - ρ: A closure that takes an element of the sequence as its argument
  ///        and returns a `Boolean` value that indicates whether the passed
  ///        element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func all(satisfy ρ: (Element) -> Bool) -> Bool {
    return (∀self) (ρ)
  }

  /// ∃ ∎ Returns a Boolean value indicating whether the sequence contains an
  /// element that satisfies the given predicate.
  ///
  /// Pronounced "there exists", "for some/any", or simply "any", the
  /// existential quantfier `∃` evaluates every element of a given set such
  /// that:
  ///
  ///     ∃𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// Read as "there exists an 𝑎 in 𝐴 that satisfies the predicate P".
  ///
  /// You can use the predicate to check for an element of a type that
  /// doesn't conform to the `Equatable` protocol, such as the `HTTPResponse`
  /// enumeration in this example.
  ///
  ///     enum HTTPResponse {
  ///         case ok
  ///         case error(Int)
  ///     }
  ///
  ///     let responses = [.ok, .ok, .error(404)] as [HTTPResponse]
  ///     ∃responses ∙ P { if case .error = $0 { true } else { false } }
  ///     // ∃ evaluates to true
  ///
  /// Read as "for some response that is .error".
  ///
  /// Alternatively, a predicate can be satisfied by a bounded quantification,
  /// such as a range of `Equatable` elements or a general condition. This
  /// example shows how you can check an array for an expense greater than
  /// $100.
  ///
  ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
  ///     ∃expenses > 100 // true
  ///
  /// Read as "any expense greater than 100".
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func any(satisfies ρ: (Element) -> Bool) -> Bool {
    return (∃self) (ρ)
  }

  /// ∃2 ∎ Returns a Boolean value indicating whether the sequence contains
  /// _two or more_ elements that satisfy the given predicate.
  ///
  /// Pronounced "there exists", "for some/any", or simply "any", the
  /// existential quantfier `∃` evaluates every element of a given set such
  /// that:
  ///
  ///     ∃𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// Read as "there exists an 𝑎 in 𝐴 that satisfies the predicate P".
  ///
  /// You can use the predicate to check for an element of a type that
  /// doesn't conform to the `Equatable` protocol, such as the `HTTPResponse`
  /// enumeration in this example.
  ///
  ///     enum HTTPResponse {
  ///         case ok
  ///         case error(Int)
  ///     }
  ///
  ///     let responses = [.ok, .ok, .error(404)] as [HTTPResponse]
  ///     ∃responses ∙ P { if case .error = $0 { true } else { false } }
  ///     // ∃ evaluates to true
  ///
  /// Read as "for some response that is .error".
  ///
  /// Alternatively, a predicate can be satisfied by a bounded quantification,
  /// such as a range of `Equatable` elements or a general condition. This
  /// example shows how you can check an array for an expense greater than
  /// $100.
  ///
  ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
  ///     ∃expenses > 100 // true
  ///
  /// Read as "any expense greater than 100".
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func some(satisfy ρ: (Element) -> Bool) -> Bool {
    return count(where: ρ) > 1
  }

  /// ∃! ∎ Returns a Boolean value indicating whether one and only one
  /// element of a sequence satisfies a given predicate.
  ///
  /// Pronounced "there is one and only one", "for exactly one", or simply
  /// "only one", the uniqueness quantfier `∃!` evaluates every element of a
  /// given set such that:
  ///
  ///     ∃𝑥(P(𝑥) ∧ ∄𝑦(P(𝑦) ∧ 𝑥 ≠ 𝑦)
  ///
  /// The following code uses this method to test whether any of the names in
  /// the array repeats:
  ///
  ///     let names = ["Sofia", "Camilla", "Sofia", "Mateo", "Nicolás"]
  ///     let distinct = (∀names ∙ { name in ∃!names ∙ { $0 == name } }
  ///     // distinct == false
  ///
  /// - Parameters:
  ///   - η: Eta ascribes the indiscernible identity of themselves through
  ///        the extensionality principle, or, the sequence to check.
  ///   - ρ: A closure that takes an element of the sequence as its argument
  ///        and returns a `Boolean` value that indicates whether the passed
  ///        element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func onlyOne(satisfies ρ: @escaping (Element) -> Bool) -> Bool {
    return ∃!self ∙ P(ρ)
  }

  /// ∄ ∎ Returns a Boolean value indicating whether no element of a sequence
  /// satisfies a given predicate.
  ///
  /// Pronounced "such that none", "for no", or simply "no", the negation of
  /// the universal quantfier `∄` evaluates every element of a given set such
  /// that:
  ///
  ///     ∄𝑎∈𝐴 ∙ 𝑃(α)
  ///
  /// The following code uses this method to test that none of the names in an
  /// array are longer than some character limit:
  ///
  ///     let characterLimit = 10
  ///     let names = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
  ///     ∄names ∙ P { $0.count > characterLimit } // == true
  ///
  /// - Parameters:
  ///   - η: Eta ascribes the indiscernible identity of themselves through
  ///        the extensionality principle, or, the sequence to check.
  ///   - ρ: A closure that takes an element of the sequence as its argument
  ///        and returns a `Boolean` value that indicates whether the passed
  ///        element satisfies a condition.
  /// - Returns: `true` if the sequence contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func none(satisfies ρ: @escaping (Element) -> Bool) -> Bool {
    return ∄self ∙ P(ρ)
  }
}

// MARK: Pair

/// Universal quantifier
@_transparent
public prefix func ∀ <A>(_ pair: (A, A)) -> ((A) -> Bool) -> Bool {
  return { ρ in ρ(pair.0) && ρ(pair.1) }
}

/// Existential quantifier
@_transparent
public prefix func ∃ <A>(_ pair: (A, A)) -> ((A) -> Bool) -> Bool {
  return { ρ in ρ(pair.0) || ρ(pair.1) }
}

/// Nonexistence quantifier
@_transparent
public prefix func ∄ <A>(_ pair: (A, A)) -> ((A) -> Bool) -> Bool {
  return { ρ in !ρ(pair.0) && !ρ(pair.1) }
}

@inlinable
public func both<A>(
  _ pair: (A, A),
  _ P: (A) -> Bool
) -> Bool {
  return (∀pair)(P)
}

@inlinable
public func either<A>(
  _ pair: (A, A),
  _ P: (A) -> Bool
) -> Bool {
  return (∃pair)(P)
}

@inlinable
public func neither<A>(
  _ pair: (A, A),
  _ P: (A) -> Bool
) -> Bool {
  return (∄pair)(P)
}

// MARK: -
// MARK: - Membership

extension Membership {

  /// Returns a Boolean value that indicates whether the given element exists
  /// in the set.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is an element of the set.
  @_transparent
  public static func ∈ (x: Element, xs: Self) -> Bool {
    xs.contains(x)
  }

  /// Returns a Boolean value that indicates whether the given element does
  /// not exist in the set.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is **not** an element of the set.
  @_transparent
  public static func !∈ (x: Element, xs: Self) -> Bool {
    !(x ∈ xs)
  }

  /// Returns a Boolean value that indicates whether the given element exists
  /// in the set.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is an element of the set.
  @_transparent
  public static func ∋ (xs: Self, x: Element) -> Bool {
    x ∈ xs
  }

  /// Returns a Boolean value that indicates whether the given element does
  /// not exist in the set.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is **not** an element of the set.
  @_transparent
  public static func !∋ (xs: Self, x: Element) -> Bool {
    !(x ∈ xs)
  }
}

/// Returns a predicate on `Element` over the given `Sequence` that indicates
/// whether a given element exists in said `Sequence`.
///
/// - Parameters:
///   - xs: The `Sequence` to build the predicate function on.
///   - element: An element to look for in the set.
/// - Returns: A predicate that will return `true` when given an element that
///   exists in the set, or `false` if it doesn't.
@_transparent
public prefix func ∈ <S: Membership> (
  _ xs: S
) -> (S.Element) -> Bool {
  curry(∋)(xs)
}

/// Returns a predicate on `Element` over the given `Sequence` that indicates
/// whether a given element exists in said `Sequence`.
///
/// - Parameters:
///   - xs: The `Sequence` to build the predicate function on.
///   - element: An element to look for in the set.
/// - Returns: A predicate that will return `true` when given an element that
///   exists in the set, or `false` if it doesn't.
@_transparent
public prefix func ∋ <S: Membership>(
  _ x: S.Element
) -> (S) -> Bool {
  curry(∈)(x)
}

extension Membership {

  /// Returns a Boolean value that indicates whether elements in a given set
  /// `xs` satisfy membership where total satisfiability is decided
  /// by a quantifier function `quantify`.
  ///
  /// Predicates are
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is an element of the set.
  public static func ∈ (
    quantify: @escaping (_ predicate: (Element) -> Bool) -> Bool,
    xs: Self
  ) -> Bool {
    return quantify(xs.contains)
  }

  /// Returns a Boolean value that indicates whether any element in a given set
  /// `xs`, is contained in a predicate mapping `pmap`.
  ///
  /// - Parameter member: An element to look for in the set.
  /// - Returns: True if `x` is **not** an element of the set.
  public static func !∈ (
    quantify: @escaping (_ predicate: (Element) -> Bool) -> Bool,
    xs: Self
  ) -> Bool {
    return quantify(flip(curry(!∈))(xs))
  }
}

// MARK: - Set Operations

extension SetAlgebra {

  /// A Boolean value that indicates whether the set has elements.
  public var hasElements: Bool {
    !isEmpty
  }
}

// MARK: - Static thunks

extension SetAlgebra {


  /// Inserts the given element in the set if it is not already present.
  ///
  /// If an element equal to `newMember` is already contained in the set, this
  /// method has no effect. In this example, a new element is inserted into
  /// `classDays`, a set of days of the week. When an existing element is
  /// inserted, the `classDays` set does not change.
  ///
  ///     enum DayOfTheWeek: Int {
  ///         case sunday, monday, tuesday, wednesday, thursday,
  ///             friday, saturday
  ///     }
  ///
  ///     var classDays: Set<DayOfTheWeek> = [.wednesday, .friday]
  ///     print(classDays.insert(.monday))
  ///     // Prints "(true, .monday)"
  ///     print(classDays)
  ///     // Prints "[.friday, .wednesday, .monday]"
  ///
  ///     print(classDays.insert(.friday))
  ///     // Prints "(false, .friday)"
  ///     print(classDays)
  ///     // Prints "[.friday, .wednesday, .monday]"
  ///
  /// - Parameter newMember: An element to insert into the set.
  /// - Returns: `(true, newMember)` if `newMember` was not contained in the
  ///   set. If an element equal to `newMember` was already contained in the
  ///   set, the method returns `(false, oldMember)`, where `oldMember` is the
  ///   element that was equal to `newMember`. In some cases, `oldMember` may
  ///   be distinguishable from `newMember` by identity comparison or some
  ///   other means.
  public static func insert(
    _ newMember: Element
  ) -> (inout Self) -> (inserted: Bool, memberAfterInsert: Self.Element) {
    return { $0.insert(newMember) }
  }

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// In the following example, the `attendeesAndVisitors` set is made up
  /// of the elements of the `attendees` and `visitors` sets:
  ///
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     let visitors = ["Marcia", "Nathaniel"]
  ///     let attendeesAndVisitors = attendees.union(visitors)
  ///     print(attendeesAndVisitors)
  ///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
  ///
  /// If the set already contains one or more elements that are also in
  /// `other`, the existing members are kept.
  ///
  ///     let initialIndices = Set(0..<5)
  ///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
  ///     print(expandedIndices)
  ///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set with the unique elements of this set and `other`.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  public static func union(_ other: __owned Self) -> (Self) -> Self {
    return { $0.union(other) }
  }

  /// Returns a new set with the elements that are common to both this set and
  /// the given set.
  ///
  /// In the following example, the `bothNeighborsAndEmployees` set is made up
  /// of the elements that are in *both* the `employees` and `neighbors` sets.
  /// Elements that are in only one or the other are left out of the result of
  /// the intersection.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let bothNeighborsAndEmployees = employees.intersection(neighbors)
  ///     print(bothNeighborsAndEmployees)
  ///     // Prints "["Bethany", "Eric"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  public static func intersection(_ other: Self) -> (Self) -> Self {
    return { $0.intersection(other) }
  }

  /// Returns a new set with the elements that are either in this set or in the
  /// given set, but not in both.
  ///
  /// In the following example, the `eitherNeighborsOrEmployees` set is made up
  /// of the elements of the `employees` and `neighbors` sets that are not in
  /// both `employees` *and* `neighbors`. In particular, the names `"Bethany"`
  /// and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
  ///     let eitherNeighborsOrEmployees = employees.symmetricDifference(neighbors)
  ///     print(eitherNeighborsOrEmployees)
  ///     // Prints "["Diana", "Forlani", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  public static func symmetricDifference(
    _ other: __owned Self
  ) -> (Self) -> Self {
    return { $0.symmetricDifference(other) }
  }

  /// Returns a new set containing the elements of this set that do not occur
  /// in the given set.
  ///
  /// In the following example, the `nonNeighbors` set is made up of the
  /// elements of the `employees` set that are not elements of `neighbors`:
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let nonNeighbors = employees.subtracting(neighbors)
  ///     print(nonNeighbors)
  ///     // Prints "["Diana", "Chris", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  public static func subtracting(
    _ other: Self
  ) -> (Self) -> Self {
    return { $0.subtracting(other) }
  }

  /// Returns a Boolean value that indicates whether the set is a subset of
  /// another set.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(attendees.isSubset(of: employees))
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  public static func isSubset(
    _ other: Self
  ) -> (Self) -> Bool {
    return { $0.isSubset(of: other) }
  }

  /// Returns a Boolean value that indicates whether the set has no members in
  /// common with the given set.
  ///
  /// In the following example, the `employees` set is disjoint with the
  /// `visitors` set because no name appears in both sets.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let visitors: Set = ["Marcia", "Nathaniel", "Olivia"]
  ///     print(employees.isDisjoint(with: visitors))
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set has no elements in common with `other`;
  ///   otherwise, `false`.
  public static func isDisjoint(
    _ other: Self
  ) -> (Self) -> Bool {
    return { $0.isDisjoint(with: other) }
  }

  /// Returns a Boolean value that indicates whether the set is a superset of
  /// the given set.
  ///
  /// Set *A* is a superset of another set *B* if every member of *B* is also a
  /// member of *A*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(employees.isSuperset(of: attendees))
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a superset of `possibleSubset`;
  ///   otherwise, `false`.
  public static func isSuperset(
    _ other: Self
  ) -> (Self) -> Bool {
    return { $0.isSuperset(of: other) }
  }

  /// A Boolean value that indicates whether the set has no elements.
  public static func isEmpty(_ set: Self) -> Bool {
    set.isEmpty
  }

  /// A Boolean value that indicates whether the set has elements.
  public static func hasElements(_ set: Self) -> Bool {
    set.hasElements
  }
}

/// Returns a new set with the elements of both this and the given set.
///
/// In the following example, the `attendeesAndVisitors` set is made up
/// of the elements of the `attendees` and `visitors` sets:
///
///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
///     let visitors = ["Marcia", "Nathaniel"]
///     let attendeesAndVisitors = attendees.union(visitors)
///     print(attendeesAndVisitors)
///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
///
/// If the set already contains one or more elements that are also in
/// `other`, the existing members are kept.
///
///     let initialIndices = Set(0..<5)
///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
///     print(expandedIndices)
///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
///
/// - Parameter other: A set of the same type as the current set.
/// - Returns: A new set with the unique elements of this set and `other`.
///
/// - Note: if this set and `other` contain elements that are equal but
///   distinguishable (e.g. via `===`), which of these elements is present
///   in the result is unspecified.
public func union<S: SetAlgebra>(_ other: __owned S) -> (S) -> S {
  return { $0.union(other) }
}

/// Returns a new set with the elements that are common to both this set and
/// the given set.
///
/// In the following example, the `bothNeighborsAndEmployees` set is made up
/// of the elements that are in *both* the `employees` and `neighbors` sets.
/// Elements that are in only one or the other are left out of the result of
/// the intersection.
///
///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
///     let bothNeighborsAndEmployees = employees.intersection(neighbors)
///     print(bothNeighborsAndEmployees)
///     // Prints "["Bethany", "Eric"]"
///
/// - Parameter other: A set of the same type as the current set.
/// - Returns: A new set.
///
/// - Note: if this set and `other` contain elements that are equal but
///   distinguishable (e.g. via `===`), which of these elements is present
///   in the result is unspecified.
public func intersection<S: SetAlgebra>(_ other: __owned S) -> (S) -> S {
  return { $0.intersection(other) }
}

/// Returns a new set with the elements that are either in this set or in the
/// given set, but not in both.
///
/// In the following example, the `eitherNeighborsOrEmployees` set is made up
/// of the elements of the `employees` and `neighbors` sets that are not in
/// both `employees` *and* `neighbors`. In particular, the names `"Bethany"`
/// and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
///
///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
///     let eitherNeighborsOrEmployees = employees.symmetricDifference(neighbors)
///     print(eitherNeighborsOrEmployees)
///     // Prints "["Diana", "Forlani", "Alicia"]"
///
/// - Parameter other: A set of the same type as the current set.
/// - Returns: A new set.
public func symmetricDifference<S: SetAlgebra>(_ other: __owned S) -> (S) -> S {
  return { $0.symmetricDifference(other) }
}

// MARK: - Arithmetic

extension SetAlgebra {

  // MARK: Intersection (AND)

  /// Returns a new set with the elements that are common to both this set and
  /// the given set.
  ///
  /// This is the set equivalent to a bitwise `and` operation.
  ///
  /// In the following example, the `bothNeighborsAndEmployees` set is made up
  /// of the elements that are in *both* the `employees` and `neighbors` sets.
  /// Elements that are in only one or the other are left out of the result of
  /// the intersection.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let bothNeighborsAndEmployees = employees & neighbors
  ///     print(bothNeighborsAndEmployees)
  ///     // Prints "["Bethany", "Eric"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  ///
  /// - Note: if `lhs` and `rhs` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func & (lhs: Self, rhs: Self) -> Self {
    return lhs ∩ rhs
  }

  /// Returns a new set with the elements that are common to both this set and
  /// the given set.
  ///
  /// This is the set equivalent to a bitwise `and` operation.
  ///
  /// In the following example, the `bothNeighborsAndEmployees` set is made up
  /// of the elements that are in *both* the `employees` and `neighbors` sets.
  /// Elements that are in only one or the other are left out of the result of
  /// the intersection.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let bothNeighborsAndEmployees = employees & neighbors
  ///     print(bothNeighborsAndEmployees)
  ///     // Prints "["Bethany", "Eric"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  ///
  /// - Note: if `lhs` and `rhs` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func &= (lhs: inout Self, rhs: Self) {
    lhs ∩= rhs
  }

  /// Returns a new set with the elements that are common to both this set and
  /// the given set.
  ///
  /// This is the set equivalent to a bitwise `and` operation.
  ///
  /// In the following example, the `bothNeighborsAndEmployees` set is made up
  /// of the elements that are in *both* the `employees` and `neighbors` sets.
  /// Elements that are in only one or the other are left out of the result of
  /// the intersection.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let bothNeighborsAndEmployees = employees & neighbors
  ///     print(bothNeighborsAndEmployees)
  ///     // Prints "["Bethany", "Eric"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  ///
  /// - Note: if `lhs` and `rhs` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func ∩ (lhs: Self, rhs: Self) -> Self {
    return lhs.intersection(rhs)
  }

  /// Returns a new set with the elements that are common to both this set and
  /// the given set.
  ///
  /// This is the set equivalent to a bitwise `and` operation.
  ///
  /// In the following example, the `bothNeighborsAndEmployees` set is made up
  /// of the elements that are in *both* the `employees` and `neighbors` sets.
  /// Elements that are in only one or the other are left out of the result of
  /// the intersection.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let bothNeighborsAndEmployees = employees & neighbors
  ///     print(bothNeighborsAndEmployees)
  ///     // Prints "["Bethany", "Eric"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  ///
  /// - Note: if `lhs` and `rhs` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func ∩= (lhs: inout Self, rhs: Self) {
    lhs.formIntersection(rhs)
  }

  // MARK: Union (OR)

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// This is the set equivalent to a bitwise `or` operation.
  ///
  /// In the following example, the `attendeesAndVisitors` set is made up
  /// of the elements of the `attendees` and `visitors` sets:
  ///
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     let visitors = ["Marcia", "Nathaniel"]
  ///     let attendeesAndVisitors = attendees.union(visitors)
  ///     print(attendeesAndVisitors)
  ///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
  ///
  /// If the set already contains one or more elements that are also in
  /// `other`, the existing members are kept.
  ///
  ///     let initialIndices = Set(0..<5)
  ///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
  ///     print(expandedIndices)
  ///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set with the unique elements of this set and `other`.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func | (lhs: Self, rhs: Self) -> Self {
    return lhs ∪ rhs
  }

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// This is the set equivalent to a bitwise `or` operation.
  ///
  /// In the following example, the `attendeesAndVisitors` set is made up
  /// of the elements of the `attendees` and `visitors` sets:
  ///
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     let visitors = ["Marcia", "Nathaniel"]
  ///     let attendeesAndVisitors = attendees.union(visitors)
  ///     print(attendeesAndVisitors)
  ///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
  ///
  /// If the set already contains one or more elements that are also in
  /// `other`, the existing members are kept.
  ///
  ///     let initialIndices = Set(0..<5)
  ///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
  ///     print(expandedIndices)
  ///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set with the unique elements of this set and `other`.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func |= (lhs: inout Self, rhs: Self) {
    lhs ∪= rhs
  }

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// This is the set equivalent to a bitwise `or` operation.
  ///
  /// In the following example, the `attendeesAndVisitors` set is made up
  /// of the elements of the `attendees` and `visitors` sets:
  ///
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     let visitors = ["Marcia", "Nathaniel"]
  ///     let attendeesAndVisitors = attendees.union(visitors)
  ///     print(attendeesAndVisitors)
  ///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
  ///
  /// If the set already contains one or more elements that are also in
  /// `other`, the existing members are kept.
  ///
  ///     let initialIndices = Set(0..<5)
  ///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
  ///     print(expandedIndices)
  ///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set with the unique elements of this set and `other`.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func ∪ (lhs: Self, rhs: Self) -> Self {
    return lhs.union(rhs)
  }

  /// Returns a new set with the elements of both this and the given set.
  ///
  /// This is the set equivalent to a bitwise `or` operation.
  ///
  /// In the following example, the `attendeesAndVisitors` set is made up
  /// of the elements of the `attendees` and `visitors` sets:
  ///
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     let visitors = ["Marcia", "Nathaniel"]
  ///     let attendeesAndVisitors = attendees.union(visitors)
  ///     print(attendeesAndVisitors)
  ///     // Prints "["Diana", "Nathaniel", "Bethany", "Alicia", "Marcia"]"
  ///
  /// If the set already contains one or more elements that are also in
  /// `other`, the existing members are kept.
  ///
  ///     let initialIndices = Set(0..<5)
  ///     let expandedIndices = initialIndices.union([2, 3, 6, 7])
  ///     print(expandedIndices)
  ///     // Prints "[2, 4, 6, 7, 0, 1, 3]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set with the unique elements of this set and `other`.
  ///
  /// - Note: if this set and `other` contain elements that are equal but
  ///   distinguishable (e.g. via `===`), which of these elements is present
  ///   in the result is unspecified.
  @_transparent
  public static func ∪= (lhs: inout Self, rhs: Self) {
    lhs.formUnion(rhs)
  }

  // MARK: Symmetric difference (XOR)

  /// Returns a new set with the elements that are either in this set or in
  /// the given set, but not in both.
  ///
  /// This is the set equivalent to a bitwise `xor` operation.
  ///
  /// In the following example, the `eitherNeighborsOrEmployees` set is made
  /// up of the elements of the `employees` and `neighbors` sets that are not
  /// in both `employees` *and* `neighbors`. In particular, the names
  /// `"Bethany"` and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
  ///     let eitherNeighborsOrEmployees = employees ∆ neighbors
  ///     print(eitherNeighborsOrEmployees)
  ///     // Prints "["Diana", "Forlani", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ^ (lhs: Self, rhs: Self) -> Self {
    return lhs ∆ rhs
  }

  /// Returns a new set with the elements that are either in this set or in
  /// the given set, but not in both.
  ///
  /// This is the set equivalent to a bitwise `xor` operation.
  ///
  /// In the following example, the `eitherNeighborsOrEmployees` set is made
  /// up of the elements of the `employees` and `neighbors` sets that are not
  /// in both `employees` *and* `neighbors`. In particular, the names
  /// `"Bethany"` and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
  ///     let eitherNeighborsOrEmployees = employees ∆ neighbors
  ///     print(eitherNeighborsOrEmployees)
  ///     // Prints "["Diana", "Forlani", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ^= (lhs: inout Self, rhs: Self) {
    lhs ∆= rhs
  }

  /// Returns a new set with the elements that are either in this set or in
  /// the given set, but not in both.
  ///
  /// This is the set equivalent to a bitwise `xor` operation.
  ///
  /// In the following example, the `eitherNeighborsOrEmployees` set is made
  /// up of the elements of the `employees` and `neighbors` sets that are not
  /// in both `employees` *and* `neighbors`. In particular, the names
  /// `"Bethany"` and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
  ///     let eitherNeighborsOrEmployees = employees ∆ neighbors
  ///     print(eitherNeighborsOrEmployees)
  ///     // Prints "["Diana", "Forlani", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ∆ (lhs: Self, rhs: Self) -> Self {
    return lhs.symmetricDifference(rhs)
  }

  /// Returns a new set with the elements that are either in this set or in
  /// the given set, but not in both.
  ///
  /// This is the set equivalent to a bitwise `xor` operation.
  ///
  /// In the following example, the `eitherNeighborsOrEmployees` set is made
  /// up of the elements of the `employees` and `neighbors` sets that are not
  /// in both `employees` *and* `neighbors`. In particular, the names
  /// `"Bethany"` and `"Eric"` do not appear in `eitherNeighborsOrEmployees`.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani"]
  ///     let eitherNeighborsOrEmployees = employees ∆ neighbors
  ///     print(eitherNeighborsOrEmployees)
  ///     // Prints "["Diana", "Forlani", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ∆= (lhs: inout Self, rhs: Self) {
    lhs.formSymmetricDifference(rhs)
  }

  // MARK: Relative complement (-)

  /// Returns a new set containing the elements of a set that do not occur
  /// in another set.
  ///
  /// In the following example, the `nonNeighbors` set is made up of the
  /// elements of the `employees` set that are not elements of `neighbors`:
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let nonNeighbors = employees - neighbors
  ///     print(nonNeighbors)
  ///     // Prints "["Diana", "Chris", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func - (lhs: Self, rhs: Self) -> Self {
    return lhs ∖ rhs
  }

  /// Returns a new set containing the elements of a set that do not occur
  /// in another set.
  ///
  /// In the following example, the `nonNeighbors` set is made up of the
  /// elements of the `employees` set that are not elements of `neighbors`:
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let nonNeighbors = employees - neighbors
  ///     print(nonNeighbors)
  ///     // Prints "["Diana", "Chris", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs ∖= rhs
  }

  /// Returns a new set containing the elements of a set that do not occur
  /// in another set.
  ///
  /// In the following example, the `nonNeighbors` set is made up of the
  /// elements of the `employees` set that are not elements of `neighbors`:
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let nonNeighbors = employees - neighbors
  ///     print(nonNeighbors)
  ///     // Prints "["Diana", "Chris", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ∖ (lhs: Self, rhs: Self) -> Self {
    return lhs.subtracting(rhs)
  }

  /// Returns a new set containing the elements of a set that do not occur
  /// in another set.
  ///
  /// In the following example, the `nonNeighbors` set is made up of the
  /// elements of the `employees` set that are not elements of `neighbors`:
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let neighbors: Set = ["Bethany", "Eric", "Forlani", "Greta"]
  ///     let nonNeighbors = employees - neighbors
  ///     print(nonNeighbors)
  ///     // Prints "["Diana", "Chris", "Alicia"]"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: A new set.
  @_transparent
  public static func ∖= (lhs: inout Self, rhs: Self) {
    lhs.subtract(rhs)
  }
}

// MARK: - Comparable

extension SetAlgebra where Self: Comparable {

  /// Returns a Boolean value that indicates whether this set is a strict
  /// subset of the given set.
  ///
  /// Set *A* is a strict subset of another set *B* if every member of *A* is
  /// also a member of *B* and *B* contains at least one element that is not a
  /// member of *A*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(attendees ⊂ employees)
  ///     // Prints "true"
  ///
  ///     // A set is never a strict subset of itself:
  ///     print(attendees ⊂ attendees)
  ///     // Prints "false"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a strict subset of `other`; otherwise,
  ///   `false`.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs ⊂ rhs
  }

  /// Returns a Boolean value that indicates whether this set is a strict
  /// subset of the given set.
  ///
  /// Set *A* is a strict subset of another set *B* if every member of *A* is
  /// also a member of *B* and *B* contains at least one element that is not a
  /// member of *A*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(attendees ⊂ employees)
  ///     // Prints "true"
  ///
  ///     // A set is never a strict subset of itself:
  ///     print(attendees ⊂ attendees)
  ///     // Prints "false"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a strict subset of `other`; otherwise,
  ///   `false`.
  public static func ⊂ (lhs: Self, rhs: Self) -> Bool {
    return lhs.isStrictSubset(of: rhs)
  }

  /// Returns a Boolean value that indicates whether the set is a subset of
  /// another set.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(attendees ⊆ employees)
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  public static func <= (lhs: Self, rhs: Self) -> Bool {
    return lhs ⊆ rhs
  }

  /// Returns a Boolean value that indicates whether the set is a subset of
  /// another set.
  ///
  /// Set *A* is a subset of another set *B* if every member of *A* is also a
  /// member of *B*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(attendees ⊆ employees)
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a subset of `other`; otherwise, `false`.
  public static func ⊆ (lhs: Self, rhs: Self) -> Bool {
    return lhs.isSubset(of: rhs)
  }

  /// Returns a Boolean value that indicates whether the set is a superset of
  /// the given set.
  ///
  /// Set *A* is a superset of another set *B* if every member of *B* is also a
  /// member of *A*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(employees ⊇ attendees)
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a superset of `possibleSubset`;
  ///   otherwise, `false`.
  public static func >= (lhs: Self, rhs: Self) -> Bool {
    return lhs ⊇ rhs
  }

  /// Returns a Boolean value that indicates whether the set is a superset of
  /// the given set.
  ///
  /// Set *A* is a superset of another set *B* if every member of *B* is also a
  /// member of *A*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(employees ⊇ attendees)
  ///     // Prints "true"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a superset of `possibleSubset`;
  ///   otherwise, `false`.
  public static func ⊇ (lhs: Self, rhs: Self) -> Bool {
    return lhs.isSuperset(of: rhs)
  }

  /// Returns a Boolean value that indicates whether this set is a strict
  /// superset of the given set.
  ///
  /// Set *A* is a strict superset of another set *B* if every member of *B* is
  /// also a member of *A* and *A* contains at least one element that is *not*
  /// a member of *B*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(employees ⊃ attendees)
  ///     // Prints "true"
  ///
  ///     // A set is never a strict superset of itself:
  ///     print(employees ⊃ employees)
  ///     // Prints "false"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a strict superset of `other`; otherwise,
  ///   `false`.
  public static func > (lhs: Self, rhs: Self) -> Bool {
    return lhs ⊃ rhs
  }

  /// Returns a Boolean value that indicates whether this set is a strict
  /// superset of the given set.
  ///
  /// Set *A* is a strict superset of another set *B* if every member of *B* is
  /// also a member of *A* and *A* contains at least one element that is *not*
  /// a member of *B*.
  ///
  ///     let employees: Set = ["Alicia", "Bethany", "Chris", "Diana", "Eric"]
  ///     let attendees: Set = ["Alicia", "Bethany", "Diana"]
  ///     print(employees ⊃ attendees)
  ///     // Prints "true"
  ///
  ///     // A set is never a strict superset of itself:
  ///     print(employees ⊃ employees)
  ///     // Prints "false"
  ///
  /// - Parameter other: A set of the same type as the current set.
  /// - Returns: `true` if the set is a strict superset of `other`; otherwise,
  ///   `false`.
  public static func ⊃ (lhs: Self, rhs: Self) -> Bool {
    return lhs.isStrictSuperset(of: rhs)
  }
}

// MARK: - Collection

extension Set {

  public func inserting(_ x: Element) -> Set {
    var xs = self
    xs.insert(x)
    return xs
  }
}

// MARK: - OptionSet.Iterator

extension OptionSet where RawValue: FixedWidthInteger {
  public typealias Iterator = OptionSetIterator<Self>

  public func makeIterator() -> Iterator {
    return .init(self)
  }
}

//@frozen // lazy-performance
public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol
  where Element.RawValue: FixedWidthInteger
{
  private let set: Element
  private var mask: Element.RawValue = 0b01
  private var bitPattern: Element.RawValue

  public init(_ set: Element) {
    self.set = set // copy on next()
    bitPattern = set.rawValue
  }

  public mutating func next() -> Element? {
    while bitPattern != 0 {
      defer { mask &*= 0b10 }
      guard bitPattern & mask != 0 else { continue }
      bitPattern &= ~mask
      return Element(rawValue: mask)
    }

    return .none
  }
}
