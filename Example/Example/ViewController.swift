//
//  Example
//
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var label:UILabel?
  @IBOutlet var image:FluidImageView?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.image?.isInteractive = true
    self.image?.image = UIImage(named: "im2")
    
    //self.showIm2()
    
    /*
    let animator = UIViewPropertyAnimator(duration: 8, curve: .linear) {
      self.label?.text = "modifiedText :)"
    }
    animator.startAnimation()*/
    //animator.pauseAnimation()
    //animator.fractionComplete = 0.5
  }

  @IBAction func slider(sender:UISlider) {
    self.image?.updateProgress(progress: CGFloat(sender.value))
  }
  
  func showIm1() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
      self.image?.image = UIImage(named: "im1")
      self.showIm2()
    }
  }
  
  func showIm2() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
      self.image?.image = UIImage(named: "im2")
      self.showIm1()
    }
  }
  
}

