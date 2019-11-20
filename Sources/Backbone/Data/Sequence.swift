import Swift

// MARK: - Access

extension Collection {

  /// Safe Collection indexing.
  ///
  /// - Parameter index: The index to subscript.
  /// - Returns: The element at the given index or nil if out of bounds.
  @inlinable
  public subscript(safe index: Index) -> Element? {
    index < endIndex ? self[index] : .none
  }

  @inlinable
  public subscript(
    index: Index,
    or default: @autoclosure () -> Element
  ) -> Element {
    self[safe: index] ?? `default`()
  }

  /// Accesses the element at the specified position.
  ///
  /// The following example accesses an element of an array through its
  /// subscript to print its value:
  ///
  ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     print(streets[1])
  ///     // Prints "Bryant"
  ///
  /// You can subscript a collection with any valid index other than the
  /// collection's end index. The end index refers to the position one past
  /// the last element of a collection, so it doesn't correspond with an
  /// element.
  ///
  /// - Parameter i: The index of the element to access. `i` must be a valid
  ///   index of the collection that is not equal to the `endIndex` property.
  /// - Complexity: O(1)
  @_transparent
  public func at(_ i: Index) -> Element {
    self[i]
  }

  /// Safely accesses the element at the specified position returning `nil` in
  /// case of an out of bounds index.
  ///
  /// The following example accesses an element of an array through its
  /// subscript to print its value:
  ///
  ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     print("\(streets[1]), \(streets[999])")
  ///     // Prints "Bryant, nil"
  ///
  /// You can subscript a collection with any valid index other than the
  /// collection's end index. The end index refers to the position one past
  /// the last element of a collection, so it doesn't correspond with an
  /// element.
  ///
  /// - Parameter i: The index of the element to access. `i` must be a valid
  ///   index of the collection that is not equal to the `endIndex` property.
  /// - Complexity: O(1)
  @_transparent
  public func at(safe i: Index) -> Element? {
    self[safe: i]
  }

  /// Accesses a contiguous subrange of the collection's elements.
  ///
  /// For example, using a `PartialRangeFrom` range expression with an array
  /// accesses the subrange from the start of the range expression until the
  /// end of the array.
  ///
  ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     let streetsSlice = streets[2..<5]
  ///     print(streetsSlice)
  ///     // ["Channing", "Douglas", "Evarts"]
  ///
  /// The accessed slice uses the same indices for the same elements as the
  /// original collection. This example searches `streetsSlice` for one of the
  /// strings in the slice, and then uses that index in the original array.
  ///
  ///     let index = streetsSlice.firstIndex(of: "Evarts")!    // 4
  ///     print(streets[index])
  ///     // "Evarts"
  ///
  /// - Parameter range: A range of the collection's indices. The bounds of
  ///   the range must be valid indices of the collection.
  /// - Complexity: O(1)
  @_transparent
  public func `in`(_ range: Range<Index>) -> SubSequence {
    self[range]
  }
}

extension BidirectionalCollection  {

  /// The collection's last **valid** position---that is, the position that is
  /// the last valid subscript argument.
  ///
  /// Use `lastIndex` where endIndex may be ambiguous or semantically
  /// inappropariate. For example:
  ///
  ///     let xs = [30, 40, 50]
  ///     let i = xs.startIndex
  ///     let j = xs.lastIndex
  ///     let nexti = i < _ =<< lastIndex == true ? xs.index(after: i) : nil
  ///     let nextj = xs.lastIndex.flatMap { j < $0 ? xs.index(after: j) : nil }
  ///     // nexti is Optional.some(1), and nextj is Optional.none
  ///
  /// - Remark: If the collection is empty, `lastIndex` is `nil`.
  @inlinable
  public var lastIndex: Index? {
    index？(before: endIndex)
  }

  /// Returns an Optional value with the position immediately before the given
  /// index or `nil` if out of bounds.
  ///
  /// - Parameter i: An index of the collection.
  /// - Returns: An Optional value with the index value immediately before `i`,
  ///   or `nil` in case such value is outside the bounds of this collection.
  @_transparent
  public func index？(before i: Index) -> Index? {
    i > startIndex ? index(before: i) : .none
  }

  /// Returns an Optional value with the position immediately after the given
  /// index or `nil` if out of bounds.
  ///
  /// The successor of an index must be well defined. For an index `i` into a
  /// collection `c`, calling `c.index(after: i)` returns the same index every
  /// time.
  ///
  /// - Parameter i: An index of the collection.
  /// - Returns: An Optional value with the index value immediately after `i`,
  ///   or `nil` in case such value is outside the bounds of the collection.
  @_transparent
  public func index？(after i: Index) -> Index? {
    lastIndex > i ? index(after: i) : .none
  }
}

// MARK: - Lookup

extension Sequence {

  /// Returns the first element of the sequence that satisfies the given
  /// predicate, or *raises a runtime exception* if no element does.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence as
  ///   its argument and returns a Boolean value indicating whether the element
  ///   is a match.
  /// - Returns: The first element of the sequence that satisfies predicate, or
  ///   raises a runtime exception if there is no element that satisfies
  ///   predicate.
  @_transparent
  public func firstǃ(
    where predicate: (Element) -> Bool
  ) -> Element {
    first(where: predicate) !! "Required element does not exist."
  }
}

extension Collection where Element: Equatable {

  /// Returns the first element of the sequence that satisfies the given
  /// predicate or `nil` if such element does not exists.
  ///
  /// A non-rethrowing overload of first until Swift fixes rethrowing meaning
  /// the same as throwing in certain contexts.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence as
  ///   its argument and returns a Boolean value indicating whether the element
  ///   is a match.
  /// - Returns: The first element satisfying the predicate, or `nil`.
  @inlinable
  public func firstOccurrence(of element: Element) -> Element? {
    firstIndex(of: element).map(at)
  }
}

// MARK: - Pattern matching

extension Collection where Self: Membership {

  /// Returns a Boolean value indicating whether an equality pattern over two
  /// collections match, ie. both collections contain the same elements
  /// notwithstanding ordering.
  ///
  /// The axiom of extensionality applies:
  /// - Two sets which contain the same elements are the same set.
  ///
  ///       ∀z∈zs (z∈xs ⟺ z∈ys) ⟹ x ≡ y
  ///
  /// - Parameters:
  ///   - x: The element value to match.
  ///   - xs: A collection of values whose type matches `lhs`.
  /// - Returns: Whether the pattern matches or not.
  @_transparent
  public static func ~= (xs: Self, ys: Self) -> Bool {
    guard xs.isEmpty == ys.isEmpty else { return false }
    guard xs.hasElements && ys.hasElements else { return true }
    return ∀xs∈ys
  }
}

// FIXME: Remove or fix
//  Element being the rhs doesn't make sense?
//    [100...300] ~= 150
//    or?
//    150 ~= [100...300]
//  plus, Self lhs and Element rhs makes something like:
//    [] ~= Set(1, 2, 3)
//  Think rhs is a Collection and lhs is an Element.
//
//extension Sequence where Element: Equatable {
//  /// Returns a Boolean value indicating whether `lhs` matches a membership
//  /// (`∈`) pattern against the values in the given collection.
//  ///
//  /// - Parameters:
//  ///   - lhs: A value to match.
//  ///   - rhs: A collection of values whose type matches `lhs`.
//  /// - Returns: Whether the pattern matches or not.
//  @_transparent
//  public static func ~= (xs: Self, x: Element) -> Bool {
//    return x ∈ xs
//    //return ∃xs • P(equals(x))
//  }
//}

extension SetAlgebra where Self: Membership {

  @_transparent
  public static func ~= <S: Collection>(xs: S, ys: Self) -> Bool where S.Element == Element {
    guard xs.isEmpty == ys.isEmpty else { return false }
    guard xs.hasElements && ys.hasElements else { return true }
    return ∀xs∈ys
  }
}

extension Sequence
  where Self: ContainsWhere, Element: RawRepresentable, Element.RawValue: Equatable
{
  /// Returns a Boolean value indicating whether `lhs` matches a membership
  /// (`∈`) pattern against the values in the given collection.
  ///
  /// - Parameters:
  ///   - lhs: A value to match.
  ///   - rhs: A collection of values whose type matches `lhs`.
  /// - Returns: Whether the pattern matches or not.
  @_transparent
  public static func ~= (xs: Self, x: Element.RawValue) -> Bool {
    ∃xs ∙ P(\.rawValue == x)
  }
}
//
//  /// Returns a Boolean value indicating whether `lhs` matches a membership
//  /// (`∈`) pattern against the values in the given collection.
//  ///
//  /// - Parameters:
//  ///   - lhs: A value to match.
//  ///   - rhs: A collection of values whose type matches `lhs`.
//  /// - Returns: Whether the pattern matches or not.
//  @_transparent
//  public static func ~= (x: Element.RawValue, xs: Self) -> Bool {
//    return (\.rawValue == x) ∈ xs
//  }
//}

// MARK: - Ad-hoc Typeclasses

extension Sequence {

  // MARK: · Functor

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
  public func fmap<Transformed>(
    _ transform: (Element) -> Transformed
  ) -> [Transformed] {
    map(transform)
  }

  // MARK: · Applicative

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
  public func apply<Transformed>(
    _ transforms: [(Element) -> Transformed]
  ) -> [Transformed] {
    transforms.flatMap(fmap)
  }

  // MARK: · Monad

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `bind` method with a closure that returns an optional value.
  ///
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  @inlinable
  public func bind<SegmentOfResult: Sequence>(
    _ transform: @escaping (Element) -> SegmentOfResult
  ) -> [SegmentOfResult.Element] {
    flatMap(transform)
  }
}

// MARK: Foldable

extension Collection {

  // MARK: · Traversable

  /// Returns a new `Result` with the collected results obtained from mapping
  /// each element in the collection to the given `Result`-returning function
  /// `transform` using the applicative form.
  ///
  ///     traverse f = List.foldr consf (pure [])
  ///       where consf x ys = liftA2 (:) (f x) ys
  ///
  /// Current implementation uses a variant of (`<*>`) with a literal name:
  /// `apply`, resulting in:
  ///
  ///     tail.traverse(transform).apply(transform(head).apply(.success(++)))
  ///
  /// This is done to prevent programmers from having to learn standard
  /// functional symbology which usually causes community-wide uproars
  /// regarding symbols making code such as the one above, illegible.
  /// Case in point:
  ///
  ///     .success(++) <*> transform(head) <*> tail.traverse(transform)
  ///
  /// Set, game and checkmate, functional programmers.
  ///
  /// Example:
  ///     let bad = ["1", "x", "y"]
  ///     bad => Array.traverse(parseInt)
  ///     // .failure(["x is not an int", "y is not an int"])
  ///     bad => Array.traverseM(parseInt)
  ///     // .failure("x is not an int")
  ///
  /// The applicative version returns all the errors, while the monadic
  /// version returns only the first error.
  ///
  /// - Parameter transform: A closure that takes an element in this
  ///   collection.
  @inlinable
  public func traverse<T, Failure: Swift.Error>(
    _ transform: (Element) -> Result<T, Failure>
  ) -> Result<[T], Failure> {
    //reduce(into: [T], (++) • mapSnd(transform))
    switch uncons {
    case .none:
      return .success(.empty)
    case let .some(head, tail):
      return tail
        .traverse(transform)
        .apply(transform(head).apply(.success(curry(++))))
    }
  }

  /// Returns a new `Result` by evaluating each each monadic action in the
  /// structure from left to right.
  ///
  ///     traverse :: (Traversable t, Applicative f) => (a -> f b) -> t a -> f (t b)
  ///     mapM :: (Traversable t, Monad m) => (a -> m b) -> t a -> m (t b)
  ///
  ///     .success(++) =<< transform(head) =<< tail.traverse(transform)
  ///
  /// - Note: The applicative version returns all the errors, while the monadic
  ///   version returns only the first error, for example:
  ///
  ///     let bad = ["1", "x", "y"]
  ///     bad => Array.traverse(parseInt)
  ///     // .failure(["x is not an int", "y is not an int"])
  ///     bad => Array.traverseM(parseInt)
  ///     // .failure("x is not an int")
  /// - Parameter transform: A closure that takes an element in this
  ///   collection.
  @inlinable
  public func traverseM<Success, Failure: Swift.Error>(
    _ f: (Element) -> Result<Success, Failure>
  ) -> Result<[Success], Failure> {
    switch uncons {
    case .none:
      return .success(.empty)
    case .some(let head, let tail):
      return f(head).flatMap { h in
        tail.traverse(f).flatMap { t in
          .success(h ++ t)
        }
      }
    }
  }

  /// Evaluate each action in the structure from left to right, and collect the
  /// results.
  ///
  ///     sequenceA ∷ Applicative f => t (f a) -> f (t a)
  ///     sequenceA = traverse id
  @inlinable
  public static func transpose<Success, Failure: Swift.Error>(
    _ xs: [Result<Success, Failure>]
  ) -> Result<[Success], Failure> {
    xs.traverse(id)
  }
}

// MARK: Distributive

/// Zips an arbitrary collection of `Results`.
///
/// `Distributive` is the categorical dual of `Traversable`, and `distribute`,
/// the dual of 'Data.Traversable.sequenceA'.
///
///     distribute ∷ ∀fa. Functor f ⟹ f (d a) → d (f a)
///     distribute = collect id
@inlinable
public func transpose<Success, Failure: Swift.Error>(
  _ xs: Result<[Success], Failure>
) -> [Result<Success, Failure>] {
  collect(id)(xs)
}

