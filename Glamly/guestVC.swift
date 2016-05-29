//
//  guestVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/26/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

//global variables
var guestname = [String]()

class guestVC: UICollectionViewController {
    
    
    //UIOBjects
    var refresher: UIRefreshControl!
    var page : Int = 10
    
    //arrays to populate view with information from server
    var uuidArray = [String]()
    var picArray = [PFFile]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        //allow vertical scroll for page refresh
        self.collectionView!.alwaysBounceVertical = true
        self.navigationItem.title = guestname.last
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn : UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        //pull to refesh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refresher)
    
        loadPosts()
    }
    
    
    func back(sender: UIBarButtonItem) {
        //push back
        self.navigationController?.popViewControllerAnimated(true)
        
        //clean guest user name, deduct the last guest user name from array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                
                //clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    self.uuidArray.append(object.objectForKey("uuid") as! String)
                    self.picArray.append(object.objectForKey("pic") as! PFFile)
                }
                
                //populate the view with this data
                self.collectionView?.reloadData()
            
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) in
            if error == nil {
                cell.picImg.image = UIImage(data:data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderView
        header.descriptionLbl.text! = ""
        
        //load data of the guest from the server
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: guestname.last!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                
                //check if the user is a valid user
                if objects!.isEmpty {
                    print("wrong user")
                }
                
                for object in objects! {
                    header.fullnameLbl!.text = object.objectForKey("username") as! String
                    let avaFile : PFFile = object.objectForKey("image") as! PFFile
                    avaFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) in
                        if error == nil {
                            header.avaImg.image = UIImage(data: data!)
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
                
                
                
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        //place correct btn depending on whether guest is being followed or not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if error == nil {
                if count == 0 {
                    header.editProfileBtn.setTitle("Follow", forState: .Normal)
                    header.editProfileBtn.backgroundColor = UIColor.lightGrayColor()
                } else {
                    header.editProfileBtn.setTitle("Following", forState: .Normal)
                    header.editProfileBtn.backgroundColor = UIColor.greenColor()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //count the statistics of the guest
        //count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if error == nil {
               header.posts.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
    
        
        //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if error == nil {
                header.following.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //count the followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        //implement tap gestures, let posts be tapped
        let postsTap = UITapGestureRecognizer(target: self, action: "postsTap")
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: "followingsTap")
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: "followersTap")
        followingsTap.numberOfTapsRequired = 1
        header.following.userInteractionEnabled = true
        header.following.addGestureRecognizer(followingsTap)
        
        
        return header
    }
    
    func postsTap() {
        if (!picArray.isEmpty) {
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
            
        }
    }
    
    func followersTap() {
        user = guestname.last!
        show = "followers"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingsTap() {
        user = guestname.last!
        show = "followings"
        
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    // go to post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //push the uuid of the selected image onto the navVC stack
        postuuid.append(uuidArray[indexPath.row])
        
        //navigate to post view controller
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
    }
}
