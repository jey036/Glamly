//
//  navigationBarVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/3/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class navigationBarVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.navigationBar.tintColor = .whiteColor()
        self.navigationBar.barTintColor  = UIColor(red: 10.0/255.0, green: 186.0/255.0, blue: 181.0/255.0, alpha: 1)
        self.navigationBar.translucent = false
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }



}