/// Cotraverses the success values of an arbitrary collection of Results.
///
/// Distributive is the categorical dual of 'Traversable' and collect, the
/// dual of traverse.
///
///     collect ∷ ∀dfab. Functor f Distributive d ⟹ (a → d b) → f a → d (f b)
///     collect f = distribute . fmap f
@inlinable
public func collect<Success, NewSuccess, Failure: Swift.Error>(
  _ transform: @escaping (Success) -> [NewSuccess]
) -> (Result<Success, Failure>) -> [Result<NewSuccess, Failure>] {
  transpose • fmap(transform)
}

/// Zip an arbitrary collection of containers and summarize the results
///
/// The dual of 'Data.Traversable.traverse'
///
///     cotraverse ∷ ∀fgab. Functor f, Distributive d ⟹ (f a → b) → f (d a) → d b
///     cotraverse f = fmap f . distribute
@inlinable
public func cotraverse<Success, NewSuccess, Failure: Swift.Error>(
  _ transform: @escaping (Result<Success, Failure>) -> NewSuccess
) -> (Result<[Success], Failure>) -> [NewSuccess] {
  fmap(transform) • transpose
}

// MARK: Kleisli composition

/// Returns a new function composing two functions whose return values are
/// sequences.
///
/// Kleisli composition allows monadic computations to be composed in the same
/// fashion as with bare functions. (`>=>`) achieves this by binding the monads
/// returned by the given functions sequentially, yielding result of the last
/// computation.
///
/// This type of composition is syntactically equivalent to binding a sequence
/// of monadic mappings:
///
///     list.flatMap(compute).flatMap(otherCompute).flatMap(anotherCompute)
///
/// Is syntactically equivalent to:
///
///     let compute = firstCompute >=> otherCompute >=> anotherCompute
///     list.flatMap(compute)
///
/// - Important: Kleisli composition is not semantically equivalent to
///   chaining a sequence of monadic bindings. In the above example, there are
///   two key differences:
///
/// 1. Like (`>>>`), (`>=>`) yields a composable unit of its parts which can
///    be memoized, reused and appended.
/// 2. The first example traverses the list 3 times, whereas (`>=>`)
///    guarantees one traversal and one only.
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
///     - g: A monadic computation that will follow `f`.
/// - Returns: A function composing `f` and `g`.
@_transparent
public func >=> <Element, Segment: Sequence, SegmentOfResult: Sequence>(
  f: @escaping (Element) -> Segment,
  g: @escaping (Segment.Element) -> SegmentOfResult
) -> (Element) -> [SegmentOfResult.Element] {
  bind(g) • f
}

// MARK: - Side-effects

extension Sequence {

  /// Evaluate the given closure for its side-effect passing each element of
  /// this `Sequence` instance as a parameter, returning the original
  /// `Sequence` instance.
  ///
  /// Use the `tap` method with a **reference** when you want to perform
  /// a side-effect on each element while retaining function composition.
  ///
  /// - Parameter effect: An effectful function that takes `Element` instances.
  /// - Returns: The original instance.
  @inlinable
  public func tap(sink body: (Element) throws -> ()) rethrows -> Self {
    const(self)(try forEach(body))
  }
}

extension MutableCollection {

  /// Mutates the sequence by mapping the given closure over the sequence's
  /// elements and replacing each one with the transformed result.
  ///
  /// For a more performant variant, check `mutateEach` which mutates via
  /// inout and prevents extra copies by returning ().
  ///
  /// - Parameter mutate: A mapping closure. `mutate` accepts an element of
  ///   this sequence as its parameter for side-effects.
  /// - Returns: The transformed collection.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  @discardableResult
  public mutating func mutateMap(
    _ transform: (Element) throws -> Element
  ) rethrows -> Self {
    var index = startIndex
    while index != endIndex {
      self[index] = try transform(self[index])
      formIndex(after: &index)
    }

    return self
  }

  /// Calls the given closure on each element in the collection in the same
  /// order as a `for-in` loop.
  ///
  /// The `modifyEach` method provides a mechanism for modifying all of the
  /// contained elements in a `MutableCollection`. It differs from `forEach`
  /// or `for-in` by providing the contained elements as `inout` parameters
  /// to the closure `body`. In some cases this will allow the parameters to
  /// be modified in-place in the collection, without needing to copy them or
  /// allocate a new collection.
  ///
  /// - Parameter body: A closure that takes each element of the sequence as
  ///   an `inout` parameter
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public mutating func mutateEach(
    _ mutate: (inout Element) throws -> ()
  ) rethrows {
    var index = startIndex
    while index != endIndex {
      try mutate(&self[index])
      formIndex(after: &index)
    }
  }
}

// MARK: - Algorithm

extension Sequence {

  /// Returns a new list by reducing the collection `tail` into a new
  /// collection with the element `head` as the its first element.
  ///
  /// A more efficient version of this operation is available to types
  /// conforming to `RangeReplaceableCollection`.
  @inlinable
  public static func cons(_ head: Element, _ tail: Self) -> [Element] {
    tail.reduce(into: [head], +=)
  }

  /// Returns an array containing the non-nil elements of this sequence.
  ///
  /// - Returns: An array containing the non-nil elements of this sequence.
  @inlinable
  public func compact<Wrapped>() -> [Wrapped] where Element == Wrapped? {
    compactMap(id)
  }

  /// Returns an array containing, in order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// A non-partial (total) variant of `filter` that cannot fail.
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the returned array.
  /// - Returns: An array of the elements that `isIncluded` allowed.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public __consuming func filterM(
    _ isIncluded: @escaping (Element) -> Bool
  ) -> [Element] {
    filter(isIncluded)
  }

  /// Returns a Boolean value indicating whether the sequence lacks an
  /// element satisfying the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence lacks an element satisfying the
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func lacks(where predicate: @escaping (Element) -> Bool) -> Bool {
    contains(where: not • predicate)
  }

  /// Returns a Boolean value indicating whether this sequence and another
  /// sequence contain equivalent elements in the same order, using the given
  /// predicate as the equivalence test.
  ///
  /// Returns whether this sequence and another sequence **do not** contain
  /// equivalent elements in the same order, using the given predicate as the
  /// equivalence test.
  ///
  /// A setoid `(𝑆𝑒𝑞, ~)` is just a `Sequence` (denoted by `𝑆𝑒𝑞`) equipped with
  /// the *equivalence relation* `equivalent` (denoted by `~`) that is able to
  /// form an *equivalence class* over its elements (denoted by `[𝑎]`):
  ///
  ///     [𝑎] := { ∀𝑏 ∈ 𝑆𝑒𝑞 | 𝑎 ~ 𝑏 }
  ///
  /// ## Properties
  ///
  /// To satisfy the `equivalence relation`, (`~`) must be:
  ///
  /// ### Reflexive
  ///     ∀𝑎 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑎 }
  ///
  /// ### Symmetric
  ///     ∀𝑎𝑏 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑏 ⟺ 𝑏 ~ 𝑎 }
  ///
  /// ### Transitive
  ///     ∀𝑎𝑏𝑐 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑏 ∧ 𝑏 ~ 𝑐 ⟹ 𝑎 ~ 𝑐 }
  ///
  /// - Note: At least one of the sequences must be finite.
  ///
  /// - Parameters:
  ///   - equivalent: A predicate that returns `true` if its two arguments
  ///     are equivalent; otherwise, `false`.
  ///   - other: A sequence to compare to this sequence.
  /// - Returns: `true` if this sequence and `other` contain equivalent items,
  ///   using `areEquivalent` as the equivalence test; otherwise, `false`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<Other: Sequence>(
    by equivalent: @escaping (Element, Other.Element) throws -> Bool
  ) -> (Other) throws -> Bool {
    partial(elementsEqual(_:by:), __, equivalent)
  }

  /// Returns whether this sequence and another sequence **do not** contain
  /// equivalent elements in the same order, using the given predicate as the
  /// equivalence test.
  ///
  /// A setoid `(𝑆𝑒𝑞, ~)` is just a `Sequence` (denoted by `𝑆𝑒𝑞`) equipped with
  /// the *equivalence relation* `equivalent` (denoted by `~`) that is able to
  /// form an *equivalence class* over its elements (denoted by `[𝑎]`):
  ///
  ///     [𝑎] := { ∀𝑏 ∈ 𝑆𝑒𝑞 | 𝑎 ~ 𝑏 }
  ///
  /// ## Properties
  ///
  /// To satisfy the `equivalence relation`, (`~`) must be:
  ///
  /// ### Reflexive
  ///     ∀𝑎 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑎 }
  ///
  /// ### Symmetric
  ///     ∀𝑎𝑏 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑏 ⟺ 𝑏 ~ 𝑎 }
  ///
  /// ### Transitive
  ///     ∀𝑎𝑏𝑐 ∈ 𝑆𝑒𝑞 : { 𝑎 ~ 𝑏 ∧ 𝑏 ~ 𝑐 ⟹ 𝑎 ~ 𝑐 }
  ///
  /// - Note: At least one of the sequences must be finite.
  ///
  /// - Parameters:
  ///   - equivalent: A predicate (or, an _equivalence relation_ `~`) that
  ///     returns `true` when the arguments are equivalent; otherwise, `false`.
  ///   - other: A sequence to compare to this sequence.
  /// - Returns: `false` if this sequence and `other` contain equivalent items,
  ///   using `areEquivalent` as the equivalence test; otherwise, `true`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsDiffer<Other: Sequence>(
    by equivalent: @escaping (Element, Other.Element) -> Bool
  ) -> (Other) -> Bool {
    { zip(with: equivalent)(self, $0).contains(false) }
    //{ zip(self, $0).lazy.first(where: not • equivalent).hasSome }

// stdlib implementation of `elementsEqual` (imperative kids are fun):
//      var iter1 = self.makeIterator()
//      var iter2 = other.makeIterator()
//      while true {
//        switch (iter1.next(), iter2.next()) {
//        case let (e1?, e2?):
//          if try !areEquivalent(e1, e2) {
//            return true
//          }
//        case (_?, nil), (nil, _?): return true
//        case (nil, nil):           return false
//        }
//      }
//    }
  }

  /// Asserts whether this instance of `Optional` satisfies the given predicate,
  /// raising a runtime assertion on debug targets if it does not satisfy.
  ///
  /// - Parameters:
  ///   - predicate: The predicate this `Optional` instance should satisfy.
  ///   - message: A message to display if it does not satisfy.
  /// - Returns: This instance of `Optional`.
  @_transparent
  @warn_unqualified_access
  public __consuming func assert(
    _ predicate: (Self) -> Bool,
    _ message: (Self) -> String = const(.empty),
    file: StaticString = #file,
    line: UInt = #line
  ) -> Self {
    Swift.assert(predicate(self), message(self), file: file, line: line)
    return self
  }

  /// Applies the given closure on each element in the sequence in the same
  /// order as a `for`-`in` loop.
  ///
  /// This is a non-rethrowing variant of forEach.
  ///
  ///     let arr = [1, 1, 1].tap(each(print • (+)& (1))))
  ///     print(arr)
  ///     // first prints three 2s, then three 1s.
  ///
  /// - Parameter body: A closure that takes an element of the sequence as a
  ///   parameter.
  @inlinable
  public func each(_ effect: (Element) -> ()) -> () {
    for x in self { effect(x) }
  }

  /// A functional variant of the `guard` statement that returns `nil` if the
  /// given predicate `p` evaluates to `false`.
  ///
  /// This function is similar to `Sequence.filter(_:)` except it works on
  /// the Sequence instance as a whole.
  ///
  /// - Parameter predicate: A closure that takes this `Sequence` instance as
  ///   its argument and returns a `Boolean` value indicating whether it should
  ///   be kept or not.
  /// - Returns: The `Sequence` instance wrapped in an `Optional` if the
  ///   predicate evaluates to `true` or a `nil` if `false`.
  @inlinable
  public __consuming func `guard`(
    _ predicate: (Self) -> Bool
  ) -> Self? {
    predicate(self) ? .some(self) : .none
  }

  /// Maps over all values in continuation-passing style, calling the given
  /// function when over.
  @inlinable
  public func contMap<U, E: Swift.Error>(
    with complete: @escaping ([Result<U, E>]) -> (),
    _ f: @escaping (Element, @escaping (Result<U, E>) -> ()) -> ()
  ) -> () {
    var results = [Result<U, E>]()
    var it = makeIterator()
    func next(_ x: Element) {
      f(x, { result in
        results.append(result)
        it.next().map(next) ?? complete(results)
      })
    }
    it.next().map(next)
  }

  /// Returns the outer product of two sequences.
  ///
  /// This is a generalization of the outer product, usually the tensor product
  /// of vectors. It operates on each combination of elements of two sequences,
  /// which results in a matrix.
  ///
  ///              ⎛ 𝑎₁₁𝐵 ⋅⋅⋅ 𝑎₁ᵧ𝐵
  ///              ⎜
  ///     𝐴 ⨂ 𝐵 =     ⋮   ⋱   ⋮   = 𝐶
  ///              ⎜
  ///              ⎝ 𝑎ᵪ₁𝐵 ⋅⋅⋅ 𝑎ᵪᵧ𝐵
  ///
  /// The outer product is closely related to the _Kronecker product_, which is
  /// the vectorized form of the outer product:
  ///
  ///     𝑥 ⨂ₖᵣₒₙ 𝑦 = ᴠᴇᴄ(𝑦 ⨂ₒᵤₜ 𝑥)
  ///
  /// ### Laws:
  ///
  ///     concat (outerProduct f xs ys) ≡ liftM2 f xs ys
  ///
  /// ### Definition
  ///
  ///     outerProduct :: (a -> b -> c) -> [a] -> [b] -> [[c]]
  ///     outerProduct f xs ys = map (flip map ys . f) xs
  @inlinable
  public func outerProduct<S: Sequence, C>(
    _ transform: @escaping (Element) -> (S.Element) -> C,
    _ xs: S
  ) -> [[C]] {
    fmap(xs.fmap • transform)
  }

  @inlinable
  public static func outerProduct<S: Sequence, C>(
    _ f: @escaping (Element) -> (S.Element) -> C,
    _ xs: Self,
    _ ys: S
  ) -> [[C]] {
    xs.fmap(ys.fmap • f)
  }

}

