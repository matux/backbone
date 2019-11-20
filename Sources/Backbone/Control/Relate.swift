import Swift

infix operator ≤ : ComparisonPrecedence
infix operator ≥ : ComparisonPrecedence

// MARK: - Equality

@inlinable
public func equals<T: Equatable>(_ x: T) -> (_ y: T) -> Bool {
  return curry(==)(x)
}

@inlinable
public func equals<A: Equatable, B: Equatable>(
    _ x: (A, B))
-> (_ y: (A, B))
-> Bool {
  return curry(==)(x)
}

@inlinable
public func equals<A: Equatable, B: RawRepresentable>(
    _ a: A)
-> (_ b: B)
-> Bool where A == B.RawValue {
  return \.rawValue == a
}

@inlinable
public func equals<A: RawRepresentable, B: Equatable>(
    _ a: A)
-> (_ b: B)
-> Bool where A.RawValue == B {
  return curry(==)(a.rawValue)
}

/// Test Equatables for equality.
///
/// - SeeAlso:
///   https://en.wikipedia.org/wiki/Equality_(mathematics)
@_transparent
public func areEqual<T: Equatable>(_ x: T, _ y: T) -> Bool {
  return x == y
}

/// Test Equatables for distinctness (`!=`).
///
/// - SeeAlso:
///   https://en.wikipedia.org/wiki/Distinct_(mathematics)
@_transparent
public func differ<T: Equatable>(_ x: T, _ y: T) -> Bool {
  return x != y
}

extension Nil: Equatable {

  /// Enables equality between nil values with no type context or
  /// `Equatable` conformance requirements.
  ///
  /// - Parameters:
  ///   - lhs: A `nil` literal, `Optional.none` or instance of `Nil`.
  ///   - rhs: A `nil` literal, `Optional.none` or instance of `Nil`.
  @_transparent // primitive
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return true
  }
}

/// Tests the value referenced by a given key path and a given value for
/// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
///
/// - Parameters:
///   - path: A key path pointing to a value to compare.
///   - box: The value to compare boxed in a `RawRepresentable` value.
@_transparent
public func == <Root, BoxedValue: RawRepresentable>(
  path: KeyPath<Root, BoxedValue>,
  box: BoxedValue
) -> (Root) -> Bool where BoxedValue.RawValue: Equatable {
  return { $0[keyPath: path] == box }
}

extension KeyPath where Value == Bool {

  @_transparent
  public static prefix func ! (path: KeyPath) -> (Root) -> Bool {
    { root in !root[keyPath: path] }
  }
}

extension KeyPath where Value: Equatable {

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - value: A value to compare.
  @_transparent
  public static func == (path: KeyPath, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: path] == value }
  }


  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare.
  ///   - path: A key path pointing to a value to compare.
  @_transparent
  public static func == (value: Value, path: KeyPath) -> (Root) -> Bool {
    return path == value
  }

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - value: A value to compare.
  @_transparent
  public static func != (path: KeyPath, value: Value) -> (Root) -> Bool {
    return not • (path == value)
  }

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare.
  ///   - path: A key path pointing to a value to compare.
  @_transparent
  public static func != (value: Value, path: KeyPath) -> (Root) -> Bool {
    return path != value
  }
}

extension KeyPath where Value: RawRepresentable, Value.RawValue: Equatable {
  public typealias BoxedValue = Value

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func == (box: BoxedValue, path: KeyPath) -> (Root) -> Bool {
    return path == box
  }

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func != (path: KeyPath, box: BoxedValue) -> (Root) -> Bool {
    return not • (path == box)
  }

  /// Tests the value referenced by a given key path and a given value for
  /// equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func != (box: BoxedValue, path: KeyPath) -> (Root) -> Bool {
    return path != box
  }
}

extension KeyPath where Value: Comparable {

  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than that of the second argument.
  ///
  /// This function is the only requirement of the `Comparable` protocol. The
  /// remainder of the relational operator functions are implemented by the
  /// standard library for any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  @_transparent
  public static func < (path: KeyPath, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: path] < value }
  }

  /// Returns a Boolean value indicating whether the value of the first argument
  /// is less than or equal to that of the second argument.
  ///
  /// This is the default implementation of the less-than-or-equal-to
  /// operator (`<=`) for any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  @_transparent
  public static func <= (path: KeyPath, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: path] <= value }
  }

  /// Returns a Boolean value indicating whether the value of the first argument
  /// is greater than that of the second argument.
  ///
  /// This is the default implementation of the greater-than operator (`>`) for
  /// any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  @_transparent
  public static func > (path: KeyPath, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: path] > value }
  }

  /// Returns a Boolean value indicating whether the value of the first argument
  /// is greater than or equal to that of the second argument.
  ///
  /// This is the default implementation of the greater-than-or-equal-to operator
  /// (`>=`) for any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  /// - Returns: `true` if `lhs` is greater than or equal to `rhs`; otherwise,
  ///   `false`.
  @_transparent
  public static func >= (path: KeyPath, value: Value) -> (Root) -> Bool {
    return { $0[keyPath: path] >= value }
  }
}

