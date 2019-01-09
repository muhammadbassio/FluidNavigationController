//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

open class FluidViewController: UIViewController {
  
  open var navigationProperties:NavigationBarProperties = NavigationBarProperties()
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
}

extension FluidViewController {
  public struct NavigationBarProperties {
    public var title:String?
    public var subtitle:String?
    public var bagroundImage:UIImage?
    public var barColor:UIColor?
    public var barHeight:CGFloat = 44
  }
}