extension Sequence where Element: Equatable {

  // MARK: Element: Equatable

  /// Returns a Boolean value indicating whether the sequence lacks an
  /// element satisfying the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence lacks an element satisfying the
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public var lacks: (Element) -> Bool { not • contains }

  /// Returns an array containing, in order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// In this example, `filter(_:)` is used to include only names shorter than
  /// five characters.
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let shortNames = cast.filter { $0.count < 5 }
  ///     print(shortNames)
  ///     // Prints "["Kim", "Karl"]"
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the returned array.
  /// - Returns: An array of the elements that `isIncluded` allowed.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func filter(_ elements: Element...) -> [Element] {
    filter(elements.contains)
  }
}

extension Sequence where Self: Semigroup, Self.Element: Monoid & Sequence {
  public typealias FlattenedSequence = Self.Element

  // MARK: · where Self: Semigroup,
  // MARK: · where Element: Monoid & Sequence

  /// Returns a flattened copy of this sequence of sequences.
  ///
  /// Given each element is itself a sequence, concatenates each element thus
  /// producing the same sequence contents but flattened.
  ///
  /// Akin to doing:
  ///
  ///     array.reduce(into: []) { $0 += $1 }
  ///
  /// Except the original instance is preserved, as opposed to being converted
  /// into an array.
  @inlinable
  public func joined() -> FlattenedSequence {
    reduce()
  }
}

extension Collection {

  /// Decompose a sequence into its head and tail. If the sequence is empty,
  /// returns `nil`. Otherwise, `.some(x, xs)`, where `x` is the head of the
  /// list and `xs` its tail.
  @inlinable
  public var uncons: (Element, SubSequence)? {
    guard let head = first else { return .none }
    return (head, tail)
  }

  /// Returns a `SubSequence` containing all but the first element.
  @inlinable
  public var tail: SubSequence {
    dropFirst()
  }

  /// A Boolean value indicating whether the collection has any
  /// elements in it.
  ///
  /// When you need to check whether your collection has elements, use the
  /// `hasElements` property instead of checking that the `count` property is
  /// greater than zero. For collections that don't conform to
  /// `RandomAccessCollection`, accessing the `count` property iterates
  /// through the elements of the collection.
  ///
  /// - Complexity: O(1)
  @_transparent
  public var hasElements: Bool {
    !isEmpty
  }

  /// The second element of the collection.
  ///
  /// If the collection is empty or has only one element, the value of this
  /// property is `nil`.
  ///
  ///     let numbers = [10, 20, 30, 40, 50]
  ///     print(numbers.second)
  @inlinable
  public var second: Element? {
    if let i = index(startIndex, offsetBy: 1, limitedBy: endIndex) {
      return i < endIndex ? self[i] : .none
    } else {
      return .none
    }
  }

  /// - TODO: Docstrings
  @inlinable
  public func trail(_ effect: (Element, Element) -> ()) -> () {
    guard hasElements else { return }
    _ = reduce(first!) { const($1)(effect($0, $1)) }
  }

  /// Returns a subsequence containing all but the given number of initial
  /// elements.
  ///
  /// This is a pointfree variant of `dropFirst` that follows [Haskell's
  /// drop signature](https://www.stackage.org/haddock/lts-13.7/base-4.12.0.0/Prelude.html#v:drop)
  /// where:
  ///
  ///     drop :: Int -> [a] -> [a]
  ///
  /// If the number of elements to drop exceeds the number of elements in
  /// the sequence, the result is an empty subsequence.
  ///
  ///     [1, 2, 3, 4, 5] => Array.drop(2) => String.init // "[3, 4, 5]"
  ///     [1, 2, 3, 4, 5] => Array.drop(10) => String.init // "[]"
  ///
  /// - Parameter k: The number of elements to drop from the beginning of
  ///   the sequence. `k` must be greater than or equal to zero.
  /// - Returns: A subsequence starting after the specified number of
  ///   elements.
  /// - Complexity: O(*k*), where *k* is the number of elements to drop from
  ///   the beginning of the sequence.
  @inlinable
  public static func drop(_ k: Int) -> (Self) -> Self.SubSequence {
    return flip(dropFirst)(k)
  }
}

extension RangeReplaceableCollection {

  // MARK: Self: RangeReplaceableCollection

  /// Returns a new list by reducing the collection `tail` into a new
  /// collection with the element `head` as the its first element.
  ///
  /// A more efficient version of this operation is available to types
  /// conforming to `RangeReplaceableCollection`.
  @inlinable
  public static func cons(_ head: Element) -> (_ tail: Self) -> Self {
    { tail in [head] + tail }
  }
}

extension Collection where SubSequence: Monoid {

  // MARK: · where SubSequence: Monoid

  /// Returns a 2-tuple (pair) where its first component is the prefix of
  /// elements in this collection that satisfy the given predicate and the
  /// second component is the the remainder of the collection.
  ///
  /// - Parameter predicate: A closure that takes an element of the
  ///   sequence as its argument and returns `true` if the element should
  ///   be included in the first component of the pair or `false`. Once the
  ///   predicate returns `false` it won't be called again.
  /// - Returns: A pair containing the resulting subsequences split from this
  ///   collection or a nil for the second component in case the first one
  ///   collected the entirety of the collection, or both components nil if
  ///
  /// - Complexity: O(*n*), where *n* is the length of the `Collection`.
  @inlinable
  public func span(
    while predicate: @escaping (Element) -> Bool
  ) -> (SubSequence, SubSequence) {
    firstIndex(where: not • predicate)
      .split(prefix(upTo:), suffix(from:))
      ?? (.empty, .empty)
  }
}

extension Collection where Element: Equatable, SubSequence: Monoid {

  /// Returns a pair (2-tuple) of `SubSequences` with the result of splitting
  /// this collection by the first occurrence of the given `Element`.
  ///
  /// - Parameter element: The element that should be split upon.
  /// - Returns: A pair with two `SubSequences`, split from this collection.
  /// - Complexity: O(_n_), where _n_ is the length of this collection.
  @inlinable
  public func split(
    by element: Element
  ) -> (SubSequence, SubSequence) {
    split(separator: element, maxSplits: 1) => {
      ($0.first ?? .empty, $0.second ?? .empty)
    }
  }

  /// Returns a pair (2-tuple) where the first `Substring` is the prefix
  /// _up to_ the given element and the second is the remainder of this `String`
  /// starting from the given element.
  ///
  /// - Parameter e: The element to be split upon.
  /// - Returns: A pair with two `SubSequences`, split from this collection.
  /// - Complexity: O(_n_), where _n_ is the length of this collection.
  @inlinable
  public func span(_ element: Element) -> (SubSequence, SubSequence) {
    span(while: { $0 != element })
  }
}

#if os(iOS)
import Dispatch

extension RandomAccessCollection where Index == Int {

  // MARK: Index == Int

  public func paramap<T>(
    _ mutating: @escaping (Element) -> T
  ) -> [T] {
    var result = ContiguousArray<T>()
    result.reserveCapacity(count)
    DispatchQueue.concurrentPerform(iterations: count) { ι in
      result.append(mutating(self[ι]))
    }
    return .init(result)
  }
}
#endif

// MARK: - Lazy

// MARK: ⠀typealias LazySlice

public typealias LazySlice = Slice

// MARK: ⠀typealias LazyReversedCollection

public typealias LazyReversedCollection = ReversedCollection

// MARK: ⠀typealias LazySuffixWhileCollection

/// A trivial alias for what would constitute the larger `LazySuffixWhile` type.
///
/// Laziness is conferred by `ReversedCollection` when applied to a collection
/// with bidirectional indices, but does not implicitly confer laziness on
/// algorithms applied to its result. In other words, for ordinary collections
/// `c` having bidirectional indices, `LazySuffixWhileCollection` will:
///
/// * not create new storage.
/// * on `c.map(ƒ)` map **eagerly** returning a **new** array.
/// * on `c.lazy.map(ƒ)` map **lazily** returning a `LazyMapCollection<LazySuffixWhileCollection>`
public typealias LazySuffixWhileCollection<Base: BidirectionalCollection> =
  LazyReversedCollection<LazyPrefixWhileSequence<LazyReversedCollection<Base>>>

// MARK: - Prefix|Suffix

extension LazySequenceProtocol where Elements: BidirectionalCollection {

  /// Returns a lazy reversed sequence of the last consecutive elements that
  /// satisfy `predicate`.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence as
  ///   its argument and returns `true` if the element should be included or
  ///   `false` otherwise. Once `predicate` returns `false` it will not be
  ///   called again.
  @inlinable // lazy-performance
  public __consuming func suffix(
    while predicate: @escaping (Elements.Element) -> Bool
  ) -> LazySuffixWhileCollection<Elements> {
    elements.reversed().lazy.prefix(while: predicate).reversed()
  }
}

extension BidirectionalCollection where SubSequence: Identity {

  /// Returns a subsequence containing the last elements until `predicate`
  /// returns `false` and skipping the remaining elements.
  ///
  /// - Parameter predicate: A closure that takes an element of the
  ///   sequence as its argument and returns `true` if the element should
  ///   be included or `false` if it should be excluded. Once the predicate
  ///   returns `false` it will not be called again.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public __consuming func suffix(
    while predicate: @escaping (Element) -> Bool
  ) -> SubSequence {
    lastIndex(where: not • predicate)
      .flatMap(index？(after:))
      .map { self[$0..<endIndex] } ?? .empty
  }
}

extension BidirectionalCollection
  where SubSequence: Identity, Element: Equatable {


  /// Returns a subsequence from the start of the collection up to, but not
  /// including, the first index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, but not including, the first index of
  ///   the given element.
  @inlinable
  public func prefix(upTo ε: Element) -> SubSequence {
    firstIndex(of: ε).map(prefix(upTo:)) ?? .empty
  }

  /// Returns a subsequence from the start of the collection through the
  /// first index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, and including, the first index of the
  ///   given element.
  @inlinable
  public func prefix(through ε: Element) -> SubSequence {
    firstIndex(of: ε).map(prefix(through:)) ?? .empty
  }

  /// Returns a subsequence from the start of the collection up to, but not
  /// including, the last index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, but not including, the last index of
  ///   the given element.
  @inlinable
  public func prefix(upToLast ε: Element) -> SubSequence {
    lastIndex(of: ε).map(prefix(upTo:)) ?? .empty
  }

  /// Returns a subsequence from the start of the collection through the
  /// last index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, and including, the last index of the
  ///   given element.
  @inlinable
  public func prefix(throughLast ε: Element) -> SubSequence {
    lastIndex(of: ε).map(prefix(through:)) ?? .empty
  }

  /// Returns a subsequence from the last index of the given element, not
  /// included, up to the end of the collection.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence from, but not including, the last index of
  ///   the given element to the end of the collection.
  @inlinable
  public func suffix(following ε: Element) -> SubSequence {
    firstIndex(of: ε).map(index(after:)).map(suffix) ?? .empty
  }

  /// Returns a subsequence from, but not including, the last index of the
  /// given element through the end of the collection.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence from, but not including, the last index of
  ///   the given element to the end of the collection.
  @inlinable
  public func suffix(from ε: Element) -> SubSequence {
    firstIndex(of: ε).map(suffix) ?? .empty
  }

  /// Returns a subsequence from the last index of the given element, not
  /// included, up to the end of the collection.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence from, but not including, the last index of
  ///   the given element to the end of the collection.
  @inlinable
  public func suffix(followingLast ε: Element) -> SubSequence {
    lastIndex(of: ε).map(index(after:)).map(suffix) ?? .empty
  }

  /// Returns a subsequence from, but not including, the last index of the
  /// given element through the end of the collection.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence from, but not including, the last index of
  ///   the given element to the end of the collection.
  @inlinable
  public func suffix(fromLast ε: Element) -> SubSequence {
    lastIndex(of: ε).map(suffix) ?? .empty
  }
}

// MARK: - CRUD

extension Collection
  where Self: RangeReplaceableCollection & BidirectionalCollection
{
  // MARK: RangeReplaceableCollection & BidirectionalCollection

  /// Removes and returns the last element that satisfies the predicate.
  ///
  /// - Parameter predicate: Closure each element will be tested against.
  /// - Returns: The element removed or nil if the predicate isn't satisfied.
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeLast(
    where predicateSatifies: (Element) throws -> Bool
  ) rethrows -> Element? {
    try lastIndex(where: predicateSatifies).map { remove(at: $0) }
  }
}

extension RangeReplaceableCollection {

  /// Removes and returns the first element that satisfies the predicate.
  ///
  /// - Parameter predicate: Closure each element will be tested against.
  /// - Returns: The element removed or nil if the predicate isn't satisfied.
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  @discardableResult
  public mutating func removeFirst(
    where predicateSatifies: (Element) throws -> Bool
  ) rethrows -> Element? {
    try firstIndex(where: predicateSatifies).map { remove(at: $0) }
  }

