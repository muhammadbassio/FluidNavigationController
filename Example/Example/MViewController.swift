//
//  MViewController.swift
//  Example
//
//  Created by Muhammad Bassio on 1/6/19.
//  Copyright © 2019 Muhammad Bassio. All rights reserved.
//

import UIKit

class MViewController: FluidNavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mmm") as? FluidViewController {
        vc.view.backgroundColor = UIColor.red
        vc.navigationProperties.title = "the title"
        vc.navigationProperties.subtitle = "subtitle"
        vc.navigationProperties.barHeight = 44
        vc.navigationProperties.bagroundImage = UIImage(named: "im1")
        vc.navigationProperties.barColor = UIColor.purple
        self.pushViewController(vc, animated: true)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mmm") as? FluidViewController {
          vc.view.backgroundColor = UIColor.green
          vc.navigationProperties.title = "another title"
          vc.navigationProperties.subtitle = "another subtitle"
          vc.navigationProperties.barHeight = 70
          vc.navigationProperties.bagroundImage = UIImage(named: "im2")
          self.pushViewController(vc, animated: true)
        }
      }
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}

