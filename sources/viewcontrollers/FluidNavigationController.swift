//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidNavigationController: UIViewController {
  
  @IBInspectable var contentViewCornerRadius:CGFloat = 10
  @IBInspectable var animationDuration:CGFloat = 0.6 {
    didSet {
      self.navigationBar.animationDuration = self.animationDuration
    }
  }
  
  /// The view controllers currently managed by the container view controller.
  open var viewControllers:[FluidViewController] = []
  
  /// The gesture recognizer responsible for changing view controllers. (read-only)
  open private(set) var interactivePopGestureRecognizer:UIScreenEdgePanGestureRecognizer?
  
  /// The view enclosing all child views
  public var contentView:ContainerView = ContainerView(frame: .zero)
  
  /// The container view controller delegate receiving the protocol callbacks.
  open var delegate:FluidNavigationControllerDelegate?
  public var currentOperation:UINavigationController.Operation = .none
  
  public var navigationBar:FluidNavigationBar = FluidNavigationBar(frame: .zero)
  public var preAnimationBlock:(() -> Void)?
  public var animationBlock:((_ percentage:CGFloat) -> Void)?
  public var postAnimationBlock:((_ completion:((Bool) -> ())?) -> Void)?
  public var rollbackBlock:(() -> Void)?
  
  
  private var isTransitioning:Bool = false
  private var isInteractive:Bool = false
  private var shouldCompleteTransition:Bool = false
  private var currentViewController:FluidViewController?
  private var nextViewController:FluidViewController = FluidViewController()
  
  private var barStartHeight:CGFloat = 44
  private var barEndHeight:CGFloat = 44
  
  private var toStartFrame = CGRect.zero
  private var toEndFrame = CGRect.zero
  private var fromStartFrame = CGRect.zero
  private var fromEndFrame = CGRect.zero
  
  
  var topViewController: FluidViewController? {
    return self.viewControllers.last
  }

  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if let mask = self.delegate?.navigationControllerSupportedInterfaceOrientations?(self) {
      return mask
    }
    if self.viewControllers.count > 0 {
      if let vc = self.viewControllers.last {
        return vc.supportedInterfaceOrientations
      }
    }
    return super.supportedInterfaceOrientations
  }
  
  open override var prefersStatusBarHidden: Bool {
    if let vc = self.viewControllers.last {
      return vc.prefersStatusBarHidden
    }
    return super.prefersStatusBarHidden
  }
  
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    if let vc = self.viewControllers.last {
      return vc.preferredStatusBarStyle
    }
    return super.preferredStatusBarStyle
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.isOpaque = true
    
    self.initNavigationBar()
    self.initAnimationBlocks()
    
    self.contentView.layer.cornerRadius = self.contentViewCornerRadius
    self.contentView.clipsToBounds = true
    self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.contentView.backgroundColor = UIColor.yellow
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    
    self.navigationBar.navigationController = self
    
    self.view.addSubview(self.navigationBar)
    self.view.addSubview(self.contentView)
    
    self.interactivePopGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(FluidNavigationController.handleGesture(gestureRecognizer:)))
    self.interactivePopGestureRecognizer?.edges = .left
    self.interactivePopGestureRecognizer?.delegate = self
    
    if self.viewControllers.count > 0 {
      self.updateUI()
    }
    
  }

  open override func viewWillLayoutSubviews() {
    if !self.isTransitioning {
      self.layoutSubviews()
    }
  }
  
  func updateUI() {
    if let vc = self.viewControllers.last {
      self.view.backgroundColor = vc.navigationProperties.barColor
    }
  }
  
  /// Override this method to make your own navigationBar
  open func initNavigationBar() {
    
  }
  
  /// Override to handle your own animation
  open func initAnimationBlocks() {
    
    self.preAnimationBlock = {
      self.nextViewController.view.translatesAutoresizingMaskIntoConstraints = true
      self.nextViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.nextViewController.view.frame = self.contentView.bounds
      
      self.toStartFrame = self.contentView.bounds.offsetBy(dx: self.contentView.bounds.width, dy: 0)
      self.toEndFrame = self.contentView.bounds
      self.fromStartFrame = self.contentView.bounds
      self.fromEndFrame = self.contentView.bounds.offsetBy(dx: -120, dy: 0)
      
      self.barStartHeight = self.contentView.frame.origin.y - self.view.safeAreaInsets.top
      self.barEndHeight = self.nextViewController.navigationProperties.barHeight
      
      if self.currentOperation == .pop {
        self.navigationBar.titleLabel.transitionDirection = .leftToright
        self.navigationBar.subtitleLabel.transitionDirection = .leftToright
        self.fromStartFrame = self.contentView.bounds
        self.fromEndFrame = self.contentView.bounds.offsetBy(dx: self.contentView.bounds.width, dy: 0)
        self.toStartFrame = self.contentView.bounds.offsetBy(dx: -120, dy: 0)
        self.toEndFrame = self.contentView.bounds
      } else {
        self.navigationBar.titleLabel.transitionDirection = .rightToleft
        self.navigationBar.subtitleLabel.transitionDirection = .rightToleft
        self.contentView.addSubview(self.nextViewController.view)
      }
      self.currentViewController?.view.frame = self.fromStartFrame
      self.nextViewController.view.frame = self.toStartFrame
      
      self.navigationBar.titleLabel.isInteractive = self.isInteractive
      self.navigationBar.subtitleLabel.isInteractive = self.isInteractive
      self.navigationBar.backgroundImageView.isInteractive = self.isInteractive
      
      if self.isInteractive {
        self.navigationBar.backgroundColor = self.nextViewController.navigationProperties.barColor
        self.navigationBar.titleLabel.text = self.nextViewController.navigationProperties.title
        self.navigationBar.subtitleLabel.text = self.nextViewController.navigationProperties.subtitle
        self.navigationBar.backgroundImageView.image = self.nextViewController.navigationProperties.bagroundImage
      }
    }
    
    self.postAnimationBlock = { completion in
      self.isTransitioning = false
      self.contentView.isAnimating = false
      switch self.currentOperation {
      case .push:
        self.addChild(self.nextViewController)
        self.nextViewController.didMove(toParent: self)
        self.viewControllers.append(self.nextViewController)
        completion?(true)
      case .pop:
        self.currentViewController?.view.removeFromSuperview()
        self.currentViewController?.didMove(toParent: nil)
        completion?(true)
      default:
        return
      }
      self.nextViewController.view.addGestureRecognizer(self.interactivePopGestureRecognizer!)
      self.layoutSubviews()
    }
    
    self.rollbackBlock = {
      let barH = self.barStartHeight + self.view.safeAreaInsets.top
      
      self.currentViewController?.view.frame = self.fromStartFrame
      self.nextViewController.view.frame = self.toStartFrame
      self.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barH + self.contentViewCornerRadius)
      self.contentView.frame = CGRect(x: 0, y: barH, width: self.view.bounds.width, height: self.view.bounds.height - barH)
      self.navigationBar.backButton.alpha = (self.currentOperation == .pop) ? ((self.viewControllers.count < 3) ? 0 : 1) : ((self.viewControllers.count > 0) ? 1 : 0)
      
      self.navigationBar.backgroundImageView.updateProgress(progress: 0)
      self.navigationBar.titleLabel.updateProgress(progress: 0)
      self.navigationBar.subtitleLabel.updateProgress(progress: 0)
    }
    
    self.animationBlock = { percentage in
      let cX = ((self.fromEndFrame.origin.x - self.fromStartFrame.origin.x) * percentage) + self.fromStartFrame.origin.x
      let nX = ((self.toEndFrame.origin.x - self.toStartFrame.origin.x) * percentage) + self.toStartFrame.origin.x
      let barH = ((self.barEndHeight - self.barStartHeight) * percentage) + self.barStartHeight + self.view.safeAreaInsets.top
      
      self.currentViewController?.view.frame = CGRect(x: cX, y: self.fromEndFrame.origin.y, width: self.fromEndFrame.width, height: self.fromEndFrame.height)
      self.nextViewController.view.frame = CGRect(x: nX, y: self.toEndFrame.origin.y, width: self.toEndFrame.width, height: self.toEndFrame.height)
      self.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barH + self.contentViewCornerRadius)
      self.contentView.frame = CGRect(x: 0, y: barH, width: self.view.bounds.width, height: self.view.bounds.height - barH)
      self.navigationBar.backButton.alpha = (self.currentOperation == .pop) ? ((self.viewControllers.count < 3) ? 0 : percentage) : ((self.viewControllers.count > 0) ? percentage : 0)
      
      if self.isInteractive {
        self.navigationBar.backgroundImageView.updateProgress(progress: percentage)
        self.navigationBar.titleLabel.updateProgress(progress: percentage)
        self.navigationBar.subtitleLabel.updateProgress(progress: percentage)
      } else {
        self.navigationBar.backgroundColor = self.nextViewController.navigationProperties.barColor
        self.navigationBar.titleLabel.text = self.nextViewController.navigationProperties.title
        self.navigationBar.subtitleLabel.text = self.nextViewController.navigationProperties.subtitle
        self.navigationBar.backgroundImageView.image = self.nextViewController.navigationProperties.bagroundImage
      }
    }
  }
  
  /// Override to customize the layout
  open func layoutSubviews() {
    var barHeight = self.view.safeAreaInsets.top
    if let vc = self.viewControllers.last {
      barHeight = self.view.safeAreaInsets.top + vc.navigationProperties.barHeight
    }
    self.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barHeight + self.contentViewCornerRadius)
    self.contentView.frame = CGRect(x: 0, y: barHeight, width: self.view.bounds.width, height: self.view.bounds.height - barHeight)
  }
  
  @objc func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      if !self.isTransitioning {
        self.isInteractive = true
        self.isTransitioning = true
        self.currentOperation = .pop
        self.currentViewController = self.viewControllers[self.viewControllers.count - 1]
        self.nextViewController = self.viewControllers[self.viewControllers.count - 2]
        self.contentView.isAnimating = true
        self.preAnimationBlock?()
      }
    case .changed:
      guard let view = self.view else {
        break
      }
      let translation = gestureRecognizer.translation(in: view)
      let percent: CGFloat = min(max(translation.x / view.frame.width, 0), 1)
      
      let velocity = gestureRecognizer.velocity(in: view)
      if velocity.x > 300 {
        self.shouldCompleteTransition = true
      }
      else if velocity.x < -300 {
        self.shouldCompleteTransition = false
      }
      else {
        self.shouldCompleteTransition = percent > 0.5
      }
      self.animationBlock?(percent)
    case .cancelled, .ended:
      if !self.shouldCompleteTransition || gestureRecognizer.state == .cancelled {
        UIView.animate(withDuration: TimeInterval(self.animationDuration), animations: {
          self.rollbackBlock?()
        })
      }
      else {
        UIView.animate(withDuration: TimeInterval(self.animationDuration), animations: {
          self.animationBlock?(1)
        }) { _ in
          self.postAnimationBlock?({ _ in
            self.viewControllers.removeLast()
          })
        }
      }
    default:
      break
    }
  }
  
  
  public func pushViewController(_ viewController: FluidViewController, animated: Bool) {
    if !self.isTransitioning {
      self.currentOperation = .push
      self.transition(to: viewController, animated: animated)
    }
  }
  
  @discardableResult public func popViewController(animated: Bool) -> FluidViewController? {
    if !self.isTransitioning {
      self.currentOperation = .pop
      if self.viewControllers.count > 1 {
        let fromVC = self.viewControllers[self.viewControllers.count - 1]
        let toVC = self.viewControllers[self.viewControllers.count - 2]
        self.transition(from: fromVC, to: toVC, animated: animated) { _ in
          self.viewControllers.removeLast()
        }
        return fromVC
      }
    }
    return nil
  }
  
  @discardableResult public func popToRootViewController(animated: Bool) -> [FluidViewController]? {
    if !self.isTransitioning {
      self.currentOperation = .pop
      if self.viewControllers.count > 1 {
        let fromVC = self.viewControllers[self.viewControllers.count - 1]
        let toVC = self.viewControllers[0]
        self.transition(from: fromVC, to: toVC, animated: animated) { _ in
          self.viewControllers = [toVC]
        }
        return Array(self.viewControllers.dropFirst())
      }
    }
    return nil
  }
  
  
  func transition(to viewController:FluidViewController, animated: Bool) {
    self.transition(from: self.viewControllers.last, to: viewController, animated: animated, completion: nil)
  }
  
  func transition(from currentViewController: FluidViewController?, to nextViewController: FluidViewController, animated: Bool, completion: ((Bool) -> ())?) {
    
    self.currentViewController = currentViewController
    self.nextViewController = nextViewController
    
    self.isTransitioning = true
    self.contentView.isAnimating = true
    
    self.preAnimationBlock?()
    if animated {
      UIView.animate(withDuration: TimeInterval(self.animationDuration), animations: {
        self.animationBlock?(1)
      }) { _ in
        self.postAnimationBlock?(completion)
      }
    } else {
      self.animationBlock?(1)
      self.postAnimationBlock?(completion)
    }
    
  }
  
}

extension FluidNavigationController: UIGestureRecognizerDelegate {
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if self.viewControllers.count > 1 {
      return true
    }
    return false
  }
}
