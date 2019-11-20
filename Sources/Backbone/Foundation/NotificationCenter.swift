#if os(iOS)
import Foundation
import UIKit

extension Notification.Name {
  public typealias App = UIApplication
  public static let finishedLaunch = App.didFinishLaunchingNotification
  public static let enteringForeground = App.willEnterForegroundNotification
  public static let becameActive = App.didBecomeActiveNotification
  public static let resigningActive = App.willResignActiveNotification
  public static let enteredBackground = App.didEnterBackgroundNotification
  public static let refreshedBackgroundStatus = App.backgroundRefreshStatusDidChangeNotification
  public static let receivedMemoryWarning = App.didReceiveMemoryWarningNotification
  public static let significantTimeChange = App.significantTimeChangeNotification
  public static let orientingStatusBar = App.willChangeStatusBarOrientationNotification
  public static let orientedStatusBar = App.didChangeStatusBarOrientationNotification
  public static let framingStatusBar = App.willChangeStatusBarFrameNotification
  public static let framedStatusBar = App.didChangeStatusBarFrameNotification
  public static let protectedDataBecameAvailable = App.protectedDataDidBecomeAvailableNotification
  public static let protectedDataBecomingUnavailable = App.protectedDataWillBecomeUnavailableNotification

  public typealias Responder = UIResponder
  public static let showingKeyboard = Responder.keyboardWillShowNotification
  public static let shownKeyboard = Responder.keyboardDidShowNotification
  public static let hidingKeyboard = Responder.keyboardWillHideNotification
  public static let hidKeyboard = Responder.keyboardDidHideNotification
}

extension NotificationCenter {

  /// Adds an entry to the notification center's dispatch table that
  /// includes a notification queue and a block to add to the **main** queue,
  /// to be called **asynchronously**, and an optional notification name.
  ///
  /// If a given notification triggers more than one observer block, the
  /// blocks may all be executed concurrently with respect to one another
  /// (but on their given queue or on the current thread).
  ///
  /// To unregister observations, you pass the object returned by this method
  /// to `removeObserver(_:)`. You must invoke `removeObserver(_:)` or
  /// `removeObserver(_:name:object:)` before any object specified by
  /// `observe(_:with:`) is deallocated.
  ///
  /// - Important: If your app targets **iOS 9.0 and later** or **macOS 10.11
  ///   and later** , you **don't need to unregister** an observer in its
  ///   `dealloc` method.
  ///
  /// - Parameters:
  ///   - name: The name of the notification for which to register the
  ///     observer; that is, only notifications with this name are used to
  ///     add the block to the operation queue.
  ///     If you pass `nil`, the notification center doesn’t use a
  ///     notification’s name to decide whether to add the block to the
  ///     operation queue.
  ///   - closure: The block to be executed when the notification is received.
  ///     The block is copied by the notification center and (the copy) held
  ///     until the observer registration is removed.
  ///     The block takes one argument: `notification`.
  /// - Returns: An opaque object representing the observer.
  @discardableResult
  public static func observe(
    _ name: Notification.Name?,
    with closure: @escaping (Notification) -> ()
  ) -> NSObjectProtocol {
    `default`
      .addObserver(forName: name, object: .none, queue: .main, using: closure)
  }

  /// Removes all entries specifying a given observer from the notification
  /// center's dispatch table.
  ///
  /// You shouldn't use this method to remove all observers from a long-lived
  /// object, because your code may not be the only code adding observers that
  /// involve the object.
  ///
  /// - Important: If your app targets **iOS 9.0 and later** or **macOS 10.11
  ///   and later** , you **don't need to unregister** an observer in its
  ///   `dealloc` method.
  ///
  /// The following example illustrates how to unregister `observer` for all
  /// notifications for which it had previously registered. This is safe to do
  /// in the `dealloc` method, but should **not** otherwise be used (use
  /// `remove(observer:name:object:)` instead).
  ///
  ///     NotificationCenter.default.removeObserver(observer)
  public static func remove(
    observer: NSObjectProtocol
  ) -> () {
    `default`.removeObserver(observer)
  }

  /// Removes matching entries from the notification center's dispatch table.
  ///
  /// - Important: If your app targets **iOS 9.0 and later** or **macOS 10.11
  ///   and later**, you **don't need** to unregister an observer in its
  ///   `dealloc` method.
  ///
  /// - Parameters:
  ///   - observer: Observer to remove from the dispatch table. Specify an
  ///     observer to remove only entries for this observer.
  ///   - name: Name of the notification to remove from dispatch table. Specify
  ///     a notification name to remove only entries that specify this
  ///     notification name. When `nil`, the receiver does not use notification
  ///     names as criteria for removal.
  ///   - object: Sender to remove from the dispatch table. Specify a
  ///     notification sender to remove only entries that specify this sender.
  ///     When `nil`, the receiver does not use notification senders as
  ///     criteria for removal.
  public static func remove(
    observer: NSObjectProtocol,
    name: NSNotification.Name?,
    object: Any? = .none
  ) -> () {
    `default`
      .removeObserver(
        observer,
        name: name,
        object: object)
  }
}
#endif
