#if os(iOS)
import Foundation
import UIKit

extension UIControl {

  private final class Observer {
    static var key = 0 as UInt8
    let action: (UIControl) -> ()
    let events: Event

    init(event: Event, action: @escaping (UIControl) -> ()) {
      self.events = event
      self.action = action
    }

    @objc
    fileprivate func perform(_ control: UIControl) {
      action(control)
    }
  }

  private var action: Selector { return #selector(Observer.perform) }

  private var observers: [UInt: [Observer]] {
    get { return T.cast(objc_getAssociatedObject(self, &Observer.key)) ?? [:] }
    set {
      objc_setAssociatedObject(
        self, &Observer.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// Binds an action to one or more `Events`.
  ///
  /// Sets a given closure as the action to be triggered for a particular event
  /// and stores it in an internal dispatch table.
  ///
  ///     let button = UIButton.buttonWithType(.System) as! UIButton
  ///     button.observe(.touchUpInside) { print("\($0) tapped!") }
  ///
  /// - Parameters:
  ///   - events: A bitmask specifying the control events for which
  ///     the action message is sent.
  ///   - closure: A closure representing an action message, with an argument
  ///     for the sender.
  @discardableResult
  public func observe(
    _ events: Event = .touchUpInside,
    with closure: @escaping (_ sender: UIControl) -> ()
  ) -> Self {
    return const(self)(
      Observer(event: events, action: closure)
        =>> add(events: *events, action: action)
        => (observers[*events] ?? .empty).appending
        => { observers[*events] = $0 })
  }

  @discardableResult
  public func removeObservers(
    for events: Event = .empty
  ) -> Self {
    for (event, wraps) in observers where event & *events != *events {
      observers[event] = .none
      wraps.each(remove(events: event, action: action))
    }

    return self
  }

  private func add(events: Event.RawValue, action: Selector) -> (Any?) -> () {
    return flip(curry(addTarget))(Event(rawValue: events))(action)
  }

  private func remove(events: Event.RawValue, action: Selector?) -> (Any?) -> () {
    return flip(curry(removeTarget))(Event(rawValue: events))(action)
  }
}

extension UIControl.Event: Monoid { }

extension UIControl.Event {

  public static prefix func * (_ event: UIControl.Event) -> UInt {
    return event.rawValue
  }
}

#endif
