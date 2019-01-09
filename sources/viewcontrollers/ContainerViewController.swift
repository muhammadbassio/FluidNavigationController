//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class ContainerViewController: UIViewController {
  
  /// The view controllers currently managed by the container view controller.
  open var viewControllers:[FluidViewController] = []
  
  /// The gesture recognizer responsible for changing view controllers. (read-only)
  open private(set) var interactiveTransitionGestureRecognizer:UIGestureRecognizer?
  
  /// The view enclosing all child views
  public var contentView:ContainerView = ContainerView(frame: .zero)
  
  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if self.viewControllers.count > 0 {
      if let vc = self.viewControllers.last {
        return vc.supportedInterfaceOrientations
      }
    }
    return super.supportedInterfaceOrientations
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.contentView)
  }
  
  override open func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  open override func viewSafeAreaInsetsDidChange() {
    self.layoutSubviews()
  }
  
  
  open override func viewWillLayoutSubviews() {
    self.layoutSubviews()
  }
  
  open func layoutSubviews() {
    self.contentView.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: (self.view.bounds.width - (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right)), height: (self.view.bounds.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)))
  }
  
  
  /// Override to initialize your own animator
  open func transitionAnimator(from currentViewController:FluidViewController, to nextViewController:FluidViewController) -> UIViewControllerAnimatedTransitioning? {
    return nil
  }
  
  /// Override to initialize your own interaction controller
  open func interactionController(animator:UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return nil
  }
  
  
  
  open func transition(from currentViewController:FluidViewController?, to nextViewController:FluidViewController, animated: Bool, completion:((_ completed: Bool) -> ())?) {
    
    let toView = nextViewController.view
    toView?.translatesAutoresizingMaskIntoConstraints = true
    toView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    toView?.frame = self.contentView.bounds
    
    guard let fromViewController = currentViewController else {
      self.contentView.addSubview(toView!)
      self.addChild(nextViewController)
      nextViewController.didMove(toParent: self)
      completion?(true)
      return
    }
    
    guard let animator = self.transitionAnimator(from: fromViewController, to: nextViewController), animated else {
      // No animator implemented
      self.contentView.addSubview(toView!)
      self.addChild(nextViewController)
      nextViewController.didMove(toParent: self)
      completion?(true)
      return
    }
    
    let context = FluidContextTransitioning(fromViewController: fromViewController, toViewController: nextViewController)
    context.isAnimated = true
    context.completionBlock = { didComplete in
      if didComplete {
        fromViewController.view.removeFromSuperview()
        fromViewController.willMove(toParent: nil)
        self.addChild(nextViewController)
      } else {
        toView?.removeFromSuperview()
      }
      completion?(didComplete)
      animator.animationEnded?(didComplete)
    }
    
    guard let interactionController = self.interactionController(animator: animator) else {
      animator.animateTransition(using: context)
      return
    }
    
    context.isInteractive = true
    interactionController.startInteractiveTransition(context)
    
  }
}