  /// Creates a new collection by replacing the specified subrange of elements
  /// with the given collection.
  ///
  /// This method has the effect of removing the specified range of elements
  /// from the collection and inserting the new elements at the same location.
  /// The number of new elements need not match the number of elements being
  /// removed.
  ///
  /// If you pass a zero-length range as the `subrange` parameter, this method
  /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
  /// the `inserting(contentsOf:at:)` method instead is preferred.
  ///
  /// Likewise, if you pass a zero-length collection as the `newElements`
  /// parameter, this method removes the elements in the given subrange
  /// without replacement. Calling the `removing(subrange:)` method instead
  /// is preferred.
  ///
  /// - Parameters:
  ///   - subrange: The subrange of the collection to replace. The bounds of
  ///               the range must be valid indices of the collection.
  ///   - newElements: The new elements to add to the collection.
  ///
  /// - Complexity: O(*n* + *m*), where *n* is the length of the collection
  ///   and *m* is the length of `newElements`. If the call to this method
  ///   simply appends the contents of `newElements` to the collection, this
  ///   method is equivalent to `appending(contentsOf:)`.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func replacing<C: Collection, R: RangeExpression>(
    subrange: R,
    with newElements: C
  ) -> Self where C.Element == Element, R.Bound == Index {
    replacing(
      subrange: subrange.relative(to: self),
      with: newElements)
  }

  /// Creates a new collection by replacing the specified subrange of
  /// elements with the given collection.
  ///
  /// This method has the effect of removing the specified range of elements
  /// from the collection and inserting the new elements at the same location.
  /// The number of new elements need not match the number of elements being
  /// removed.
  ///
  /// If you pass a zero-length range as the `subrange` parameter, this method
  /// inserts the elements of `newElements` at `subrange.startIndex`. Calling
  /// the `inserting(contentsOf:at:)` method instead is preferred.
  ///
  /// Likewise, if you pass a zero-length collection as the `newElements`
  /// parameter, this method removes the elements in the given subrange
  /// without replacement. Calling the `removing(subrange:)` method instead
  /// is preferred.
  ///
  /// - Parameters:
  ///   - subrange: The subrange of the collection to replace. The bounds of
  ///               the range must be valid indices of the collection.
  ///   - newElements: The new elements to add to the collection.
  ///
  /// - Complexity: O(*n* + *m*), where *n* is length of this collection and
  ///   *m* is the length of `newElements`. If the call to this method simply
  ///   appends the contents of `newElements` to the collection, this method
  ///   is equivalent to `appending(contentsOf:)`.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func replacing<C: Collection>(
    subrange: Range<Index>,
    with newElements: C
  ) -> Self where C.Element == Element {
    // The intention behind providing a default implementation for concrete
    // subranges is to ensure the `replaceSubrange` call dance needed to
    // lift a given `RangeExpression` to a `Range` is kept to a minimum.
    mutating(self) { xs in
      xs.replaceSubrange(subrange, with: newElements)
    }
  }

  /// Inserts a new element into the collection at the specified position.
  ///
  /// The new element is inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as
  /// the `index` parameter, the new element is appended to the
  /// collection.
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.insert(100, at: 3)
  ///     numbers.insert(200, at: numbers.endIndex)
  ///
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
  ///
  /// Calling this method may invalidate any existing indices for use with
  /// this collection.
  ///
  /// - Parameters:
  ///     - newElement: The new element to insert into the collection.
  ///     - index: The position at which to insert the new element. It must
  ///       be a valid index into the collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection. If
  ///   `i == endIndex`, this method is equivalent to `append(_:)`.
  @inlinable
  public func inserting(
    _ newElement: Element,
    at index: Index
  ) -> Self {
    replacing(
      subrange: index..<index,
      with: CollectionOfOne(newElement))
  }

  /// Inserts a new element into the collection at the specified position.
  ///
  /// The new element is inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as
  /// the `index` parameter, the new element is appended to the
  /// collection.
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.insert(100, at: 3)
  ///     numbers.insert(200, at: numbers.endIndex)
  ///
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
  ///
  /// Calling this method may invalidate any existing indices for use with
  /// this collection.
  ///
  /// - Parameters:
  ///     - newElement: The new element to insert into the collection.
  ///     - predicate: A function that should return `true` where `newElement`
  ///       should be inserted.
  /// - Complexity: O(*n*), where *n* is the length of the collection. If
  ///   `i == endIndex`, this method is equivalent to `append(_:)`.
  @inlinable
  public func inserting(
    _ newElement: Element,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Self {
    try inserting(
      contentsOf: CollectionOfOne(newElement),
      where: predicate)
  }

  /// Inserts the elements of a sequence into the collection at the specified
  /// position.
  ///
  /// The new elements are inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as
  /// the `index` parameter, the new elements are appended to the collection.
  ///
  /// Here's an example of inserting a range of integers into an array of the
  /// same type:
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.insert(contentsOf: 100...103, at: 3)
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 100, 101, 102, 103, 4, 5]"
  ///
  /// Calling this method may invalidate any existing indices for use with
  /// this collection.
  ///
  /// - Parameter newElements: The new elements to insert into the collection.
  /// - Parameter index: The position at which to insert the new elements. It
  ///   must be a valid index of the collection.
  ///
  /// - Complexity: O(*n* + *m*), where *n* is length of this collection and
  ///   *m* is the length of `newElements`. If `i == endIndex`, this method
  ///   is equivalent to `append(contentsOf:)`.
  @inlinable
  public func inserting<C: Collection>(
    contentsOf newElements: C,
    at index: Index
  ) -> Self where C.Element == Element {
    replacing(
      subrange: index..<index,
      with: newElements)
  }

  /// Inserts the elements of a sequence into the collection at the specified
  /// position.
  ///
  /// The new elements are inserted before the element currently at the
  /// specified index. If you pass the collection's `endIndex` property as
  /// the `index` parameter, the new elements are appended to the collection.
  ///
  /// Here's an example of inserting a range of integers into an array of the
  /// same type:
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.insert(contentsOf: 100...103, at: 3)
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 100, 101, 102, 103, 4, 5]"
  ///
  /// Calling this method may invalidate any existing indices for use with
  /// this collection.
  ///
  /// - Parameter newElements: The new elements to insert into the collection.
  /// - Parameter index: The position at which to insert the new elements. It
  ///   must be a valid index of the collection.
  ///
  /// - Complexity: O(*n* + *m*), where *n* is length of this collection and
  ///   *m* is the length of `newElements`. If `i == endIndex`, this method
  ///   is equivalent to `append(contentsOf:)`.
  @inlinable
  public func inserting<C: Collection>(
    contentsOf newElements: C,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Self where C.Element == Element {
    try firstIndex(where: predicate)
      .map { replacing(subrange: .init($0), with: newElements) } ?? self
  }

  /// Creates a new collection by adding an element to the end of it.
  ///
  /// If the collection does not have sufficient capacity for another element,
  /// additional storage is allocated before appending `newElement`.
  ///
  /// - Parameter newElement: The element to append to the collection.
  ///
  /// - Complexity: O(1) on average, over many calls to `append(_:)` on the
  ///               same collection.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func appending(
    _ newElement: Element
  ) -> Self {
    inserting(newElement, at: endIndex)
  }

  /// Creates a new collection by concatenating the elements of a collection
  /// and a sequence.
  ///
  /// This is the instance method version of the `+` operator on the same
  /// types.
  ///
  /// The two arguments must have the same `Element` type. For example, you
  /// can concatenate the elements of an integer array and a `Range<Int>`
  /// instance.
  ///
  /// - Parameter newElements: A collection or finite sequence.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func appending<S: Sequence>(
    contentsOf newElements: S
  ) -> Self where S.Element == Element {
    mutating(self) { xs in xs.append(contentsOf: newElements) }
  }

  /// Adds an element to the end of the collection.
  ///
  /// If the collection does not have sufficient capacity for another element,
  /// additional storage is allocated before appending `newElement`. The
  /// following example adds a new number to an array of integers:
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.append(100)
  ///
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 4, 5, 100]"
  ///
  /// - Parameter newElement: The element to append to the collection.
  ///
  /// - Complexity: O(1) on average, over many calls to `append(_:)` on the
  ///   same collection.
  @inlinable
  public mutating func prepend(_ element: __owned Element) -> () {
    insert(element, at: startIndex)
  }

  /// Adds the elements of a sequence or collection to the end of this
  /// collection.
  ///
  /// The collection being appended to allocates any additional necessary
  /// storage to hold the new elements.
  ///
  /// The following example appends the elements of a `Range<Int>` instance to
  /// an array of integers:
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers.append(contentsOf: 10...15)
  ///     print(numbers)
  ///     // Prints "[1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]"
  ///
  /// - Parameter newElements: The elements to append to the collection.
  ///
  /// - Complexity: O(*m*), where *m* is the length of `newElements`.
  @inlinable
  public mutating func prepend<S: Collection>(
    contentsOf newElements: __owned S
  ) where S.Element == Element {
    insert(contentsOf: newElements, at: startIndex)
  }


  /// Creates a new collection by adding an element to the start of it.
  ///
  /// If the collection does not have sufficient capacity for another element,
  /// additional storage is allocated before appending `newElement`.
  ///
  /// - Parameter newElement: The element to append to the collection.
  ///
  /// - Complexity: O(1) on average, over many calls to `append(_:)` on the
  ///               same collection.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func prepending(_ newElement: Element) -> Self {
    inserting(newElement, at: startIndex)
  }

  /// Creates a new collection by prepending the elements of a given
  /// collection.
  ///
  /// The two arguments must have the same `Element` type. For example, you
  /// can concatenate the elements of an integer array and a `Range<Int>`
  /// instance.
  ///
  /// - Parameter newElements: A collection or finite sequence.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func prepending<C: Collection>(
    contentsOf newElements: C
  ) -> Self where C.Element == Element {
    mutating(self) { xs in
      xs.insert(contentsOf: newElements, at: startIndex)
    }
  }

  /// Creates a new collection by prepending the elements of a given
  /// collection.
  ///
  /// The two arguments must have the same `Element` type. For example, you
  /// can concatenate the elements of an integer array and a `Range<Int>`
  /// instance.
  ///
  /// - Parameter newElements: A collection or finite sequence.
  ///
  /// - Returns: The new collection.
  @inlinable
  public func prepending(contentsOf newElements: Self) -> Self {
    newElements + self
  }

  /// Returns a new collection with the specified range removed.
  ///
  /// - Parameter bounds: The subrange of the collection to remove. The
  ///   bounds of the range must be valid indices of the collection.
  ///
  /// - Returns: The new collection
  @inlinable
  public func removing(subrange: Range<Index>) -> Self {
    replacing(subrange: subrange, with: EmptyCollection())
  }

  /// Removes from the collection all elements that satisfy the given
  /// predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be removed from the collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func removingAll(where predicate: (Element) -> Bool) -> Self {
    mutating(self) { $0.removeAll(where: predicate) }
  }
}


extension MutableCollection where Element: Equatable {

  // MARK: Element: Equatable

  /// Returns a new `Collection` in which all occurrences of an `Element`
  /// are replaced by another `Element`.
  ///
  /// - Parameters:
  ///   - current: `Element` to replace.
  ///   - replacement: `Element` to replace with.
  /// - Returns: A new `Collection` with any occurrences of `current`
  ///   replaced with `replacement`
  /// - Complexity: O(*n*) where *n* is the amount of elements that had to be
  ///   replaced
  @inlinable
  public mutating func replace(
    _ element: Element,
    with replacement: Element
  ) {
    for i in indices where self[i] == element {
      self[i] = replacement
    }
  }

  /// Returns a new `Collection` in which all occurrences of an `Element`
  /// are replaced by another `Element`.
  ///
  /// - Parameters:
  ///   - current: `Element` to replace.
  ///   - replacement: `Element` to replace with.
  /// - Returns: A new `Collection` with any occurrences of `current`
  ///   replaced with `replacement`
  /// - Complexity: O(*n*) where *n* is the amount of elements that had to be
  ///   replaced
  @inlinable
  public func replacing(
    _ element: Element,
    with replacement: Element
  ) -> Self {
    mutating(self) { xs in xs.replace(element, with: replacement) }
  }
}

extension RangeReplaceableCollection where Element: Equatable {

  // MARK: Element: Equatable

  /// Returns a new `Collection` in which all occurrences of an `Element`
  /// are replaced by another `Element`.
  ///
  /// - Parameters:
  ///   - current: `Element` to replace.
  ///   - replacement: `Element` to replace with.
  /// - Returns: A new `Collection` with any occurrences of `current`
  ///   replaced with `replacement`
  /// - Complexity: O(*n*) where *n* is the size of the collection.
  @inlinable
  public func replacing(
    _ current: Element,
    with replacement: Element
  ) -> Self {
    .init(map { $0 == current ? replacement : $0 })
  }

  /// Creates a new collection by removing all the elements contained in a
  /// sequence `rhs` from the collection `lhs`.
  ///
  /// The two arguments must have the same `Element` type. For example, you
  /// can subtract the elements of an integer array and a `Range<Int>`
  /// instance.
  ///
  ///     let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     let moreNumbers = numbers - 3...7
  ///     print(moreNumbers)
  ///     // Prints "[1, 2, 8, 9, 10]"
  ///
  /// The resulting collection has the type of the argument on the left-hand
  /// side. In the example above, `moreNumbers` has the same type as `numbers`,
  /// which is `[Int]`.
  ///
  /// - Parameters:
  ///   - lhs: A range-replaceable collection.
  ///   - rhs: A collection or finite sequence.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @_transparent
  public static func - <Other: Sequence>(
    lhs: Self,
    rhs: Other
  ) -> Self where Element == Other.Element {
    mutating(lhs) { xs in xs -= rhs }
  }

  /// Removes the elements from a range-replaceable collection that are
  /// contained in a sequence.
  ///
  /// Use this operator to remove the elements in a sequence from a
  /// range-replaceable collection with same `Element` type. This example
  /// removes the elements in a `Range<Int>` instance from an array of
  /// integers.
  ///
  ///     var numbers = [1, 2, 3, 4, 5]
  ///     numbers -= 3...5
  ///     print(numbers)
  ///     // Prints "[1, 2]"
  ///
  /// - Parameters:
  ///   - lhs: The array to remove from.
  ///   - rhs: A collection or finite sequence.
  ///
  /// - Complexity: O(*m*), where *m* is the length of the right-hand-side
  ///   argument.
  @_transparent
  public static func -= <Other: Sequence>(
    lhs: inout Self,
    rhs: Other
  ) where Element == Other.Element {
    lhs.removeAll(where: rhs.contains)
  }
}

