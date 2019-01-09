//
//  FluidLabel.swift
//  Example
//
//  Created by Muhammad Bassio on 1/6/19.
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidLabel: UILabel {
  
  public enum Direction:Int {
    case rightToleft = 0
    case leftToright = 1
    case topToBottom = 2
    case bottomToTop = 3
  }
  
  fileprivate var fromLabel: UILabel?
  fileprivate var toLabel: UILabel?
  private var nextText:String?
  private let maskLayer = CAGradientLayer()
  
  @IBInspectable open var fadeWidth: CGFloat = 20.0
  @IBInspectable open var transitionProgress: CGFloat = 0.0
  @IBInspectable open var transitionDuration: CGFloat = 0.6
  @IBInspectable open var transitionEnabled: Bool = true
  
  public var transitionDirection: Direction = .rightToleft
  public var isInteractive:Bool = false
  
  open override var frame: CGRect {
    didSet {
      maskLayer.frame = self.bounds
      let point = self.fadeWidth / self.bounds.width
      maskLayer.locations = [NSNumber(value: 0), NSNumber(value: Double(point)), NSNumber(value: Double(1 - point)), NSNumber(value: 1)]
      self.layoutIfNeeded()
    }
  }
  
  override open var text: String? {
    get { return super.text }
    set {
      guard self.text != newValue else { return }
      if !self.transitionEnabled {
        return
      }
      self.nextText = newValue
      self.transitionProgress = 0.0
      self.start()
    }
  }
  
  open func start() {
    self.fromLabel = UILabel(frame: self.bounds)
    self.fromLabel?.font = self.font
    self.fromLabel?.textColor = self.textColor
    self.fromLabel?.text = self.text
    self.fromLabel?.textAlignment = self.textAlignment
    
    self.toLabel = UILabel(frame: self.bounds.offsetBy(dx: ((self.transitionDirection == .rightToleft) ? self.bounds.size.width : -self.bounds.size.width), dy: 0))
    self.toLabel?.font = self.font
    self.toLabel?.textColor = self.textColor
    self.toLabel?.text = self.nextText
    self.toLabel?.textAlignment = self.textAlignment
    
    self.addSubview(self.fromLabel!)
    self.addSubview(self.toLabel!)
    
    super.text = nil
    if !self.isInteractive {
      self.finish()
    }
  }
  
  open func finish() {
    UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - self.transitionProgress)), animations: {
      self.toLabel?.frame = self.bounds
      self.fromLabel?.frame = self.bounds.offsetBy(dx: (self.transitionDirection == .rightToleft) ? -self.bounds.size.width : self.bounds.size.width, dy: 0)
    }) { _ in
      self.transitionProgress = 1
      self.fromLabel?.removeFromSuperview()
      self.fromLabel = nil
      self.toLabel?.removeFromSuperview()
      self.toLabel = nil
      super.text = self.nextText
    }
  }
  
  open func cancel() {
    UIView.animate(withDuration: TimeInterval(transitionDuration * self.transitionProgress), animations: {
      self.fromLabel?.frame = self.bounds
      self.toLabel?.frame = self.bounds.offsetBy(dx: (self.transitionDirection == .rightToleft) ? self.bounds.size.width : -self.bounds.size.width, dy: 0)
    }) { _ in
      self.transitionProgress = 0
      super.text = self.fromLabel?.text
      self.fromLabel?.removeFromSuperview()
      self.fromLabel = nil
      self.toLabel?.removeFromSuperview()
      self.toLabel = nil
    }
  }
  
  public func updateProgress(progress: CGFloat) {
    self.toLabel?.frame = self.bounds.offsetBy(dx: ((self.transitionDirection == .rightToleft) ? self.bounds.size.width : -self.bounds.width) * (1 - progress), dy: 0)
    self.fromLabel?.frame = self.bounds.offsetBy(dx: ((self.transitionDirection == .rightToleft) ? -self.bounds.size.width : self.bounds.width) * progress, dy: 0)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    initMask()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initMask()
  }
  
  func initMask() {
    maskLayer.frame = self.bounds
    maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
    maskLayer.startPoint = CGPoint(x: 0, y: 0.5)
    maskLayer.endPoint = CGPoint(x: 1, y: 0.5)
    self.layer.mask = maskLayer
  }
  
}

