//
//  commentCell.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    // UI objects
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        alignment()
    }

    func alignment() {
        
        //set up for the constraints
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        commentLbl.translatesAutoresizingMaskIntoConstraints   = false
        date.translatesAutoresizingMaskIntoConstraints = false
        
        
        //constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[username]-(-2)-[comment]-5-|",
            options: [], metrics: nil, views: ["username":usernameBtn, "comment":commentLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-15-[date]",
            options:[], metrics: nil, views: ["date":date]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(40)]",
            options: [], metrics: nil, views: ["ava":avaImg]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(40)]-13-[comment]-20-|",
            options: [], metrics: nil, views: ["ava":avaImg, "comment":commentLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[ava]-13-[username]",
            options: [], metrics: nil, views: ["ava":avaImg, "username":usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":date]))
        
        
    }

}