extension Collection
  where Self: RangeReplaceableCollection & BidirectionalCollection
{
  // MARK: RangeReplaceableCollection & BidirectionalCollection

  /// Creates a new collections by removing the last element of the
  /// collection.
  ///
  /// The collection must not be empty. To remove the last element of a
  /// collection that might be empty, use the popLast() method instead.
  ///
  /// - Returns: A new collection without the last element.
  @inlinable
  public func removingLast() -> Self {
    mutating(self) { xs in xs.removeLast() }
  }

  /// Creates a new collections by removing the given number of elements
  /// from the end of the collection.
  ///
  /// - Parameter n: The number of elements to remove. k must be greater than
  ///   or equal to zero, and must be less than or equal to the number of
  ///   elements in the collection.
  ///
  /// - Complexity: O(*1*) if the collection conforms to `RandomAccessCollection`;
  ///   otherwise, O(*k*), where *k* is the number of elements to remove.
  ///
  /// - Returns: A new `Collection` without the last `n` elements.
  @inlinable
  public func removing(last n: Int) -> Self {
    mutating(self) { xs in xs.removeLast(n) }
  }
}

// MARK: -
// MARK: - Static thunks

// - Why are you creating a static variant of each instance function? Are you
// coding from a mental institution or something?
// + If you pay attention to the signatures you'll see a pattern, every
//   function has the same arguments as its instance counterpart except that
//   they all return a function that will take an instance of the type `Self`
//   before giving back a result or performing a side-effect.
// - So you are in a mental institution...
// + Yes, but that has noth—Listen, this is a technique called Currying,
//   widely used in the Functional Programming community.
// - Oh, so that's why you are in a mental institution... Are you there with
//   all yiour friends from the uh, "community"?
// + Goddammit, yes, we're all here, but—just...! just...! ok?!
// - Ook loonie, calm down, calm down, I'm listening, I'm listening...
// + :sigh: Ok... It's all about composition, see? The signature in these
//   static member functions is what allows you to chain multiple functions
//   to create complex, reusable functionality out of smaller "chunks", all
//   fully type-checked, testable, free of side-effects...
// - Oook... I see, I see... So, let me ask you something, do I still get the
//   discount with the tikka masala, or...
// + Are you ordering food?!
// - (Shh, it's your damn fault, shut up.) OK, thank you! *click* Hope that
//   curry makes it up for listening to all this nonsense.
// + Alrighty then... So, what could be even more significant is that by
//   using this technique, which I'll demo to you in a bit, you exploit one of
//   the least appreciated yet most powerful features in Swift: Pointfree
//   style! Pointfree style is s programming paradigm

// to be continued...

extension Sequence {

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
    _ transform: @escaping (Element) -> Transformed
  ) -> (Self) -> [Transformed] {
    { xs in xs.map(transform) }
  }

  /// Returns an array containing the non-`nil` results of calling the given
  /// transformation with each element of this sequence.
  ///
  /// Use this method to receive an array of non-optional values when your
  /// transformation produces an optional value.
  ///
  /// In this example, note the difference in the result of using `map` and
  /// `compactMap` with a transformation that returns an optional `Int` value.
  ///
  ///     let possibleNumbers = ["1", "2", "three", "///4///", "5"]
  ///
  ///     let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
  ///     // [1, 2, nil, nil, 5]
  ///
  ///     let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
  ///     // [1, 2, 5]
  ///
  /// - Parameter transform: A closure that accepts an element of this
  ///   sequence as its argument and returns an optional value.
  /// - Returns: An array of the non-`nil` results of calling `transform`
  ///   with each element of the sequence.
  ///
  /// - Complexity: O(*m* + *n*), where *n* is the length of this sequence
  ///   and *m* is the length of the result.
  @inlinable
  public static func compactMap<ElementOfResult>(
    _ transform: @escaping (Element) -> ElementOfResult?
  ) -> (Self) -> [ElementOfResult] {
    { xs in xs.compactMap(transform) }
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
    _ transforms: [(Element) -> Transformed]
  ) -> (Self) -> [Transformed] {
    { xs in xs.apply(transforms) }
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
  public static func flatMap<SegmentOfResult: Sequence>(
    _ transform: @escaping (Element) throws -> SegmentOfResult
  ) rethrows -> (Self) throws -> [SegmentOfResult.Element] {
    { xs in try xs.flatMap(transform) }
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
  public static func bind<SegmentOfResult: Sequence>(
    _ transform: @escaping (Element) -> SegmentOfResult
  ) -> (Self) -> [SegmentOfResult.Element] {
    { xs in xs.bind(transform) }
  }
  
  /// Calls the given closure on each element in the sequence in the same order
  /// as a `for`-`in` loop.
  ///
  /// Using the `forEach` method is distinct from a `for`-`in` loop in two
  /// important ways:
  ///
  /// 1. You cannot use a `break` or `continue` statement to exit the current
  ///    call of the `body` closure or skip subsequent calls.
  /// 2. Using the `return` statement in the `body` closure will exit only from
  ///    the current call to `body`, not from any outer scope, and won't skip
  ///    subsequent calls.
  ///
  /// - Parameter body: A closure that takes an element of the sequence as a
  ///   parameter.
  @inlinable
  public static func forEach(
    _ body: @escaping (Element) -> ()
  ) -> (Self) -> () {
    { xs in xs.forEach(body) }
  }

  /// Returns an array containing, in order, the elements of the sequence
  /// that satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   sequence as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the returned array.
  /// - Returns: An array of the elements that `isIncluded` allowed.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func filter(
    _ isIncluded: @escaping (Element) -> Bool
  ) -> (Self) -> [Element] {
    { xs in xs.filter(isIncluded) }
  }

  /// Returns the result of combining the elements of the sequence using the
  /// given closure.
  ///
  /// Use the `reduce(_:_:)` method to produce a single value from the elements
  /// of an entire sequence. For example, you can use this method on an array
  /// of numbers to find their sum or product.
  ///
  /// The `nextPartialResult` closure is called sequentially with an
  /// accumulating value initialized to `initialResult` and each element of
  /// the sequence. This example shows how to find the sum of an array of
  /// numbers.
  ///
  ///     let numbers = [1, 2, 3, 4]
  ///     let numberSum = numbers.reduce(0, { x, y in
  ///         x + y
  ///     })
  ///     // numberSum == 10
  ///
  /// When `numbers.reduce(_:_:)` is called, the following steps occur:
  ///
  /// 1. The `nextPartialResult` closure is called with `initialResult`---`0`
  ///    in this case---and the first element of `numbers`, returning the sum:
  ///    `1`.
  /// 2. The closure is called again repeatedly with the previous call's return
  ///    value and each element of the sequence.
  /// 3. When the sequence is exhausted, the last value returned from the
  ///    closure is returned to the caller.
  ///
  /// If the sequence has no elements, `nextPartialResult` is never executed
  /// and `initialResult` is the result of the call to `reduce(_:_:)`.
  ///
  /// - Parameters:
  ///   - initialResult: The value to use as the initial accumulating value.
  ///     `initialResult` is passed to `nextPartialResult` the first time the
  ///     closure is executed.
  ///   - nextPartialResult: A closure that combines an accumulating value and
  ///     an element of the sequence into a new accumulating value, to be used
  ///     in the next call of the `nextPartialResult` closure or returned to
  ///     the caller.
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func reduce<Result>(
    _ initialResult: Result,
    _ nextPartialResult: @escaping (Result, Element) throws -> Result
  ) rethrows -> (Self) throws -> Result {
    { xs in try xs.reduce(initialResult, nextPartialResult) }
  }

  /// Returns the result of combining the elements of the sequence using the
  /// given closure.
  ///
  /// Use the `reduce(into:_:)` method to produce a single value from the
  /// elements of an entire sequence. For example, you can use this method on an
  /// array of integers to filter adjacent equal entries or count frequencies.
  ///
  /// This method is preferred over `reduce(_:_:)` for efficiency when the
  /// result is a copy-on-write type, for example an Array or a Dictionary.
  ///
  /// The `updateAccumulatingResult` closure is called sequentially with a
  /// mutable accumulating value initialized to `initialResult` and each element
  /// of the sequence. This example shows how to build a dictionary of letter
  /// frequencies of a string.
  ///
  ///     let letters = "abracadabra"
  ///     let letterCount = letters.reduce(into: [:]) { counts, letter in
  ///         counts[letter, default: 0] += 1
  ///     }
  ///     // letterCount == ["a": 5, "b": 2, "r": 2, "c": 1, "d": 1]
  ///
  /// When `letters.reduce(into:_:)` is called, the following steps occur:
  ///
  /// 1. The `updateAccumulatingResult` closure is called with the initial
  ///    accumulating value---`[:]` in this case---and the first character of
  ///    `letters`, modifying the accumulating value by setting `1` for the key
  ///    `"a"`.
  /// 2. The closure is called again repeatedly with the updated accumulating
  ///    value and each element of the sequence.
  /// 3. When the sequence is exhausted, the accumulating value is returned to
  ///    the caller.
  ///
  /// If the sequence has no elements, `updateAccumulatingResult` is never
  /// executed and `initialResult` is the result of the call to
  /// `reduce(into:_:)`.
  ///
  /// - Parameters:
  ///   - initialResult: The value to use as the initial accumulating value.
  ///   - updateAccumulatingResult: A closure that updates the accumulating
  ///     value with an element of the sequence.
  /// - Returns: The final accumulated value. If the sequence has no elements,
  ///   the result is `initialResult`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func reduce<Result>(
    into initialResult: __owned Result,
    _ updateAccumulatingResult: @escaping (inout Result, Element) throws -> ()
  ) rethrows -> (Self) throws -> Result {
    { xs in try xs.reduce(into: initialResult, updateAccumulatingResult) }
  }

  /// Returns a sequence of pairs `(n, x)`, where `n` represents a consecutive
  /// integer starting at zero and `x` represents an element of the sequence.
  ///
  /// When you enumerate a collection, the integer part of each pair is a counter
  /// for the enumeration, but is not necessarily the index of the paired value.
  /// These counters can be used as indices only in instances of zero-based,
  /// integer-indexed collections, such as `Array` and `ContiguousArray`. For
  /// other collections the counters may be out of range or of the wrong type
  /// to use as an index. To iterate over the elements of a collection with its
  /// indices, use the `zip(_:_:)` function.
  ///
  /// - Returns: A sequence of pairs enumerating the sequence.
  /// - Complexity: O(1)
  @inlinable
  public static func enumerated(_ xs: Self) -> EnumeratedSequence<Self> {
    xs.enumerated()
  }

  /// Returns an array containing the elements of this sequence in reverse
  /// order.
  ///
  /// The sequence must be finite.
  ///
  /// - Returns: An array containing the elements of this sequence in
  ///   reverse order.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func reversed(_ xs: Self) -> [Element] {
    xs.reversed()
  }

  /// Returns a Boolean value indicating whether the sequence lacks an
  /// element satisfying the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence lacks an element satisfying the
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func lacks(
    where predicate: @escaping (Element) -> Bool
  ) -> (Self) -> Bool {
    { xs in xs.lacks(where: predicate) }
  }

  /// Returns the elements of the sequence, sorted using the given predicate as
  /// the comparison between elements.
  ///
  /// When you want to sort a sequence of elements that don't conform to the
  /// `Comparable` protocol, pass a predicate to this method that returns
  /// `true` when the first element should be ordered before the second. The
  /// elements of the resulting array are ordered according to the given
  /// predicate.
  ///
  /// In the following example, the predicate provides an ordering for an array
  /// of a custom `HTTPResponse` type. The predicate orders errors before
  /// successes and sorts the error responses by their error code.
  ///
  ///     enum HTTPResponse {
  ///         case ok
  ///         case error(Int)
  ///     }
  ///
  ///     let responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
  ///     let sortedResponses = responses.sorted {
  ///         switch ($0, $1) {
  ///         // Order errors by code
  ///         case let (.error(aCode), .error(bCode)):
  ///             return aCode < bCode
  ///
  ///         // All successes are equivalent, so none is before any other
  ///         case (.ok, .ok): return false
  ///
  ///         // Order errors before successes
  ///         case (.error, .ok): return true
  ///         case (.ok, .error): return false
  ///         }
  ///     }
  ///     print(sortedResponses)
  ///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
  ///
  /// You also use this method to sort elements that conform to the
  /// `Comparable` protocol in descending order. To sort your sequence in
  /// descending order, pass the greater-than operator (`>`) as the
  /// `areInIncreasingOrder` parameter.
  ///
  ///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
  ///     let descendingStudents = students.sorted(by: >)
  ///     print(descendingStudents)
  ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
  ///
  /// Calling the related `sorted()` method is equivalent to calling this
  /// method and passing the less-than operator (`<`) as the predicate.
  ///
  ///     print(students.sorted())
  ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
  ///     print(students.sorted(by: <))
  ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also `true`.
  ///   (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// The sorting algorithm is not guaranteed to be stable. A stable sort
  /// preserves the relative order of elements for which
  /// `areInIncreasingOrder` does not establish an order.
  ///
  /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument;
  ///   otherwise, `false`.
  /// - Returns: A sorted array of the sequence's elements.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
  @inlinable
  public static func sorted(
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> (Self) -> [Element] {
    { xs in xs.sorted(by: areInIncreasingOrder) }
  }

  /// A functional variant of the `guard` statement that returns `nil` if the
  /// given predicate `p` evaluates to `false`.
  ///
  /// This function is similar to `Sequence.filter(_:)` except it works on
  /// the Sequence instance as a whole.
  ///
  /// - Parameter predicate: A closure that takes this `Sequence` instance as
  ///   its argument and returns a `Boolean` value indicating whether it should
  ///   be kept or not.
  /// - Returns: The `Sequence` instance wrapped in an `Optional` if the
  ///   predicate evaluates to `true` or a `nil` if `false`.
  @_transparent
  public static func `guard`(
    _ predicate: @escaping (Self) -> Bool
  ) -> (Self) -> Self? {
    { xs in xs.guard(predicate) }
  }
}

