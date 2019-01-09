//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidImageView: UIImageView {
  
  fileprivate var fromImageView: UIImageView?
  fileprivate var toImageView: UIImageView?
  fileprivate var overlayView: UIView = UIView(frame: .zero)
  private var nextImage:UIImage?
  
  @IBInspectable open var transitionProgress: CGFloat = 0.0
  @IBInspectable open var transitionDuration: CGFloat = 0.6
  @IBInspectable open var transitionEnabled: Bool = true
  @IBInspectable open var isOverlayEnabled: Bool = false {
    didSet {
      self.overlayView.alpha = self.isOverlayEnabled ? 1 : 0
    }
  }
  @IBInspectable open var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.4) {
    didSet {
      self.overlayView.backgroundColor = self.overlayColor
    }
  }
  
  public var isInteractive:Bool = false
  
  open override var frame: CGRect {
    didSet {
      self.layoutIfNeeded()
    }
  }
  
  override open var image: UIImage? {
    get { return super.image }
    set {
      guard self.image != newValue else { return }
      if !self.transitionEnabled {
        return
      }
      self.nextImage = newValue
      self.transitionProgress = 0.0
      self.start()
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  private func setup() {
    self.overlayView.alpha = self.isOverlayEnabled ? 1 : 0
    self.overlayView.backgroundColor = self.overlayColor
    self.addSubview(self.overlayView)
  }
  
  open func start() {
    self.fromImageView = UIImageView(frame: self.bounds)
    self.fromImageView?.image = self.image
    self.fromImageView?.contentMode = self.contentMode
    self.fromImageView?.alpha = 1
    
    self.toImageView = UIImageView(frame: self.bounds)
    self.toImageView?.image = self.nextImage
    self.toImageView?.contentMode = self.contentMode
    self.toImageView?.alpha = 0
    
    self.insertSubview(self.fromImageView!, belowSubview: self.overlayView)
    self.insertSubview(self.toImageView!, belowSubview: self.overlayView)
    super.image = nil
    if !self.isInteractive {
      self.finish()
    }
  }
  
  open func finish() {
    UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - self.transitionProgress)), animations: {
      self.fromImageView?.alpha = 0
      self.toImageView?.alpha = 1
    }) { _ in
      self.transitionProgress = 1
      self.fromImageView?.removeFromSuperview()
      self.fromImageView = nil
      self.toImageView?.removeFromSuperview()
      self.toImageView = nil
      super.image = self.nextImage
    }
  }
  
  open func cancel() {
    UIView.animate(withDuration: TimeInterval(transitionDuration * self.transitionProgress), animations: {
      self.fromImageView?.alpha = 1
      self.toImageView?.alpha = 0
    }) { _ in
      self.transitionProgress = 0
      super.image = self.fromImageView?.image
      self.fromImageView?.removeFromSuperview()
      self.fromImageView = nil
      self.toImageView?.removeFromSuperview()
      self.toImageView = nil
    }
  }
  
  public func updateProgress(progress: CGFloat) {
    self.toImageView?.alpha = progress
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    self.fromImageView?.frame = self.bounds
    self.toImageView?.frame = self.bounds
    self.overlayView.frame = self.bounds
  }
}
