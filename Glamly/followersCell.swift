//
//  followersCell.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/4/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse
class followersCell: UITableViewCell {

    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
//        avaImg.clipsToBounds = true
        
        //alignment
        let width = UIScreen.mainScreen().bounds.width
        avaImg.frame = CGRectMake(10, 10, width / 6, width / 6)
        usernameLbl.frame = CGRectMake(avaImg.frame.size.width + 20, 25, width / 3.2, 30)
        followBtn.frame = CGRectMake(width - (width / 3.5) - 20 , 30, width / 3.5, 20)
    }

    @IBAction func followBtn_click(sender: AnyObject) {
        let title = followBtn.titleForState(.Normal)
        
        //follow a user
        if title == "Follow" {
            let object = PFObject(className: "follow")
            
            //set the current user as the new follower of some other user
            object["follower"] = PFUser.currentUser()?.username
            
            //the other user is being followed, set him as following
            object["following"] = usernameLbl.text
            
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                
                //if successful communication with server, modify the table to now show following
                if success {
                    self.followBtn.setTitle("Following", forState: .Normal)
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        // unfollow a user
        if title == "Following" {
            
            let query = PFQuery(className:"follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: self.usernameLbl.text!)
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if success {
                                self.followBtn.setTitle("Follow", forState: .Normal)
                                self.followBtn.backgroundColor = UIColor.lightGrayColor()
                            } else {
                                print(error!.localizedDescription)
                            }
                       })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
    }
  

}
