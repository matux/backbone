import Swift

extension Array {

  @inlinable
  @inline(__always)
  public init(initialCapacity: Int) {
    self.init()
    reserveCapacity(initialCapacity)
  }

  // Captures sequences, eg.
  // Array([1,2,3].reversed()) = [ReversedCollection<Int>([1,2,3]]
//  @inlinable
//  @inline(__always)
//  public init(head: Element) {
//    self = [head]
//  }
}

// MARK: -

extension Array {

  private func describe(_ x: Any) -> String {
    switch x {
    case let x as HDictionary<AnyHashable>: return x.description
    case let x as Array: return x.description
    case let x as Set<AnyHashable>: return x.description
    case let x as CustomStringConvertible: return x.description
    case let x: return "\(x, trunc: 64)"
    }
  }

  public var description: String {
    return { "\(type(of: self)) = [\n\($0)\t\t\t]" }(reduce {
      $0 += "\t\t\t\t\(describe($1))\n"
    })
  }
}

extension Array: Comparable where Element: Comparable {

  @_transparent
  public static func < (lhs: Array, rhs: Array) -> Bool {
    return lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

// MARK: -

extension ContiguousArray {

  @inlinable
  @inline(__always)
  public init(initialCapacity: Int) {
    self.init()
    reserveCapacity(initialCapacity)
  }

  @inlinable
  @inline(__always)
  public init(head: Element) {
    self = [head]
  }
}

extension ContiguousArray: Comparable where Element: Comparable {

  @_transparent
  public static func < (lhs: ContiguousArray, rhs: ContiguousArray) -> Bool {
    return lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

// MARK: -

extension ArraySlice {

  @inlinable
  @inline(__always)
  public init(initialCapacity: Int) {
    self.init()
    reserveCapacity(initialCapacity)
  }

  @inlinable
  @inline(__always)
  public init(head: Element) {
    self = [head]
  }
}

extension ArraySlice: Comparable where Element: Comparable {

  @_transparent
  public static func < (lhs: ArraySlice, rhs: ArraySlice) -> Bool {
    return lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

