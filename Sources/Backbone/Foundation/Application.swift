#if os(iOS)
import UIKit

public typealias Application = UIApplication

extension UIApplication {
  public typealias LaunchOptions = [LaunchOptionsKey: Any]
  public typealias OpenURLOptions = [OpenURLOptionsKey: Any]

  @inlinable
  public static var rootViewController: UIViewController? {
      return shared.keyWindow?.rootViewController
  }

  @inlinable
  public static func canOpen(_ url: URL) -> Bool {
      return shared.canOpenURL(url)
  }

  @inlinable
  public static func open(_ url: URL) {
      shared.open(url)
  }

  @inlinable
  public static func suspend() {
    UIControl().sendAction(
      #selector(NSXPCConnection.suspend),
      to: shared,
      for: .none)
  }

  @inlinable
  public static func beginIgnoringInteractionEvents() {
    shared.beginIgnoringInteractionEvents()
  }

  @inlinable
  public static func endIgnoringInteractionEvents() {
    shared.endIgnoringInteractionEvents()
  }
}

#endif