extension Sequence where Element: Equatable {

  /// Returns a Boolean value indicating whether this sequence and another
  /// sequence contain the same elements in the same order.
  ///
  /// At least one of the sequences must be finite.
  ///
  /// - Parameter other: A sequence to compare to this sequence.
  /// - Returns: `true` if this sequence and `other` contain the same elements
  ///   in the same order.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public static func elementsEqual<OtherSequence: Sequence>(
    _ other: OtherSequence
  ) -> (Self) -> Bool where Element == OtherSequence.Element {
    { xs in xs.elementsEqual(other) }
  }

  /// Returns a Boolean value indicating whether the sequence contains the
  /// given element.
  ///
  /// - Parameter element: The element to find in the sequence.
  /// - Returns: `true` if the element was found in the sequence; otherwise,
  ///   `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
//  @inlinable
//  public static func contains(
//    _ element: Element
//  ) -> (Self) -> Bool {
//    { xs in xs.contains(element) }
//  }

  /// Returns a Boolean value indicating whether the sequence lacks an
  /// element satisfying the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the sequence lacks an element satisfying the
  ///   `predicate`; otherwise, `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public static func lacks(_ element: Element) -> (Self) -> Bool {
    { xs in xs.lacks(element) }
  }
}

extension Sequence where Element: Comparable {

  /// Returns the elements of the sequence, sorted.
  ///
  /// You can sort any sequence of elements that conform to the `Comparable`
  /// protocol by calling this method. Elements are sorted in ascending order.
  ///
  /// Here's an example of sorting a list of students' names. Strings in Swift
  /// conform to the `Comparable` protocol, so the names are sorted in
  /// ascending order according to the less-than operator (`<`).
  ///
  ///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
  ///     let sortedStudents = students.sorted()
  ///     print(sortedStudents)
  ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
  ///
  /// To sort the elements of your sequence in descending order, pass the
  /// greater-than operator (`>`) to the `sorted(by:)` method.
  ///
  ///     let descendingStudents = students.sorted(by: >)
  ///     print(descendingStudents)
  ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
  ///
  /// The sorting algorithm is not guaranteed to be stable. A stable sort
  /// preserves the relative order of elements that compare equal.
  ///
  /// - Parameter seq: The sequence to sort.
  /// - Returns: A sorted array of the sequence's elements.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
  @inlinable
  public static func sorted(_ seq: Self) -> [Element] {
    seq.sorted()
  }
}

extension BidirectionalCollection {

  /// Returns a view presenting the elements of the collection in reverse
  /// order.
  ///
  /// You can reverse a collection without allocating new space for its
  /// elements by calling this `reversed()` method. A `ReversedCollection`
  /// instance wraps an underlying collection and provides access to its
  /// elements in reverse order. This example prints the characters of a
  /// string in reverse order:
  ///
  ///     let word = "Backwards"
  ///     for char in word.reversed() {
  ///         print(char, terminator: "")
  ///     }
  ///     // Prints "sdrawkcaB"
  ///
  /// If you need a reversed collection of the same type, you may be able to
  /// use the collection's sequence-based or collection-based initializer. For
  /// example, to get the reversed version of a string, reverse its
  /// characters and initialize a new `String` instance from the result.
  ///
  ///     let reversedWord = String(word.reversed())
  ///     print(reversedWord)
  ///     // Prints "sdrawkcaB"
  ///
  /// - Complexity: O(1)
  @inlinable
  public static func reversed(_ xs: Self) -> ReversedCollection<Self> {
    xs.reversed()
  }
}

extension BidirectionalCollection where SubSequence: Identity {

  /// Returns a subsequence containing the last elements until the predicate
  /// `ρ` returns `false` and skipping the remaining elements.
  ///
  /// This is an idiomatic Haskell variant with declarative arguments coming
  /// first and returning a reusable/composable ƒ accepting `Self`:
  ///
  ///     let totalPoints = reduce(+) • map(points) • filter(wasSpoken)
  ///
  /// _"Let totalPoints be the sum of the points that were spoken."_
  ///
  ///     func totalPoints(for entries: [Entry]) -> Int {
  ///         return entries
  ///             .filter(wasSpoken)
  ///             .map(points)
  ///             .reduce(+)
  ///     }
  ///
  /// _"Function totalPoints for a list of entries that will: Take the
  /// entries, keep those that were spoken, get their points, sum them."_
  ///
  /// - - -
  ///
  /// - Parameter ρ: A closure that takes an element of the sequence as its
  ///   argument and returns `true` if the element should be included or
  ///   `false` if it should be excluded. Once the predicate returns `false`
  ///   it will not be called again.
  /// - Returns: A sequence starting after the last element to satisfy `ρ`.
  /// - Complexity: O(*k*), where *k* is the length of the result.
  @inlinable
  public static func suffix(
    while ρ: @escaping (Element) -> Bool
  ) -> (Self) -> SubSequence {
    flip(suffix)(ρ)
  }
}

extension BidirectionalCollection
  where SubSequence: Identity, Element: Equatable
{
  // MARK: Suffix

  /// Returns a subsequence from the last index of the given element to the
  /// end of the collection.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence from the last index of the given element to
  ///   the end of the collection.
  @inlinable
  public static func suffix(fromLast ε: Element) -> (Self) -> SubSequence {
    flip(suffix(fromLast:))(ε)
  }

  // MARK: Prefix


  /// Returns a subsequence from the start of the collection up to, but not
  /// including, the first index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, but not including, the first index of
  ///   the given element.
  @inlinable
  public static func prefix(upTo ε: Element) -> (Self) -> SubSequence {
    flip(prefix(upTo:))(ε)
  }

  /// Returns a subsequence from the start of the collection through the
  /// first index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, and including, the first index of the
  ///   given element.
  @inlinable
  public static func prefix(through ε: Element) -> (Self) -> SubSequence {
    flip(prefix(through:))(ε)
  }

  /// Returns a subsequence from the start of the collection up to, but not
  /// including, the last index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, but not including, the last index of
  ///   the given element.
  @inlinable
  public static func prefix(upToLast ε: Element) -> (Self) -> SubSequence {
    flip(prefix(upToLast:))(ε)
  }

  /// Returns a subsequence from the start of the collection through the
  /// last index of the given element.
  ///
  /// - Parameter ε: The element to search.
  /// - Returns: A subsequence up to, and including, the last index of the
  ///   given element.
  @inlinable
  public static func prefix(throughLast ε: Element) -> (Self) -> SubSequence {
    flip(prefix(throughLast:))(ε)
  }
}

extension RangeReplaceableCollection {

  // MARK: Append

  @_transparent
  public static func append(_ element: Element) -> (inout Self) -> () {
    { xs in xs.append(element) }
  }

  @_transparent
  public static func append(contentsOf elements: Self) -> (inout Self) -> () {
    { xs in xs.append(contentsOf: elements) }
  }

  @_transparent
  public static func appending(_ element: Element) -> (Self) -> Self {
    { xs in xs.appending(element) }
  }

  @_transparent
  public static func appending(contentsOf ys: Self) -> (Self) -> Self {
    { xs in xs.appending(contentsOf: ys) }
  }

  // MARK: Prepend

  @_transparent
  public static func prepend(_ element: Element) -> (inout Self) -> () {
    { xs in xs.prepend(element) }
  }

  @_transparent
  public static func prepend(contentsOf elements: Self) -> (inout Self) -> () {
    { xs in xs.prepend(contentsOf: elements) }
  }

  @_transparent
  public static func prepending(_ element: Element) -> (Self) -> Self {
    { xs in xs.prepending(element) }
  }

  @_transparent
  public static func prepending(contentsOf ys: Self) -> (Self) -> Self {
    { xs in xs.prepending(contentsOf: ys) }
  }

  // MARK: Insert

  @_transparent
  public static func inserting(
    _ newElement: Element,
    at index: Index
  ) -> (Self) -> Self {
    { xs in xs.inserting(newElement, at: index) }
  }

  @_transparent
  public static func inserting(
    contentsOf xs: Self,
    at index: Index
  ) -> (Self) -> Self {
    { xs in xs.inserting(contentsOf: xs, at: index) }
  }

  @_transparent
  public static func inserting(
    _ newElement: Element,
    where predicate: @escaping (Element) -> Bool
  ) -> (Self) -> Self {
    { xs in xs.inserting(newElement, where: predicate) }
  }

  @_transparent
  public static func inserting(
    contentsOf xs: Self,
    where predicate: @escaping (Element) -> Bool
  ) -> (Self) -> Self {
    { xs in xs.inserting(contentsOf: xs, where: predicate) }
  }

  // MARK: Remove

  @_transparent
  public static func removing(
    subrange: Range<Index>
  ) -> (Self) -> Self {
    { xs in xs.removing(subrange: subrange) }
  }

  @_transparent
  public static func removingAll(
    where ρ: @escaping (Element) -> Bool
  ) -> (Self) -> Self {
    { xs in xs.removingAll(where: ρ) }
  }
}

extension MutableCollection where Element: Equatable {

  @_transparent
  public static func replacing(
    _ element: Element,
    with replacement: Element
  ) -> (Self) -> Self {
    { xs in xs.replacing(element, with: replacement) }
  }
}

extension RangeReplaceableCollection where Element: Equatable {

  @_transparent
  public static func replacing(
    _ element: Element,
    with replacement: Element
    ) -> (Self) -> Self {
    { xs in xs.replacing(element, with: replacement) }
  }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {

  @_transparent
  public static func removingLast(xs: Self) -> Self {
    xs.removingLast()
  }

  @_transparent
  public static func removingLast(_ n: Int) -> (Self) -> Self {
    { xs in xs.removing(last: n) }
  }
}

// MARK: -
// MARK: - Property thunks

extension Sequence {

  /// A sequence containing the same elements as this sequence, but on which
  /// some operations, such as map and filter, are implemented lazily.
  @_transparent
  public static func lazy(_ it: Self) -> LazySequence<Self> {
    it.lazy
  }

  /// A value less than or equal to the number of elements in the sequence,
  /// calculated nondestructively.
  ///
  /// The default implementation returns `0`. If you provide your own
  /// implementation, make sure to compute the value nondestructively.
  ///
  /// - Complexity: O(1), except if the sequence also conforms to `Collection`.
  /// In this case, see the documentation of `Collection.underestimatedCount`.
  @_transparent
  public static func underestimatedCount(_ it: Self) -> Int {
    it.underestimatedCount
  }
}

extension Collection {

  /// A Boolean value indicating whether the collection has any
  /// elements in it.
  ///
  /// When you need to check whether your collection has elements, use the
  /// `hasElements` property instead of checking that the `count` property is
  /// greater than zero. For collections that don't conform to
  /// `RandomAccessCollection`, accessing the `count` property iterates
  /// through the elements of the collection.
  ///
  /// - Complexity: O(1)
  @_transparent
  public static func hasElements(_ seq: Self) -> Bool {
    seq.hasElements
  }

  /// Accesses the element at the specified position.
  ///
  /// The following example accesses an element of an array through its
  /// subscript to print its value:
  ///
  ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     print(streets[1])
  ///     // Prints "Bryant"
  ///
  /// You can subscript a collection with any valid index other than the
  /// collection's end index. The end index refers to the position one past
  /// the last element of a collection, so it doesn't correspond with an
  /// element.
  ///
  /// - Parameter i: The index of the element to access. `i` must be a valid
  ///   index of the collection that is not equal to the `endIndex` property.
  /// - Complexity: O(1)
  @_transparent
  public static func at(_ i: Index) -> (Self) -> Element? {
    flip(at)(i)
  }

  /// Accesses the contiguous subrange of the collection's elements specified
  /// by a range expression.
  ///
  /// The range expression is converted to a concrete subrange relative to this
  /// collection. For example, using a `PartialRangeFrom` range expression
  /// with an array accesses the subrange from the start of the range
  /// expression until the end of the array.
  ///
  ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     let streetsSlice = streets[2...]
  ///     print(streetsSlice)
  ///     // ["Channing", "Douglas", "Evarts"]
  ///
  /// The accessed slice uses the same indices for the same elements as the
  /// original collection uses. This example searches `streetsSlice` for one
  /// of the strings in the slice, and then uses that index in the original
  /// array.
  ///
  ///     let index = streetsSlice.firstIndex(of: "Evarts")    // 4
  ///     print(streets[index!])
  ///     // "Evarts"
  ///
  /// Always use the slice's `startIndex` property instead of assuming that its
  /// indices start at a particular value. Attempting to access an element by
  /// using an index outside the bounds of the slice's indices may result in a
  /// runtime error, even if that index is valid for the original collection.
  ///
  ///     print(streetsSlice.startIndex)
  ///     // 2
  ///     print(streetsSlice[2])
  ///     // "Channing"
  ///
  ///     print(streetsSlice[0])
  ///     // error: Index out of bounds
  ///
  /// - Parameter bounds: A range of the collection's indices. The bounds of
  ///   the range must be valid indices of the collection.
  /// - Complexity: O(1)
  @_transparent
  public static func elements<R: RangeExpression>(
    in r: R
  ) -> (Self) -> SubSequence where R.Bound == Index {
    { xs in xs[r] }
  }

