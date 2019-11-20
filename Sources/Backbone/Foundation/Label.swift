#if os(iOS)
import UIKit

extension UILabel {

  /// The current text that is displayed by the label.
  ///
  /// A non-optional variant of the `text` property.
  ///
  /// - Note: Assigning a new value to this property also replaces the value
  ///   of the `attributedText` property with the same string, although without
  ///   any inherent style attributes.
  ///
  ///   Instead the label styles the new string using `shadowColor`,
  ///   `textAlignment`, and other style-related properties of the class.
  public var string: String {
    get { text ?? .empty }
    set { text = newValue }
  }
}

#endif
