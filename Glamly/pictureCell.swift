//
//  pictureCell.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/23/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.mainScreen().bounds.width
        picImg.frame = CGRectMake(0,0, width / 3, width / 3)
        
    }
}