  /// A range expression that represents the entire range of a collection.
  ///
  /// You can use the unbounded range operator (`...`) to create a slice of a
  /// collection that contains all of the collection's elements. Slicing with an
  /// unbounded range is essentially a conversion of a collection instance into
  /// its slice type.
  ///
  /// For example, the following code declares `countLetterChanges(_:_:)`, a
  /// function that finds the number of changes required to change one
  /// word or phrase into another. The function uses a recursive approach to
  /// perform the same comparisons on smaller and smaller pieces of the original
  /// strings. In order to use recursion without making copies of the strings at
  /// each step, `countLetterChanges(_:_:)` uses `Substring`, a string's slice
  /// type, for its parameters.
  ///
  ///     func countLetterChanges(_ s1: Substring, _ s2: Substring) -> Int {
  ///         if s1.isEmpty { return s2.count }
  ///         if s2.isEmpty { return s1.count }
  ///
  ///         let cost = s1.first == s2.first ? 0 : 1
  ///
  ///         return min(
  ///             countLetterChanges(s1.dropFirst(), s2) + 1,
  ///             countLetterChanges(s1, s2.dropFirst()) + 1,
  ///             countLetterChanges(s1.dropFirst(), s2.dropFirst()) + cost)
  ///     }
  ///
  /// To call `countLetterChanges(_:_:)` with two strings, use an unbounded
  /// range in each string's subscript.
  ///
  ///     let word1 = "grizzly"
  ///     let word2 = "grisly"
  ///     let changes = countLetterChanges(word1[...], word2[...])
  ///     // changes == 2
  ///
  /// - Parameter r: The unbounded range operator (`...`) is valid only within
  ///   a collection's subscript.
  /// - Returns: Creates an unbounded range expression.
  /// - Complexity: O(1)
  @_transparent
  public static func elements(
    in r: @escaping (UnboundedRange_) -> ()
  ) -> (Self) -> SubSequence {
    { xs in xs[r] }
  }

  /// A Boolean value indicating whether the collection is empty.
  ///
  /// When you need to check whether your collection is empty, use the
  /// `isEmpty` property instead of checking that the `count` property is
  /// equal to zero. For collections that don't conform to
  /// `RandomAccessCollection`, accessing the `count` property iterates
  /// through the elements of the collection.
  ///
  ///     let horseName = "Silver"
  ///     if horseName.isEmpty {
  ///         print("I've been through the desert on a horse with no name.")
  ///     } else {
  ///         print("Hi ho, \(horseName)!")
  ///     }
  ///     // Prints "Hi ho, Silver!"
  ///
  /// - Complexity: O(1)
  @_transparent
  public static func isEmpty(_ it: Self) -> Bool {
    it.isEmpty
  }

  /// The number of elements in the collection.
  ///
  /// To check whether a collection is empty, use its `isEmpty` property
  /// instead of comparing `count` to zero. Unless the collection guarantees
  /// random-access performance, calculating `count` can be an O(*n*)
  /// operation.
  ///
  /// - Complexity: O(1) if the collection conforms to
  ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
  ///   of the collection.
  @_transparent
  public static func count(_ it: Self) -> Int {
    it.count
  }

  /// The first element of the collection.
  ///
  /// If the collection is empty, the value of this property is `nil`.
  ///
  ///     let numbers = [10, 20, 30, 40, 50]
  ///     if let firstNumber = numbers.first {
  ///         print(firstNumber)
  ///     }
  ///     // Prints "10"
  @_transparent
  public static func first(_ it: Self) -> Element? {
    it.first
  }

  /// The position of the first element in a nonempty collection.
  ///
  /// If the collection is empty, `startIndex` is equal to `endIndex`.
  @_transparent
  public static func startIndex(_ it: Self) -> Index {
    it.startIndex
  }

  /// The collection's "past the end" position---that is, the position one
  /// greater than the last valid subscript argument.
  ///
  /// When you need a range that includes the last element of a collection, use
  /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
  /// creates a range that doesn't include the upper bound, so it's always
  /// safe to use with `endIndex`. For example:
  ///
  ///     let numbers = [10, 20, 30, 40, 50]
  ///     if let index = numbers.firstIndex(of: 30) {
  ///         print(numbers[index ..< numbers.endIndex])
  ///     }
  ///     // Prints "[30, 40, 50]"
  ///
  /// If the collection is empty, `endIndex` is equal to `startIndex`.
  @_transparent
  public static func endIndex(_ it: Self) -> Index {
    it.endIndex
  }

  /// The indices that are valid for subscripting the collection, in ascending
  /// order.
  ///
  /// A collection's `indices` property can hold a strong reference to the
  /// collection itself, causing the collection to be nonuniquely referenced.
  /// If you mutate the collection while iterating over its indices, a strong
  /// reference can result in an unexpected copy of the collection. To avoid
  /// the unexpected copy, use the `index(after:)` method starting with
  /// `startIndex` to produce indices instead.
  ///
  ///     var c = MyFancyCollection([10, 20, 30, 40, 50])
  ///     var i = c.startIndex
  ///     while i != c.endIndex {
  ///         c[i] /= 5
  ///         i = c.index(after: i)
  ///     }
  ///     // c == MyFancyCollection([2, 4, 6, 8, 10])
  @_transparent
  public static func indices(_ it: Self) -> Indices {
    it.indices
  }
}

extension Collection /*where SubSequence == Slice<Self>*/ {

  /// Accesses a contiguous subrange of the collection's elements.
  ///
  /// For example, using a `PartialRangeFrom` range expression with an array
  /// accesses the subrange from the start of the range expression until the
  /// end of the array.
  ///
  ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     let streetsSlice = streets[2..<5]
  ///     print(streetsSlice)
  ///     // ["Channing", "Douglas", "Evarts"]
  ///
  /// The accessed slice uses the same indices for the same elements as the
  /// original collection. This example searches `streetsSlice` for one of the
  /// strings in the slice, and then uses that index in the original array.
  ///
  ///     let index = streetsSlice.firstIndex(of: "Evarts")!    // 4
  ///     print(streets[index])
  ///     // "Evarts"
  ///
  /// Always use the slice's `startIndex` property instead of assuming that its
  /// indices start at a particular value. Attempting to access an element by
  /// using an index outside the bounds of the slice may result in a runtime
  /// error, even if that index is valid for the original collection.
  ///
  ///     print(streetsSlice.startIndex)
  ///     // 2
  ///     print(streetsSlice[2])
  ///     // "Channing"
  ///
  ///     print(streetsSlice[0])
  ///     // error: Index out of bounds
  ///
  /// - Parameter bounds: A range of the collection's indices. The bounds of
  ///   the range must be valid indices of the collection.
  /// - Complexity: O(1)
  @_transparent
  public static func elements(in range: Range<Index>) -> (Self) -> SubSequence {
    { xs in xs.in(range) }
  }
}

extension BidirectionalCollection {

  /// The last element of the collection.
  ///
  /// If the collection is empty, the value of this property is `nil`.
  ///
  ///     let numbers = [10, 20, 30, 40, 50]
  ///     if let lastNumber = numbers.last {
  ///         print(lastNumber)
  ///     }
  ///     // Prints "50"
  ///
  /// - Complexity: O(1)
  @_transparent
  public static func last(_ xs: Self) -> Element? {
    xs.last
  }
}

extension LazySequenceProtocol where Self == Elements {

