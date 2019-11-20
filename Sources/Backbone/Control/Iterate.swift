import Swift

/// The type of values that iterate infinitely over a sequence.
///
/// An infinite iterator is guaranteed to always supply a value of a sequence.
/// How this type of iteration is achieved is an implementation detail.
public protocol InfiniteIterator {

  /// The type of element traversed by the iterator.
  associatedtype Element

  /// Advances to the next element and returns it, where the next element may
  /// be the successor to the current element or the first element in the
  /// sequence if the current one is the last element in the sequence.
  ///
  /// Repeatedly calling this method always returns an element of the
  /// underlying sequence.
  ///
  /// - Precondition: You must **not** call this method if any other copy of
  ///   this iterator has been advanced with a call to its `next()` method.
  ///
  /// - Returns: An element in the underlying sequence.
  mutating func next() -> Self.Element
}

/// An iterator that ties a finite sequence into a circular one, or
/// equivalently, the infinite repetition of the original sequence.
///
/// Represents the identity on infinite sequences.
//@frozen
public struct CyclingIterator<BaseFiniteIterator: IteratorProtocol>: InfiniteIterator {
  public typealias Element = BaseFiniteIterator.Element

  @usableFromInline
  internal var makeFiniteIterator: () -> BaseFiniteIterator

  @usableFromInline
  internal lazy var finiteIterator = makeFiniteIterator()

  /// Creates an instance over the `makeIterator` function of a sequence.
  ///
  /// - Parameter makeIterator: The `makeIterator` of the sequence to cycle
  ///   over to eternity and beyond.
  @inlinable
  @inline(__always)
  public init(_ makeIterator: @escaping () -> BaseFiniteIterator) {
    makeFiniteIterator = makeIterator
  }

  @inlinable
  public mutating func next() -> CyclingIterator.Element {
    return finiteIterator.next().otherwise {
      finiteIterator = makeFiniteIterator()
      return finiteIterator.next()
        !! "Cannot cycle over an empty sequence."
    }
  }
}

extension Sequence {

  /// Returns an infinite iterator that will cycle  over the elements of this
  /// sequence.
  public func makeCyclingIterator() -> CyclingIterator<Self.Iterator> {
    return .init(self.makeIterator)
  }
}

/// Returns an infinite iterator that will cycle  over the elements of this
/// sequence.
public func makeCyclingIterator<S: Sequence>(
  _ xs: S
) -> CyclingIterator<S.Iterator> {
  return S.makeCyclingIterator(xs)()
}
