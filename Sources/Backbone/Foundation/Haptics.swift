#if canImport(UIKit) && os(iOS)
import UIKit

/// A namespace encapsulating haptics-related functionality to notify the user
/// of events of varied importance.
///
/// Haptics provide a tactile response that draw attention and reinforces both
/// actions and events. They _must_ match a visual change in the UI, or be in
/// response to a user action.
///
/// - Note: Many system UI elements (eg. pickers, switches, and sliders)
///   already provide haptic feedback.
/// - SeeAlso:
///   https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/feedback/
@available(iOS 10.0, *)
public enum Haptics {

  /// A subtle tap suitable to go along with UI interaction, to indicate a
  /// change in selection, or communicate movement through a series of
  /// discrete values.
  case tap

  /// A haptic suitable to simulate physical impacts such as collisions or
  /// UI controls snapping into into place.
  case hit

  /// Produces a sequence of rhythmic haptics of varied intensity suitable to
  /// draw attention to events that were not caused by the user directly.
  case notify(Intensity)

  /// A haptic with a custom intensity `0.0...1.0`.
  case custom(CGFloat)

  /// Indicates dynamics for a single haptics `notify` or `hit` event.
  ///
  /// Variations on the amount of taps, intensity and rhythm occur depending
  /// on context and at the discretion of the system.
  public enum Intensity: Int {
    /// Typically used for notifications that don't require any actions
    /// from the user.
    ///
    /// It'll generate two haptics of medium intensity for a notification
    /// and one a subtle tap for impacts.
    case subtle = 1

    /// Typically used for important notifications that require a user's
    /// attention but not any immediate action.
    ///
    /// Sequences three haptics of varied intensity for notifications and
    /// a medium intensity tap for impacts.
    case regular = 2

    /// Typically used for very important notifications that the user may
    /// need to act upon.
    ///
    /// Sequences four arrythmic strong haptics for notifications and a
    /// strong tap for impact.
    case prominent = 3

    var float: CGFloat {
      return [
        .subtle: 1.0 / 3.0 as CGFloat,
        .regular: 1.0 / 6.0 as CGFloat,
        .prominent: 1.0 / 1.0 as CGFloat
        ][self]!
    }
  }
}

extension Haptics {

  /// Immediately triggers haptics feedback without the need of a pre-prepared
  /// generator.
  ///
  /// Only recommended for notifications, other haptics may lag.
  public func emit() {
    switch self {
    case .tap:
      UISelectionFeedbackGenerator().selectionChanged()

    case .hit:
      UIImpactFeedbackGenerator().impactOccurred()

    case .notify(let intensity):
      UINotificationFeedbackGenerator().notificationOccurred(.init(intensity))

    #if swift(>=5.1)
    case .custom(let intensity):
      if #available(iOS 13.0, *) {
        UIImpactFeedbackGenerator().impactOccurred(intensity: intensity)
      }
    #else
    case .custom:
      UIImpactFeedbackGenerator().impactOccurred()
    #endif
    }
  }
}


extension Haptics {

  public struct Generator {

    private var tapGenerator = UISelectionFeedbackGenerator?.none
    private var hitGenerator = UIImpactFeedbackGenerator?.none
    private var notifyGenerator = UINotificationFeedbackGenerator?.none
    private var customGenerator = UIImpactFeedbackGenerator?.none

    public mutating func prepare(for haptics: Haptics) {
      switch haptics {
      case .tap where tapGenerator.isNil:
        tapGenerator = UISelectionFeedbackGenerator()
        fallthrough
      case .tap:
        tapGenerator?.prepare()

      case .hit where hitGenerator.isNil:
        hitGenerator = UIImpactFeedbackGenerator()
        fallthrough
      case .hit:
        hitGenerator?.prepare()

      case .notify where notifyGenerator.isNil:
        notifyGenerator = UINotificationFeedbackGenerator()
        fallthrough
      case .notify:
        notifyGenerator?.prepare()

      case .custom where customGenerator.isNil:
        customGenerator = UIImpactFeedbackGenerator()
        fallthrough
      case .custom:
        customGenerator?.prepare()
      }
    }

    /// Generates haptics.
    ///
    /// This function tells the haptic generator that an event or action has
    /// occurred. In response, the generator may play the appropriate haptics,
    /// based on the provided `Haptics.Intensity` value.
    ///
    /// - Remark: This function is thread safe.
    public func emit(_ haptics: Haptics) {
      switch haptics {
      case .tap:
        tapGenerator?.selectionChanged()

      case .hit:
        hitGenerator?.impactOccurred()

      case .notify(let intensity):
        notifyGenerator?.notificationOccurred(.init(intensity))

      #if swift(>=5.1)
      case .custom(let intensity):
        if #available(iOS 13.0, *) {
          customGenerator?.impactOccurred(intensity: intensity)
        }

        #else
      case .custom:
        customGenerator?.impactOccurred()
        #endif
      }
    }
  }
}
// MARK: - Haptics private parts

// The intention behind these abstraction is to detach haptics from the concrete
// notions of "success" and "error" as well as "impact"; these can obscure
// intent when using haptics in more interesting ways, eg. picking up or
// dropping 3D objects.

extension UINotificationFeedbackGenerator.FeedbackType {

  fileprivate init(_ dynamics: Haptics.Intensity) {
    self = [.subtle: .success,
            .regular: .warning,
            .prominent: .error][dynamics]!
  }
}

extension UIImpactFeedbackGenerator.FeedbackStyle {

  fileprivate init(_ dynamics: Haptics.Intensity) {
    self = [.subtle: .light,
            .regular: .medium,
            .prominent: .heavy][dynamics]!
  }
}

#endif // canImport(UIKit) && !os(watchOS)
