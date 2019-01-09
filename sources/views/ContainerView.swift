//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class ContainerView: UIView {
  
  public var isAnimating:Bool = false
  
  open override var frame: CGRect {
    didSet {
      self.layoutIfNeeded()
    }
  }
  
  override open func layoutSubviews() {
    if !self.isAnimating {
      self.subviews.forEach { $0.frame = self.bounds }
    }
  }
  
}

