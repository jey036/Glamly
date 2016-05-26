//
//  followersCell.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/4/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class followersCell: UITableViewCell {

    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