extension RawRepresentable where RawValue: Equatable {

  /// Tests a value boxed in the given raw representable value and the given
  /// value for equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func == (value: RawValue, box: Self) -> Bool {
    return value == box.rawValue
  }

  /// Tests a value boxed in the given raw representable value and the given
  /// value for equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func == (box: Self, value: RawValue) -> Bool {
    return value == box
  }

  /// Tests a value boxed in the given raw representable value and the given
  /// value for equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func != (value: RawValue, box: Self) -> Bool {
    return !(value == box)
  }

  /// Tests a value boxed in the given raw representable value and the given
  /// value for equality, where `∀𝑎𝑏. 𝑎 = 𝑏 ⟺ 𝑎 ≠ 𝑏` holds.
  ///
  /// - Parameters:
  ///   - value: A value to compare
  ///   - box: The value to compare boxed in a `RawRepresentable` value.
  @_transparent
  public static func != (box: Self, value: RawValue) -> Bool {
    return value != box
  }
}

// MARK: - Identity

infix operator ≡≡ : ComparisonPrecedence
infix operator !≡ : ComparisonPrecedence

/// Returns a Boolean value indicating whether two references point to the same
/// object instance.
///
/// This operator tests whether two instances have the same identity, not the
/// same value. For value equality, see the equal-to operator (`==`) and the
/// `Equatable` protocol.
///
/// The following example defines an `IntegerRef` type, an integer type with
/// reference semantics.
///
///     class IntegerRef: Equatable {
///         let value: Int
///         init(_ value: Int) {
///             self.value = value
///         }
///     }
///
///     func ==(lhs: IntegerRef, rhs: IntegerRef) -> Bool {
///         return lhs.value == rhs.value
///     }
///
/// Because `IntegerRef` is a class, its instances can be compared using the
/// identical-to operator (`===`). In addition, because `IntegerRef` conforms
/// to the `Equatable` protocol, instances can also be compared using the
/// equal-to operator (`==`).
///
///     let a = IntegerRef(10)
///     let b = a
///     print(a == b)
///     // Prints "true"
///     print(a ≡≡ b)
///     // Prints "true"
///
/// The identical-to operator (`≡≡`) returns `false` when comparing two
/// references to different object instances, even if the two instances have
/// the same value.
///
///     let c = IntegerRef(10)
///     print(a == c)
///     // Prints "true"
///     print(a ≡≡ c)
///     // Prints "false"
///
/// - Parameters:
///   - lhs: A reference to compare.
///   - rhs: Another reference to compare.
@inlinable // trivial-implementation
public func ≡≡ (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return ObjectIdentifier(l) == ObjectIdentifier(r)
  case (.none, .none):
    return true
  default:
    return false
  }
}

/// Returns a Boolean value indicating whether two references point to
/// different object instances.
///
/// This operator tests whether two instances have different identities, not
/// different values. For value inequality, see the not-equal-to operator
/// (`!=`) and the `Equatable` protocol.
///
/// - Parameters:
///   - lhs: A reference to compare.
///   - rhs: Another reference to compare.
@inlinable // trivial-implementation
public func !≡ (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
  return not(lhs ≡≡ rhs)
}

/// Test whether two references refer to the same instance.
///
/// Functional variant of the `identical to` [identity operator][1].
///
/// [1]: https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html#ID90
@inlinable
public func references(_ x: AnyObject) -> (_ y: AnyObject) -> Bool {
  return curry(≡≡)(x)
}

// MARK: - Comparable

extension Comparable {

  /// Returns a `Boolean` value indicating whether the value of the _first_
  /// argument is **greater than or equal** to that of the _second_ argument.
  ///
  /// - Parameters
  ///   - lhs: A value to compare
  ///   - rhs: Another value to compare.
  /// - Returns: Whether `lhs` is greater than or equal than `rhs`.
  @_transparent
  public static func ≥ (lhs: Self, rhs: Self) -> Bool {
    return lhs >= rhs
  }

  /// Returns a `Boolean` value indicating whether the value of the _first_
  /// argument is **less than or equal** to that of the _second_ argument.
  ///
  /// - Parameters
  ///   - lhs: A value to compare
  ///   - rhs: Another value to compare.
  /// - Returns: Whether `lhs` is less than or equal than `rhs`.
  @_transparent
  public static func ≤ (lhs: Self, rhs: Self) -> Bool {
    return lhs <= rhs
  }
}

/// Returns a `Boolean` value indicating whether the value of the _first_
/// argument is **less than** to the _second_ argument.
///
/// - Parameters
///   - y: The value to compare `x` to.
///   - x: A value to compare.
/// - Returns: Whether `x` is less than `y`.
public func lessThan<T: Comparable>(_ y: T) -> (T) -> Bool {
  return { x in x < y }
}

/// Returns a `Boolean` value indicating whether the value of the _first_
/// argument is **greater than** to the _second_ argument.
///
/// - Parameters
///   - y: The value to compare `x` to.
///   - x: A value to compare.
/// - Returns: Whether `x` is greater than `y`.
public func greaterThan<T: Comparable>(_ y: T) -> (T) -> Bool {
  return { x in x > y }
}

