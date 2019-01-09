//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidContextTransitioning: NSObject, UIViewControllerContextTransitioning {
  public var containerView: UIView
  public var isAnimated: Bool
  public var isInteractive: Bool
  public var transitionWasCancelled: Bool
  public var presentationStyle: UIModalPresentationStyle
  public var targetTransform: CGAffineTransform
  public var completionBlock: ((_ didComplete: Bool) -> ())?
  
  private var viewControllers:[UITransitionContextViewControllerKey:UIViewController] = [:]
  private var views:[UITransitionContextViewKey:UIView] = [:]
  private var appearenceStartFrame = CGRect.zero
  private var appearenceEndFrame = CGRect.zero
  private var disappearenceStartFrame = CGRect.zero
  private var disappearenceEndFrame = CGRect.zero
  
  init(fromViewController:UIViewController, toViewController:UIViewController) {
    if (fromViewController.isViewLoaded && toViewController.isViewLoaded) {
      self.isAnimated = false
      self.isInteractive = false
      self.transitionWasCancelled = false
      self.targetTransform = CGAffineTransform()
      self.presentationStyle = .custom
      //self.containerView = fromViewController.view.superview!
      self.containerView = (fromViewController.parent?.view)!
      self.transitionWasCancelled = false
      self.viewControllers = [.from: fromViewController, .to: toViewController]
      self.views = [.from: fromViewController.view, .to: toViewController.view]
      self.appearenceEndFrame = self.containerView.bounds
      self.disappearenceStartFrame = self.containerView.bounds
      self.appearenceStartFrame = self.containerView.bounds.offsetBy(dx: 120, dy: 0)
      self.disappearenceEndFrame = self.containerView.bounds.offsetBy(dx: -120, dy: 0)
      super.init()
    } else {
      fatalError("The fromViewController view must reside in the container view upon initializing the transition context.")
    }
  }
  
  open func updateInteractiveTransition(_ percentComplete: CGFloat) {
    
  }
  
  open func finishInteractiveTransition() {
    self.transitionWasCancelled = false
  }
  
  open func cancelInteractiveTransition() {
    self.transitionWasCancelled = true
  }
  
  open func pauseInteractiveTransition() {
    
  }
  
  open func completeTransition(_ didComplete: Bool) {
    self.completionBlock?(didComplete)
  }
  
  open func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
    return self.viewControllers[key]
  }
  
  public func view(forKey key: UITransitionContextViewKey) -> UIView? {
    return self.views[key]
  }
  
  open func initialFrame(for vc: UIViewController) -> CGRect {
    if vc == self.viewControllers[.from] {
      return self.disappearenceStartFrame
    } else {
      return self.appearenceStartFrame
    }
  }
  
  open func finalFrame(for vc: UIViewController) -> CGRect {
    if vc == self.viewControllers[.from] {
      return self.disappearenceEndFrame
    } else {
      return self.appearenceEndFrame
    }
  }
  
  
}
