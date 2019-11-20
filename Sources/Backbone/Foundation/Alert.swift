#if os(iOS)
import UIKit

public typealias Alert = UIAlertController

extension Alert.Action: SelfAware {

  public static let ok = Self(title: "OK", style: .default)
  public static let yes = Self(title: "Yes", style: .default)
  public static let no = Self(title: "No", style: .default)
  public static let cancel = Self(title: "Cancel", style: .cancel)

  public static func ok(_ handler: @escaping () -> ()) -> Alert.Action {
    return .init("OK", handler: discard >>> handler)
  }

  convenience init(
    _ title: String,
    style: Style = .default,
    handler: @escaping (Self) -> ()
  ) {
    self.init(title: title, style: style, handler: handler)
  }
}

extension Alert: SelfAware {
  public typealias Action = UIAlertAction

  private static var topViewController: UIViewController? {
    guard var topController = UIApplication.shared.keyWindow?.rootViewController else { return nil }

    while let presentedViewController = topController.presentedViewController {
      topController = presentedViewController
    }

    return topController
    //return UIApplication.shared.keyWindow?.rootViewController
  }

  public static func present(
    _ error: Swift.Error,
    handler: @escaping () -> () = noop
  ) {
    present("Error", message: error.localizedDescription, handler: handler)
  }

  public static func present(
    _ title: String,
    message: String = .empty,
    action: String = "OK",
    style: Action.Style = .default,
    handler: @escaping () -> () = noop
  ) {
    guard Thread.isMainThread else {
      return async {
        present(
          title,
          message: message,
          action: action,
          style: .default,
          handler: handler)
      }
    }

    topViewController?.present(
      Self(title, message: message, actions: [
        Action(action, style: style, handler: discard >>> handler)]))
  }

  public convenience init(
    _ title: String,
    message: String = .empty,
    style: Style = .alert,
    actions: [Action]
  ) {
    self.init(title: title, message: message, preferredStyle: style)

    actions.forEach(addAction)
  }

  public convenience init(
    _ title: String,
    message: String = .empty,
    style: Style = .alert,
    handler: @escaping () -> () = noop
  ) {
    self.init(title, message: message, style: style, actions: [.ok(handler)])
  }

  @discardableResult
  public func present() -> Self {
    return const(self)(
      Alert.topViewController.map(UIViewController.present(self)))
  }
}

#endif
