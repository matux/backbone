import Swift

prefix operator ++
prefix operator --
postfix operator ++
postfix operator --

postfix operator %

extension BinaryInteger {

  /// Computes an integer from the given boolean following classical logic
  /// semantics where `true` is denoted by 1 and false by 0.
  ///
  /// - Parameter booleanValue: The boolean to base the new integer off.
  @_transparent
  public init(_ booleanValue: Bool) {
    self = booleanValue ? .unit : .zero
  }

  /// Creates a new integer by rounding the given floating point value to an
  /// integral value using the specified rounding rule.
  ///
  /// - Parameters:
  ///     - value: The floating point value to round.
  ///     - rule: The rounding rule to use.
  /// - SeeAlso: `BinaryFloatingPoint.rounded(_:)`
  @_transparent
  public init<Floating: BinaryFloatingPoint>(
    _ value: Floating,
    rounded rule: BinaryFloatingPoint.RoundingRule
  ) {
    self.init(value.rounded(rule))
  }
}

extension BinaryInteger {

  @_transparent
  public static postfix func % (_ floating: Self) -> Double {
    return .init(floating) / 100.0
  }
}

extension BinaryInteger {

  @_transparent
  @discardableResult
  public static prefix func -- (_ x: inout Self) -> Self {
    x -= .unit
    return x
  }

  @_transparent
  @discardableResult
  public static prefix func ++ (_ x: inout Self) -> Self {
    x += .unit
    return x
  }

  @_transparent
  @discardableResult
  public static postfix func -- (_ x: inout Self) -> Self {
    return const(x)(--x)
  }

  @_transparent
  @discardableResult
  public static postfix func ++ (_ x: inout Self) -> Self {
    return const(x)(++x)
  }

  /// Returns an array containing the results of mapping the given closure
  /// over an enumerated stride from zero to this instance integer value.
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an integer
  ///   of the stride as its parameter and returns a value.
  /// - Returns: An array containing the values returned by `transform`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  /// @inlinable
  public func fmap<U>(_ transform: (Self) -> U) -> [U] {
    return stride(from: 0, to: self, by: 1).fmap(transform)
  }

  /// Returns an array containing the results of mapping the given closure
  /// over an enumerated stride from zero to this instance integer value.
  ///
  /// This partial variant accepts throwing closures.
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an integer
  ///   of the stride as its parameter and returns a value.
  /// - Returns: An array containing the values returned by `transform`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func map<U>(_ transform: (Self) throws -> U) rethrows -> [U] {
    return try stride(from: 0, to: self, by: 1).map(transform)
  }

  /// Returns a given element lazily repeated an amount equal to this
  /// BinaryInteger instance value.
  ///
  /// This is a synonym of the `replicate` free function.
  ///
  ///     10.of(0.0 / 0).each { print($0, terminator: "") }
  ///     print(" batman!")
  ///     // prints "nannannannannannannannannannan batman!"
  ///
  /// - Requires: `times` must be >= 0.
  /// - Parameters:
  ///   - element: The element to repeat.
  /// - Returns: A collection that contains as many repeated elements as this
  ///   integer instance value.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  @_specialize(exported: true, kind: partial, where Self == Int)
  public func repeats<Element>(
    of element: Element
  ) -> Repeated<Element>? {
    return element * self
  }

  /// Returns a given element lazily repeated an amount equal to this
  /// BinaryInteger instance value.
  ///
  /// This is a synonym of the `replicate` free function.
  ///
  ///     "\(0.0 / 0)" * 10
  ///       => forEach { print($0, terminator: "") }
  ///       => { print(" batman!") }
  ///     // prints "nannannannannannannannannannan batman!"
  ///
  /// - Requires: `times` must be >= 0.
  /// - Parameters:
  ///   - element: The element to repeat.
  ///   - times: The amount of repetitions of elements.
  /// - Returns: A collection that contains the many repeations of `element`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @_transparent
  @_specialize(exported: true, kind: partial, where Self == Int)
  public static func * <Element>(
    element: Element,
    times: Self
  ) -> Repeated<Element>? {
    switch times {
    case 0...:
      return repeatElement(element, count: .init(times))
    case _:
      return .none
    }
  }

  /// Returns an array with the repeated applications of the given nullary
  /// function `generate`.
  ///
  /// This is a variant of the `replicate` free function where the element is
  /// a function to be applied repeatedly in order to generate the elements
  /// that the resulting array will contain.
  ///
  ///     10.iterations(of: { Int.random(in: 0..<5) })
  ///          .each { print($0, terminator: "") }
  ///     // prints 10 random numbers
  ///
  /// - Requires: `times` must be >= 0.
  /// - Note: The generated collection is **not** lazy.
  /// - Parameter generate: Nullary function that will generate an element on
  ///   each consecutive application of it.
  /// - Returns: A collection with the elements generated by `generate`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  @_specialize(exported: true, kind: partial, where Self == Int)
  public func iterations<Element>(
    of generate: () -> Element
  ) -> [Element]? {
    return generate * self
  }

  /// Returns an array with the repeated applications of the given nullary
  /// function `generate`.
  ///
  /// This is a variant of the `replicate` free function where the element is
  /// a function to be applied repeatedly in order to generate the elements
  /// that the resulting array will contain.
  ///
  ///     Int.random * 10 => each { print($0, terminator: "") }
  ///     // prints 10 random numbers
  ///
  /// - Requires: `times` must be >= 0.
  /// - Note: The generated collection is **not** lazy.
  /// - Parameters:
  ///   - generate: Nullary function that will generate an element on each
  ///     consecutive application of it.
  ///   - times: The amount of elements to generate.
  /// - Returns: A collection with the elements generated by `generate`.
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @_transparent
  @_specialize(exported: true, kind: partial, where Self == Int)
  public static func * <Element>(
    generate: () -> Element,
    times: Self
  ) -> [Element]? {
    precondition(times >= 0, "Can't generate an element negative times.")
    switch times {
    case 0...:
      return times.fmap { _ in generate() }
    case _:
      return .none
    }
  }
}

