//
//  HeaderView.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/23/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
        
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    
    
    @IBOutlet weak var editProfileBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment of the header UI
        let width = UIScreen.mainScreen().bounds.width
        avaImg.frame = CGRectMake(width / 16, width / 16, width / 4, width  / 4)
        posts.frame = CGRectMake(width / 2 , avaImg.frame.origin.y, 50, 30)
        followers.frame = CGRectMake(width / 1.5 , avaImg.frame.origin.y, 50, 30)
        following.frame = CGRectMake(width / 1.25 + 5, avaImg.frame.origin.y, 50 ,30)
        
        postsLbl.center = CGPointMake(posts.center.x, posts.center.y + 20)
        followersLbl.center = CGPointMake(followers.center.x - 15, followers.center.y + 20)
        followingLbl.center = CGPointMake(following.center.x - 6, following.center.y + 20)
       
        editProfileBtn.frame = CGRectMake(postsLbl.frame.origin.x, postsLbl.center.y + 20, width - postsLbl.frame.origin.x - 25, 20)
        fullnameLbl.frame = CGRectMake(avaImg.frame.origin.x, avaImg.frame.origin.y + avaImg.frame.size.height,width - 20, 30)
        descriptionLbl.frame = CGRectMake(avaImg.frame.origin.x - 5,fullnameLbl.frame.origin.y + 15, width - 30, 30)
        
        //avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        //avaImg.clipsToBounds = true
        
        
    }
    
    
    @IBAction func followBtn_click(sender: AnyObject) {
        
        let title = editProfileBtn.titleForState(.Normal)
        
        //follow a user
        if title == "Follow" {
            let object = PFObject(className: "follow")
            
            //set the current user as the new follower of some other user
            object["follower"] = PFUser.currentUser()?.username
            
            //the other user is being followed, set him as following
            object["following"] = fullnameLbl.text
            
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                
                //if successful communication with server, modify the table to now show following
                if success {
                    self.editProfileBtn.setTitle("Following", forState: .Normal)
                    self.editProfileBtn.backgroundColor = UIColor.greenColor()
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
        // unfollow a user
        if title == "Following" {
            
            let query = PFQuery(className:"follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: self.fullnameLbl.text!)
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if success {
                                self.editProfileBtn.setTitle("Follow", forState: .Normal)
                                self.editProfileBtn.backgroundColor = UIColor.lightGrayColor()
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
