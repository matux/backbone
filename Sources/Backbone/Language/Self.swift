import Swift

public protocol SelfAware {
  associatedtype `Self`: SelfAware = Self
}

extension Range: SelfAware { }
extension ClosedRange: SelfAware { }
extension PartialRangeFrom: SelfAware { }
extension PartialRangeUpTo: SelfAware { }
extension PartialRangeThrough: SelfAware { }

extension Array: SelfAware { }
extension Slice: SelfAware { }
extension ArraySlice: SelfAware { }
extension ContiguousArray: SelfAware { }

extension String: SelfAware { }
extension Substring: SelfAware { }
extension Character: SelfAware { }

extension Dictionary: SelfAware { }
extension KeyValuePairs: SelfAware { }

extension Either: SelfAware { }
extension Optional: SelfAware { }
extension Result: SelfAware { }
extension These: SelfAware { }
