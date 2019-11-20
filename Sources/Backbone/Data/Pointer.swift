import Swift

public struct RelativeDirectPointer<Pointee, Offset: BinaryInteger> {
  public var relative: Offset

  public mutating func get() -> Pointee {
    return Int(relative) => { rawOffset in
      withUnsafePointer(to: &self, { fieldPointer in
        UnsafeRawPointer(fieldPointer)
          .advanced(by: rawOffset)
          .assumingMemoryBound(to: Pointee.self)
      }).pointee
    }
  }
}
