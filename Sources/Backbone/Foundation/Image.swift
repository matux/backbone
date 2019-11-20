#if os(iOS)
import UIKit

extension UIImage {

  /// This instance of UIImage with its image rendered as a template.
  var template: UIImage? { withRenderingMode(.alwaysTemplate) }
}

#endif