// MARK: - Relation

/// Description
///
/// - Parameters:
///   - attribute: attribute description
///   - compare: A predicate that returns `true` if its first argument should be
///     ordered before its second argument; otherwise, `false`.
/// - Returns: A binary function to apply as a sorting predicate.
@inlinable
public func their<A, B: Comparable>(
  _ attribute: @escaping (A) -> B,
  where compare: @escaping (B, B) -> Bool
) -> (A, A) -> Bool {
  return compose(compare, on: attribute)
}

/// Description
///
/// - Parameters:
///   - keyPath: keyPath description
///   - compare: A predicate that returns `true` if its first argument should be
///     ordered before its second argument; otherwise, `false`.
/// - Returns: A binary function to apply as a sorting predicate.
@inlinable
public func their<Root, Value: Comparable>(
  _ keyPath: KeyPath<Root, Value>,
  _ predicate: @escaping (Value, Value) -> Bool
) -> (Root, Root) -> Bool {
  return their(^keyPath, where: predicate)
}

/// Description
///
/// - Parameter attribute: attribute description
/// - Returns: A binary function to apply as a sorting predicate.
@inlinable
public func their<A, B: Comparable>(
  _ attribute: @escaping (A) -> B
) -> (A, A) -> Bool {
  return their(attribute, where: <)
}

/// Description
///
/// - Parameter keyPath: keyPath description
/// - Returns: A binary function to apply as a sorting predicate.
@inlinable
public func their<Root, Value: Comparable>(
  _ keyPath: KeyPath<Root, Value>
) -> (Root, Root) -> Bool {
  return their(^keyPath)
}

// MARK: - Membership

extension KeyPath {

  /// Returns whether the value referenced by a given key path is an element of
  /// a given collection.
  ///
  /// The [relation][1] "is an [element of][2]", also called [set membership][3],
  /// is denoted by the symbol (`∈`):
  ///
  ///     𝒙 ∈ 𝑨
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [2]: https://reference.wolfram.com/language/ref/Element.html
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func ∈ <S: Membership>(
    path: KeyPath,
    values: S
  ) -> (Root) -> Bool where S.Element == Value {
    return { root in values.contains(root[keyPath: path]) }
  }

  /// Returns whether the given collection contains the value referenced by the
  /// given key path.
  ///
  /// The [relation][1] "[contains][2]" is denoted by the symbol (`∋`):
  ///
  ///     𝑨 ∋ x
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func ∋ <S: Membership>(
    values: S,
    path: KeyPath
  ) -> (Root) -> Bool where S.Element == Value {
    return { root in values.contains(root[keyPath: path]) }
  }

  /// Returns whether the value referenced by a given key path is an element of
  /// a given collection.
  ///
  /// The [relation][1] "is **not** an [element of][2]", also called
  /// [set membership][3], is denoted by the symbol (`∉`):
  ///
  ///     𝒙 ∉ [𝑨]
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [2]: https://reference.wolfram.com/language/ref/Element.html
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func !∈ <S: Membership>(
    path: KeyPath,
    values: S
  ) -> (Root) -> Bool where S.Element == Value {
    return { root in !values.contains(root[keyPath: path]) }
  }

  /// Returns whether the given collection lacks the value referenced by the
  /// given key path.
  ///
  /// The [relation][1] "[does not contain][2]" is denoted by the symbol (`∌`):
  ///
  ///     [𝑨] ∌ x
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func !∋ <S: Membership>(
    values: S,
    path: KeyPath
  ) -> (Root) -> Bool where S.Element == Value {
    return { root in !values.contains(root[keyPath: path]) }
  }
}


extension KeyPath where Value: Membership {

  /// Returns whether the collection referenced by the given key path contains
  /// the given value.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func ∈ (
    x: Value.Element,
    xs: KeyPath
  ) -> (Root) -> Bool {
    return { x ∈ $0[keyPath: xs] }
  }

  /// Returns whether the collection referenced by the given key path lacks
  /// the given value.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func !∈ (
    x: Value.Element,
    xs: KeyPath
  ) -> (Root) -> Bool {
    return { x !∈ $0[keyPath: xs] }
  }

  /// Returns whether the collection referenced by the given key path contains
  /// the given value.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func ∋ (
    xs: KeyPath,
    x: Value.Element
  ) -> (Root) -> Bool  {
    return { $0[keyPath: xs] ∋ x }
  }

  /// Returns whether the collection referenced by the given key path lacks
  /// the given value.
  ///
  /// - Parameters:
  ///   - path: A key path pointing to a value to compare.
  ///   - values: A value to compare.
  ///
  /// [1]: https://en.wikipedia.org/wiki/Heterogeneous_relation
  /// [3]: https://en.wikipedia.org/wiki/Element_(mathematics)
  @_transparent
  public static func !∋ (
    xs: KeyPath,
    x: Value.Element
  ) -> (Root) -> Bool  {
    return { $0[keyPath: xs] !∋ x }
  }
}
