#if os(iOS)
import UIKit

final class Placeholder: UIImageView {

  override func didMoveToSuperview() {
    removeFromSuperview()
  }
}
#endif
