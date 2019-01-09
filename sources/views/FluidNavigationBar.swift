//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidNavigationBar: UIView {
  
  @IBInspectable var animationDuration:CGFloat = 0.6 {
    didSet {
      self.backgroundImageView.transitionDuration = self.animationDuration
      self.titleLabel.transitionDuration = self.animationDuration
      self.subtitleLabel.transitionDuration = self.animationDuration
    }
  }
  public var isInteractive:Bool = false {
    didSet {
      self.backgroundImageView.isInteractive = self.isInteractive
      self.titleLabel.isInteractive = self.isInteractive
      self.subtitleLabel.isInteractive = self.isInteractive
    }
  }
  
  public var titleLabel:FluidLabel = FluidLabel(frame: .zero)
  public var subtitleLabel:FluidLabel = FluidLabel(frame: .zero)
  public var backButton:UIButton = UIButton(frame: .zero)
  public var backgroundImageView:FluidImageView = FluidImageView(frame: .zero)
  
  public var navigationController:FluidNavigationController?
  
  override open var frame: CGRect {
    didSet {
      self.layoutIfNeeded()
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
  
  open func setup() {
    self.backButton.setImage(UIImage(named: "back"), for: .normal)
    self.backButton.tintColor = UIColor.white
    
    self.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    self.titleLabel.textColor = UIColor.white
    self.titleLabel.transitionDuration = self.animationDuration
    self.titleLabel.textAlignment = .center
    
    self.subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
    self.subtitleLabel.textColor = UIColor.white
    self.subtitleLabel.transitionDuration = self.animationDuration
    self.subtitleLabel.textAlignment = .center
    
    self.backgroundImageView.contentMode = .scaleAspectFill
    self.backgroundImageView.isOverlayEnabled = true
    
    
    self.addSubview(self.backgroundImageView)
    self.addSubview(self.subtitleLabel)
    self.addSubview(self.titleLabel)
    self.addSubview(self.backButton)
    
    self.backButton.addTarget(self, action: #selector(FluidNavigationBar.backPressed), for: .touchUpInside)
    
  }
  
  
  @objc func backPressed() {
    self.navigationController?.popViewController(animated: true)
  }
  
  open override func layoutSubviews() {
    self.backButton.frame = CGRect(x: 0, y: self.safeAreaInsets.top, width: 50, height: 44)
    self.titleLabel.frame = CGRect(x: 50, y: self.safeAreaInsets.top, width: self.bounds.width - (self.safeAreaInsets.right + self.safeAreaInsets.left + 100), height: 28)
    self.subtitleLabel.frame = CGRect(x: 50, y: self.safeAreaInsets.top + 28, width: self.bounds.width - (self.safeAreaInsets.right + self.safeAreaInsets.left + 100), height: 16)
    self.backgroundImageView.frame = self.bounds
    if let nc = self.navigationController {
      self.backButton.alpha = (nc.viewControllers.count > 1) ? 1 : 0
    }
  }
  
}