extension FixedWidthInteger {

  /// Offsets this value by the specified stride.
  ///
  /// Use the `advance(by:)` method in generic code to offset a value by a
  /// specified distance. If you're working directly with numeric values, use
  /// the addition operator (`+=`) instead of this method.
  ///
  ///     func addOne<T: Strideable>(to x: T) -> T
  ///         where T.Stride : ExpressibleByIntegerLiteral
  ///     {
  ///         return x.advanced(by: 1)
  ///     }
  ///
  ///     let x = addOne(to: 5)
  ///     // x == 6
  ///     let y = addOne(to: 3.5)
  ///     // y = 4.5
  ///
  /// If this type's `Stride` type conforms to `BinaryInteger`, then for a
  /// value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
  /// `x.distance(to: y) == n`. Using this method with types that have a
  /// noninteger `Stride` may result in an approximation.
  ///
  /// - Parameter n: The distance to advance this value.
  /// - Returns: A value that is offset from this value by `n`.
  ///
  /// - Complexity: O(1)
  @inlinable
  public mutating func advance(by n: Stride) -> () {
    self = advanced(by: n)
  }

  /// Returns an array with the repeated applications of `transform` passing
  /// the iteration count as an argument starting from zero.
  ///
  /// Use the `enumerating` function when you need to the index of the element
  /// to generate an array of `n` elements where `n` is an amount equal to the
  /// number represented by this instance.
  ///
  ///     10.enumerating(id)
  ///          .forEach { print($0, separator: " ", terminator: "") }
  ///     // prints "0 1 2 3 4 5 6 7 8 9"
  ///
  /// - Note: The generated collection is not lazy.
  /// - Parameter generate: Nullary function that will generate an element on
  ///   each consecutive application of it.
  /// - Returns: return value description
  @inlinable
  @_specialize(exported: true, kind: partial, where Self == Int)
  public func enumerate<Element>(
    with transform: (Self) throws -> Element
  ) rethrows -> [Element] {
    precondition(self >= 0, "Can't loop negatively.")
    return try (.zero...self).map(transform)
  }

  /// Calls the given closure an amount equal to the number represented by
  /// this instance passing each number consecutively as an argument starting
  /// from zero.
  @inlinable
  @_specialize(exported: true, kind: partial, where Self == Int)
  public func forEach(_ effect: (Self) throws -> ()) rethrows -> () {
    precondition(self >= 0, "Can't loop negatively.")
    try (.zero...self).forEach(effect)
  }

  /// Calls the given closure an amount equal to the number represented by
  /// this instance passing each number consecutively as an argument starting
  /// from zero; and returning this integer instance as a result.
  @inlinable
  @_specialize(exported: true, kind: partial, where Self == Int)
  public func tapEach(_ effect: (Self) throws -> ()) rethrows -> Self {
    precondition(self >= 0, "Can't loop negatively.")
    return const(self)(try forEach(effect))
  }
}
