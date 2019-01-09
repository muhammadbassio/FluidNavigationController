//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

@objc public protocol FluidNavigationControllerDelegate {
  @objc optional func navigationController(_ navigationController: FluidNavigationController, willShow viewController: FluidViewController, animated: Bool)
  @objc optional func navigationController(_ navigationController: FluidNavigationController, didShow viewController: FluidViewController, animated: Bool)
  
  @objc optional func navigationController(_ navigationController: FluidNavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: FluidViewController, to toVC: FluidViewController) -> UIViewControllerAnimatedTransitioning?
  @objc optional func navigationController(_ navigationController: FluidNavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
  @objc optional func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: FluidNavigationController) -> UIInterfaceOrientation
  @objc optional func navigationControllerSupportedInterfaceOrientations(_ navigationController: FluidNavigationController) -> UIInterfaceOrientationMask

}