  /// A sequence containing the same elements as this one, possibly with
  /// a simpler type.
  ///
  /// When implementing lazy operations, wrapping `elements` instead
  /// of `self` can prevent result types from growing an extra
  /// `LazySequence` layer.  For example,
  ///
  /// _prext_ example needed
  ///
  /// Note: this property need not be implemented by conforming types,
  /// it has a default implementation in a protocol extension that
  /// just returns `self`.
  @_transparent
  public static func elements(_ it: Self) -> Elements {
    it.elements
  }
}

// MARK: -
// MARK: - Free thunks

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
public func fmap<S: Sequence, T, U>(
  _ λ: @escaping (T) -> U
) -> (S) -> [U] where S.Element == T {
  S.fmap(λ)
}

/// Returns an array containing the non-`nil` results of calling the given
/// transformation with each element of this sequence.
///
/// Use this method to receive an array of non-optional values when your
/// transformation produces an optional value.
///
/// In this example, note the difference in the result of using `map` and
/// `compactMap` with a transformation that returns an optional `Int` value.
///
///     let possibleNumbers = ["1", "2", "three", "///4///", "5"]
///
///     let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
///     // [1, 2, nil, nil, 5]
///
///     let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
///     // [1, 2, 5]
///
/// - Parameter transform: A closure that accepts an element of this
///   sequence as its argument and returns an optional value.
/// - Returns: An array of the non-`nil` results of calling `transform`
///   with each element of the sequence.
///
/// - Complexity: O(*m* + *n*), where *n* is the length of this sequence
///   and *m* is the length of the result.
@inlinable
public func compactMap<S: Sequence, T, U>(
  _ λ: @escaping (T) -> U?
) -> (S) -> [U] where S.Element == T {
  S.compactMap(λ)
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
public func apply<S: Sequence, T, U>(
  _ λs: [(T) -> U]
) -> (S) -> [U] where S.Element == T {
  S.apply(λs)
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
public func flatMap<S: Sequence, SegmentOfResult: Sequence>(
  _ λ: @escaping (S.Element) throws -> SegmentOfResult
) rethrows -> (S) throws -> [SegmentOfResult.Element] {
  try S.flatMap(λ)
}

/// Evaluates the given closure when this `Optional` instance is not `nil`,
/// passing the unwrapped value as a parameter.
///
/// Use the `bind` method with a closure that returns an optional value.
///
/// - Note: A Monad. `flatMap` is an ad-hoc monadic implementation of `bind`.
/// - Parameter transform: A closure that takes the unwrapped value
///   of the instance.
/// - Returns: The result of the given closure. If this instance is `nil`,
///   returns `nil`.
@inlinable
public func bind<S: Sequence, SegmentOfResult: Sequence>(
  _ λ: @escaping (S.Element) -> SegmentOfResult
) -> (S) -> [SegmentOfResult.Element] {
  S.bind(λ)
}

/// Calls the given closure on each element in the sequence in the same order
/// as a `for`-`in` loop.
///
/// Using the `forEach` method is distinct from a `for`-`in` loop in two
/// important ways:
///
/// 1. You cannot use a `break` or `continue` statement to exit the current
///    call of the `body` closure or skip subsequent calls.
/// 2. Using the `return` statement in the `body` closure will exit only from
///    the current call to `body`, not from any outer scope, and won't skip
///    subsequent calls.
///
/// - Parameter body: A closure that takes an element of the sequence as a
///   parameter.
@inlinable
public func forEach<S: Sequence, T> (
  _ body: @escaping (T) -> ()
) -> (S) -> () where S.Element == T {
  S.forEach(body)
}

/// A Boolean value indicating whether the collection is empty.
///
/// When you need to check whether your collection is empty, use the
/// `isEmpty` property instead of checking that the `count` property is
/// equal to zero. For collections that don't conform to
/// `RandomAccessCollection`, accessing the `count` property iterates
/// through the elements of the collection.
///
/// - Parameter collection: A collection to check.
/// - Complexity: O(1)
@inlinable
public func isEmpty<C: Collection>(_ collection: C) -> Bool {
  collection.isEmpty
}

/// A Boolean value indicating whether the collection has elements.
///
/// - Parameter collecti ,
public func hasElements<C: Collection>(_ collection: C) -> Bool {
  !collection.isEmpty
}

/// Returns a Boolean value indicating whether the sequence contains the
/// given element.
///
/// - Parameter element: The element to find in the sequence.
/// - Returns: `true` if the element was found; otherwise, `false`.
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func lacks<S: Sequence>(
  _ element: S.Element
) -> (S) -> Bool where S.Element: Equatable {
  S.lacks(element)
}

/// Returns an array containing, in order, the elements of the sequence
/// that satisfy the given predicate.
///
/// - Parameter isIncluded: A closure that takes an element of the
///   sequence as its argument and returns a Boolean value indicating
///   whether the element should be included in the returned array.
/// - Returns: An array of the elements that `isIncluded` allowed.
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func filter<S: Sequence>(
  _ isIncluded: @escaping (S.Element) -> Bool
) -> (S) -> [S.Element] {
  S.filter(isIncluded)
}

/// Returns a sequence of pairs `(n, x)`, where `n` represents a consecutive
/// integer starting at zero and `x` represents an element of the sequence.
///
/// When you enumerate a collection, the integer part of each pair is a counter
/// for the enumeration, but is not necessarily the index of the paired value.
/// These counters can be used as indices only in instances of zero-based,
/// integer-indexed collections, such as `Array` and `ContiguousArray`. For
/// other collections the counters may be out of range or of the wrong type
/// to use as an index. To iterate over the elements of a collection with its
/// indices, use the `zip(_:_:)` function.
///
/// - Returns: A sequence of pairs enumerating the sequence.
/// - Complexity: O(1)
@inlinable
public func enumerated<S: Sequence>(
  _ seq: S
) -> EnumeratedSequence<S> {
  seq.enumerated()
}

/// Returns an array containing the elements of this sequence in reverse
/// order.
///
/// The sequence must be finite.
///
/// - Returns: An array containing the elements of this sequence in
///   reverse order.
///
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func reversed<S: Sequence>(_ xs: S) -> [S.Element] {
  xs.reversed()
}

/// Returns a view presenting the elements of the collection in reverse
/// order.
///
/// You can reverse a collection without allocating new space for its
/// elements by calling this `reversed()` method. A `ReversedCollection`
/// instance wraps an underlying collection and provides access to its
/// elements in reverse order. This example prints the characters of a
/// string in reverse order:
///
///     let word = "Backwards"
///     for char in word.reversed() {
///         print(char, terminator: "")
///     }
///     // Prints "sdrawkcaB"
///
/// If you need a reversed collection of the same type, you may be able to
/// use the collection's sequence-based or collection-based initializer. For
/// example, to get the reversed version of a string, reverse its
/// characters and initialize a new `String` instance from the result.
///
///     let reversedWord = String(word.reversed())
///     print(reversedWord)
///     // Prints "sdrawkcaB"
///
/// - Complexity: O(1)
@inlinable
public func reversed<S: BidirectionalCollection>(_ xs: S) -> ReversedCollection<S> {
  xs.reversed()
}

/// Returns the elements of the sequence, sorted using the given predicate as
/// the comparison between elements.
///
/// When you want to sort a sequence of elements that don't conform to the
/// `Comparable` protocol, pass a predicate to this method that returns
/// `true` when the first element should be ordered before the second. The
/// elements of the resulting array are ordered according to the given
/// predicate.
///
/// In the following example, the predicate provides an ordering for an array
/// of a custom `HTTPResponse` type. The predicate orders errors before
/// successes and sorts the error responses by their error code.
///
///     enum HTTPResponse {
///         case ok
///         case error(Int)
///     }
///
///     let responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
///     let sortedResponses = responses.sorted {
///         switch ($0, $1) {
///         // Order errors by code
///         case let (.error(aCode), .error(bCode)):
///             return aCode < bCode
///
///         // All successes are equivalent, so none is before any other
///         case (.ok, .ok): return false
///
///         // Order errors before successes
///         case (.error, .ok): return true
///         case (.ok, .error): return false
///         }
///     }
///     print(sortedResponses)
///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
///
/// You also use this method to sort elements that conform to the
/// `Comparable` protocol in descending order. To sort your sequence in
/// descending order, pass the greater-than operator (`>`) as the
/// `areInIncreasingOrder` parameter.
///
///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
///     let descendingStudents = students.sorted(by: >)
///     print(descendingStudents)
///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
///
/// Calling the related `sorted()` method is equivalent to calling this
/// method and passing the less-than operator (`<`) as the predicate.
///
///     print(students.sorted())
///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
///     print(students.sorted(by: <))
///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
///
/// The predicate must be a *strict weak ordering* over the elements. That
/// is, for any elements `a`, `b`, and `c`, the following conditions must
/// hold:
///
/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
///   both `true`, then `areInIncreasingOrder(a, c)` is also `true`.
///   (Transitive comparability)
/// - Two elements are *incomparable* if neither is ordered before the other
///   according to the predicate. If `a` and `b` are incomparable, and `b`
///   and `c` are incomparable, then `a` and `c` are also incomparable.
///   (Transitive incomparability)
///
/// The sorting algorithm is not guaranteed to be stable. A stable sort
/// preserves the relative order of elements for which
/// `areInIncreasingOrder` does not establish an order.
///
/// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
///   first argument should be ordered before its second argument;
///   otherwise, `false`.
/// - Returns: A sorted array of the sequence's elements.
///
/// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
@inlinable
public func sorted<S: Sequence>(
  by areInIncreasingOrder: @escaping (S.Element, S.Element) -> Bool
) -> (S) -> [S.Element] {
  S.sorted(by: areInIncreasingOrder)
}

/// Returns the elements of the sequence, sorted.
///
/// You can sort any sequence of elements that conform to the `Comparable`
/// protocol by calling this method. Elements are sorted in ascending order.
///
/// Here's an example of sorting a list of students' names. Strings in Swift
/// conform to the `Comparable` protocol, so the names are sorted in
/// ascending order according to the less-than operator (`<`).
///
///     let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
///     let sortedStudents = students.sorted()
///     print(sortedStudents)
///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
///
/// To sort the elements of your sequence in descending order, pass the
/// greater-than operator (`>`) to the `sorted(by:)` method.
///
///     let descendingStudents = students.sorted(by: >)
///     print(descendingStudents)
///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
///
/// The sorting algorithm is not guaranteed to be stable. A stable sort
/// preserves the relative order of elements that compare equal.
///
/// - Parameter seq: The sequence to sort.
/// - Returns: A sorted array of the sequence's elements.
///
/// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
@inlinable
public func sorted<S: Sequence>(
  _ seq: S
) -> [S.Element] where S.Element: Comparable {
  S.sorted(seq)
}

/// Returns the result of combining the elements of the sequence using the
/// given closure.
///
/// Use the `reduce(_:_:)` method to produce a single value from the elements
/// of an entire sequence. For example, you can use this method on an array
/// of numbers to find their sum or product.
///
/// The `nextPartialResult` closure is called sequentially with an
/// accumulating value initialized to `initialResult` and each element of
/// the sequence. This example shows how to find the sum of an array of
/// numbers.
///
///     let numbers = [1, 2, 3, 4]
///     let numberSum = numbers.reduce(0, { x, y in
///         x + y
///     })
///     // numberSum == 10
///
/// When `numbers.reduce(_:_:)` is called, the following steps occur:
///
/// 1. The `nextPartialResult` closure is called with `initialResult`---`0`
///    in this case---and the first element of `numbers`, returning the sum:
///    `1`.
/// 2. The closure is called again repeatedly with the previous call's return
///    value and each element of the sequence.
/// 3. When the sequence is exhausted, the last value returned from the
///    closure is returned to the caller.
///
/// If the sequence has no elements, `nextPartialResult` is never executed
/// and `initialResult` is the result of the call to `reduce(_:_:)`.
///
/// - Parameters:
///   - initialResult: The value to use as the initial accumulating value.
///     `initialResult` is passed to `nextPartialResult` the first time the
///     closure is executed.
///   - nextPartialResult: A closure that combines an accumulating value and
///     an element of the sequence into a new accumulating value, to be used
///     in the next call of the `nextPartialResult` closure or returned to
///     the caller.
/// - Returns: The final accumulated value. If the sequence has no elements,
///   the result is `initialResult`.
///
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func reduce<S: Sequence, U>(
  _ initialResult: U,
  _ nextPartialResult: @escaping (U, S.Element) -> U
) -> (S) -> U {
  { xs in xs.reduce(initialResult, nextPartialResult) }
}

/// Returns the result of combining the elements of the sequence using the
/// given closure.
///
/// Use the `reduce(into:_:)` method to produce a single value from the
/// elements of an entire sequence. For example, you can use this method on an
/// array of integers to filter adjacent equal entries or count frequencies.
///
/// This method is preferred over `reduce(_:_:)` for efficiency when the
/// result is a copy-on-write type, for example an Array or a Dictionary.
///
/// The `updateAccumulatingResult` closure is called sequentially with a
/// mutable accumulating value initialized to `initialResult` and each element
/// of the sequence. This example shows how to build a dictionary of letter
/// frequencies of a string.
///
///     let letters = "abracadabra"
///     let letterCount = letters.reduce(into: [:]) { counts, letter in
///         counts[letter, default: 0] += 1
///     }
///     // letterCount == ["a": 5, "b": 2, "r": 2, "c": 1, "d": 1]
///
/// When `letters.reduce(into:_:)` is called, the following steps occur:
///
/// 1. The `updateAccumulatingResult` closure is called with the initial
///    accumulating value---`[:]` in this case---and the first character of
///    `letters`, modifying the accumulating value by setting `1` for the key
///    `"a"`.
/// 2. The closure is called again repeatedly with the updated accumulating
///    value and each element of the sequence.
/// 3. When the sequence is exhausted, the accumulating value is returned to
///    the caller.
///
/// If the sequence has no elements, `updateAccumulatingResult` is never
/// executed and `initialResult` is the result of the call to
/// `reduce(into:_:)`.
///
/// - Parameters:
///   - initialResult: The value to use as the initial accumulating value.
///   - updateAccumulatingResult: A closure that updates the accumulating
///     value with an element of the sequence.
/// - Returns: The final accumulated value. If the sequence has no elements,
///   the result is `initialResult`.
///
/// - Complexity: O(*n*), where *n* is the length of the sequence.
@inlinable
public func reduce<S: Sequence, Result>(
  into initialResult: __owned Result,
  _ updateAccumulatingResult: @escaping (inout Result, S.Element) -> ()
) -> (S) -> Result {
  { xs in xs.reduce(into: initialResult, updateAccumulatingResult) }
}

/// Returns a new string by concatenating the elements of the given sequence.
///
/// - Returns: A single, concatenated string.
@inlinable
public func join<S: Sequence>(
  _ seq: S
) -> String where S.Element: StringProtocol {
  seq.joined()
}

/// Returns a new string by concatenating the elements of the sequence,
/// adding the given separator between each element.
///
/// The following example shows how an array of strings can be joined to a
/// single, comma-separated string:
///
///     print(["Vivien", "Marlon", "Kim", "Karl"] => join(separator: ", "))
///     // Prints "Vivien, Marlon, Kim, Karl"
///
/// - Parameter separator: A string to insert between each element.
/// - Returns: A single, concatenated string.
@inlinable
public func join<S: Sequence>(
  separator: String
) -> (S) -> String where S.Element: StringProtocol {
  { xs in xs.joined(separator: separator) }
}

/// Returns a Boolean value indicating whether this sequence and another
/// sequence contain the same elements in the same order.
///
/// This example tests whether one countable range shares the same elements
/// as another countable range and an array.
///
///     let a = 1...3
///     let b = 1...10
///
///     print(a.elementsEqual(b))
///     // Prints "false"
///     print(a.elementsEqual([1, 2, 3]))
///     // Prints "true"
///
/// - Requires: At least one of the sequences must be finite.
/// - Parameters:
///   - seq₁: A sequence to compare to `seq₂`.
///   - seq₂: A sequence to compare to `seq₁`.
/// - Returns: `true` if `seq₁` and `seq₂` contain the same elements in order.
///
/// - Complexity: O(*m*), where *m* is the lesser of the length of `seq₁` and
///   the length of `seq₂`.
@inlinable
public func elementsEqual<S: Sequence>(
  _ seq₁: S, _ seq₂: S
) -> Bool where S.Element: Equatable {
  seq₁.elementsEqual(seq₂)
}

/// Returns a Boolean value indicating whether this sequence and another
/// sequence **do not** contain the same elements in the same order.
///
/// This example tests whether one countable range don't share the same elements
/// as another countable range and an array.
///
///     let a = 1...3
///     let b = 1...10
///
///     print(a.elementsDiffer(b))
///     // Prints "true"
///     print(a.elementsDiffer([1, 2, 3]))
///     // Prints "false"
///
/// - Requires: At least one of the sequences must be finite.
/// - Parameters:
///   - seq₁: A sequence to compare to `seq₂`.
///   - seq₂: A sequence to compare to `seq₁`.
/// - Returns: `false` if `seq₁` and `seq₂` contain the same elements in order.
///
/// - Complexity: O(*m*), where *m* is the lesser of the length of `seq₁` and
///   the length of `seq₂`.
@inlinable
public func elementsDiffer<S: Sequence>(
  _ seq₁: S, _ seq₂: S
) -> Bool where S.Element: Equatable {
  !seq₁.elementsEqual(seq₂)
}

/// Returns a Boolean value indicating whether this sequence and another
/// sequence contain equivalent elements in the same order, using the given
/// predicate as the equivalence test.
///
/// At least one of the sequences must be finite.
///
/// The predicate must be a *equivalence relation* over the elements. That
/// is, for any elements `a`, `b`, and `c`, the following conditions must
/// hold:
///
/// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
/// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
/// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
///   `areEquivalent(a, c)` is also `true`. (Transitivity)
///
/// - Parameters:
///   - areEquivalent: A predicate that returns `true` if its two arguments
///     are equivalent; otherwise, `false`.
/// - Returns: `true` if this sequence and `other` contain equivalent items,
///   using `areEquivalent` as the equivalence test; otherwise, `false.`
///
/// - Complexity: O(*m*), where *m* is the lesser of the length of the
///   sequence and the length of `other`.
@inlinable
public func elementsEqual<S₁: Sequence, S₂: Sequence>(
  by areEquivalent: @escaping (S₁.Element, S₂.Element) -> Bool
) -> (S₁, S₂) -> Bool {
  { s₁, s₂ in s₁.elementsEqual(s₂, by: areEquivalent) }
}

/// Creates a sequence of pairs built out of two underlying sequences.
///
/// In the `Zip2Sequence` instance returned by this function, the elements of
/// the *i*th pair are the *i*th elements of each underlying sequence. The
/// following example uses the `zip(_:_:)` function to iterate over an array
/// of strings and a countable range at the same time:
///
///     let words = ["one", "two", "three", "four"]
///     let numbers = 1...4
///
///     for (word, number) in zip(words, numbers) {
///         print("\(word): \(number)")
///     }
///     // Prints "one: 1"
///     // Prints "two: 2
///     // Prints "three: 3"
///     // Prints "four: 4"
///
/// If the two sequences passed to `zip(_:_:)` are different lengths, the
/// resulting sequence is the same length as the shorter sequence. In this
/// example, the resulting array is the same length as `words`:
///
///     let naturalNumbers = 1...Int.max
///     let zipped = Array(zip(words, naturalNumbers))
///     // zipped == [("one", 1), ("two", 2), ("three", 3), ("four", 4)]
///
/// - Parameters:
///   - sequence1: The first sequence or collection to zip.
///   - sequence2: The second sequence or collection to zip.
/// - Returns: A sequence of tuple pairs, where the elements of each pair are
///   corresponding elements of `sequence1` and `sequence2`.
@inlinable
public func zip<U, S₁: Sequence, S₂: Sequence>(
  with transform: @escaping (S₁.Element, S₂.Element) -> U
) -> (S₁, S₂) -> LazyMapSequence<Zip2Sequence<S₁, S₂>, U> {
  { zip($0, $1).lazy.map(transform) }
}
