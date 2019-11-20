// Structure-preserving higher-order endomorphisms
import Swift

// MARK: -
// MARK: - Free thunks

///// Maps `.some` given value to the given closure.
//@_transparent
//public func fmap<T, U>(_ λ: @escaping (T) -> U) -> (Set<T>) -> Set<U> {
//  return Set.fmap(λ) >>> Set.init
//}
//
///// Maps `.some` given value to the given closure.
//@_transparent
//public func compactMap<T, U>(_ λ: @escaping (T) -> U?) -> (Set<T>) -> Set<U> {
//  return Set.compactMap(λ) >>> Set.init
//}
//
///// Applies `.some` given closure to `.some` given value.
//@_transparent
//public func apply<T, U>(_ λs: [(T) -> U]) -> (Set<T>) -> Set<U> {
//  return Set.apply(λs) >>> Set.init
//}
//
///// Maps `.some` given value to the given closure and unwraps its results.
//@_transparent
//public func bind<T, U>(_ λ: @escaping (T) -> [U]) -> (Set<T>) -> Set<U> {
//  return Set.bind(λ) >>> Set.init
//}

/// Maps `.some` given value to the given closure.
@_transparent
public func fmap<T, U>(_ λ: @escaping (T) -> U) -> (Set<T>) -> [U] {
  return Set.fmap(λ)
}

/// Maps `.some` given value to the given closure.
@_transparent
public func compactMap<T, U>(_ λ: @escaping (T) -> U?) -> (Set<T>) -> [U] {
  return Set.compactMap(λ)
}

/// Applies `.some` given closure to `.some` given value.
@_transparent
public func apply<T, U>(_ λs: [(T) -> U]) -> (Set<T>) -> [U] {
  return Set.apply(λs)
}

/// Maps `.some` given value to the given closure and unwraps its results.
@_transparent
public func bind<T, U>(_ λ: @escaping (T) -> [U]) -> (Set<T>) -> [U] {
  return Set.bind(λ)
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
public func filter<T>(
  _ isIncluded: @escaping (T) -> Bool
) -> (Set<T>) -> Set<T> {
  return Set.filter(isIncluded) >>> Set.init
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
public func reduce<T, Result>(
  _ initialResult: Result,
  _ nextPartialResult: @escaping (Result, T) throws -> Result
) rethrows -> (Set<T>) throws -> Result {
  return { try $0.reduce(initialResult, nextPartialResult) }
}

/// Returns the result of combining the elements of the sequence using the
/// given closure.
///
/// Use the `reduce(into:_:)` method to produce a single value from the
/// elements of an entire sequence. For example, you can use this method on an
/// array of integers to filter adjacent equal entries or count frequencies.
///
/// This method is preferred over `reduce(_:_:)` for efficiency when the
/// result is a copy-on-write type, for example an Set or a Dictionary.
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
public func reduce<T, Result>(
  into initialResult: __owned Result,
  _ updateAccumulatingResult: @escaping (inout Result, T) -> ()
) -> (Set<T>) -> Result {
  return { $0.reduce(into: initialResult, updateAccumulatingResult) }
}
