//
//  tabBarVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class tabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = glamlyColor
        self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.translucent = false
        //self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        //self.tabBar.barTintColor = UIColor(red: 94.0 / 255.0, green: 65.0 / 255.0, blue: 47.0 / 255.0, alpha: 1)
        self.tabBar.barTintColor = glamlyColor
    }
}
