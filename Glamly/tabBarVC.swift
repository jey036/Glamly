//
//  tabBarVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import MultipeerConnectivity

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

class tabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        // set red as selected background color
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(glamlyColor, size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2
        //self.view.backgroundColor = glamlyColor
        //self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.translucent = false
        //self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        //self.tabBar.barTintColor = UIColor(red: 94.0 / 255.0, green: 65.0 / 255.0, blue: 47.0 / 255.0, alpha: 1)
        self.tabBar.barTintColor = UIColor(red: 0.1176, green: 0.15686, blue: 0.247059, alpha: 1)
    }
}
