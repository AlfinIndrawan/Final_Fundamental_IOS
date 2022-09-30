// @IBDesignable is any variable that have ib inspectable in front of it appear inside of attribute inspector in interface builder
import UIKit

extension UIFont {
  static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
    let metrics = UIFontMetrics(forTextStyle: style)
    let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
    return metrics.scaledFont(for: font)
  }
}
