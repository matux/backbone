#if canImport(UIKit)
import UIKit

extension UIDeviceOrientation {

  /// The device is held parallel to the ground
  public static let flat = { UIDevice.current.orientation ∈ [.faceUp, .faceDown] }
}

#endif // canImport(UIKit)
