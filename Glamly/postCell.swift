//
//  postCell.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/27/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeBtn.setTitleColor(UIColor.clearColor(), forState: .Normal)
        
        
        // Initialization code
        let width = UIScreen.mainScreen().bounds.width
        
        //allow constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints  = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        picImg.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.translatesAutoresizingMaskIntoConstraints  = false
        moreBtn.translatesAutoresizingMaskIntoConstraints  = false
        commentBtn.translatesAutoresizingMaskIntoConstraints  = false
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        uuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        let pictureWidth = width - 20
        
//        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
//            "V:|-50-[pic]",
//            options: [],
//            metrics: nil, views: ["pic":picImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(30)]-10-[pic(\(pictureWidth-65))]-5-[like(30)]",
            options: [],metrics: nil, views: ["ava":avaImg, "pic":picImg, "like":likeBtn]))

        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[username]",
            options: [],
            metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-5-[comment(30)]",
            options: [],
            metrics: nil, views: ["pic":picImg, "comment":commentBtn]))
        
        //i set to 15
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-20-[date]",
            options: [],
            metrics: nil, views: ["date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[like(30)]-5-[title]-5-|",
            options: [], metrics: nil, views: ["like":likeBtn, "title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-5-[more(30)]",
            options: [], metrics: nil, views: ["pic":picImg, "more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[likes]",
            options: [], metrics: nil, views: ["pic":picImg, "likes":likeLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(30)]-10-[username]",
            options: [], metrics: nil, views: ["ava":avaImg, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[pic]-10-|",
            options: [], metrics: nil, views: ["pic":picImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]",
            options: [], metrics: nil, views: ["like":likeBtn, "likes":likeLbl, "comment":commentBtn]))
    
    
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[more(30)]-15-|",
            options: [], metrics: nil, views: ["more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-20-[title]-20-|",
            options: [], metrics: nil, views: ["title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[date]-10-|",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
      
    
        //if we want a round ava
        //avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        
        //enable double tap like desture
        let likeTap = UITapGestureRecognizer(target: self, action: "likeTap")
        likeTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
        
    }

    func likeTap() {
        
        // create a large heart image
        let likePic = UIImageView(image: UIImage(named: "like2.png"))
        likePic.frame.size.width = picImg.frame.size.width / 1.5
        likePic.frame.size.height = picImg.frame.size.height / 1.5
        likePic.center = picImg.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        //hide likePic with animatation and transform to be smaller
        UIView.animateWithDuration(0.4) { () -> Void in
            likePic.alpha = 0
            likePic.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }
        
        let title = likeBtn.titleForState(.Normal)
        if title == "unlike" {
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()!.username!
            object["to"] = uuidLbl.text!
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success {
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like2.png"), forState: .Normal)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                } else {
                    
                }
            })
        } else {
            
        }
        
    }
    
    @IBAction func likeBtn_click(sender: AnyObject) {
        let title = sender.titleForState(.Normal)
        if title == "unlike" {
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()!.username!
            object["to"] = uuidLbl.text!
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success {
                    self.likeBtn.setTitle("like", forState: .Normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like2.png"), forState: .Normal)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                } else {
                    
                }
            })
        } else {
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("to", equalTo: uuidLbl.text!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success: Bool, error:NSError?) in
                            if success {
                                self.likeBtn.setTitle("unlike", forState: .Normal)
                                self.likeBtn.setBackgroundImage(UIImage(named: "unlike2"), forState: .Normal)
                                NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
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
