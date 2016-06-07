//
//  HomeVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/23/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse
import MultipeerConnectivity

//global variable for passing mpc data to UsersVC
//var mpcUsernames = [String]()

class HomeVC: UICollectionViewController, MPCManagerDelegate {
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var refresher : UIRefreshControl!
    var page: Int = 12
    var picArray = [PFFile]()
    var userNameArray = [String]()
    var uuidArray = [String]()
    
    override func viewDidLoad() {
        if appDelegate.useMPC {
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        
        for peer in appDelegate.mpcManager.foundPeers {
            appDelegate.mpcManager.browser.invitePeer(peer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 30)
        }
        
        }
        
        super.viewDidLoad()
        collectionView?.backgroundColor = .whiteColor()
        self.navigationItem.title = PFUser.currentUser()?.username
        
        self.collectionView?.alwaysBounceVertical = true
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refresher)
        
        //revceive notification from editVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "reload", object: nil)
        
        loadPosts()
        
        //recieve notification from uploadVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploaded:", name: "uploaded", object: nil)
    }
    
    //reloading function
    func reload(notification:NSNotification){
        collectionView?.reloadData()
    }
    
    
    func foundPeer() {
        print("found peers:")
        for id in appDelegate.mpcManager.displayNames {
            print("peer: \(id)")
            //mpcUsernames.append(id)
        }
        print("# of peers: \(self.appDelegate.mpcManager.displayNames.count)")
    }
    
    
    
    func lostPeer() {
        print("lost peer")
    }
    
    
    func sendMPCData() {
//        let usernameDictionary : [String: String] = ["username": PFUser.currentUser()!.username!]
//        if appDelegate.mpcManager.sendData(dictionaryWithData: usernameDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] ) {
//            mpcUsernames.append(PFUser.currentUser()!.username!)
//        }
    }
    
    //MPC CODE
    func invitationWasReceived(formPeer: String) {
        sendMPCData()
        self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
    }
    
    
    
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    
 
    
    func loadPosts() {
        
        //target the specific table named 'posts' in the database
        let query = PFQuery(className: "posts")
        //search for the 'username' column, where the username equals the current user
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        //set a limit on the number of posts that can be displayed initially, without pull to refresh
        query.limit = page
        
        //find these objects in the database
        query.findObjectsInBackgroundWithBlock ({ (objects: [PFObject]?, error : NSError?)-> Void in
            if error == nil {
                
                //clean up our datastructures from previous calls
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                //find objects related to our request
                for object in objects! {
                    
                    //add found data to arrays (holders)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                //reload this infomation since the tableview displays information
                //form the arrays that we have just populated
                self.collectionView?.reloadData()
            }else{
                //print any error if conenctinf to the database
                print(error!.localizedDescription)
            }
        })

    }
    
    //reload the posts after having uploaded an image
    func uploaded(notification: NSNotification) {
         //TODO: AFTER GETTING CODE UNCOMMENT THIS
        loadPosts()
    }
    
    //clicked logout
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) in
            if error == nil {
                //erase nsuserdefaults, removed logged in user from app memory
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let signInVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! LoginViewController
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = signInVC
                
            } else {
                print(error!.localizedDescription)
            }
            
        }
    
    }
    
    
    //cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)-> UICollectionViewCell {
        //define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        //get picture from the picArray
        picArray[indexPath.row].getDataInBackgroundWithBlock ({ (data:NSData?, error:NSError?)-> Void in
            if error == nil {
                cell.picImg.image = UIImage(data:data!)
            }
        })
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderView
        
        header.fullnameLbl.text = PFUser.currentUser()?.username
        header.descriptionLbl.text = ""
        
        let avaQuery = PFUser.currentUser()?.objectForKey("image") as! PFFile
        avaQuery.getDataInBackgroundWithBlock { (data:NSData?, error: NSError?) in
            if error == nil {
                header.avaImg.image = UIImage(data: data!)
                
            }
        }
        
        header.editProfileBtn.setTitle("edit profile", forState: .Normal)
        
        //count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        posts.countObjectsInBackgroundWithBlock( { (count: Int32, error:NSError?) ->Void in
            if error == nil{
                header.posts.text = "\(count)"
            }
        })
        
        //count total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followers.countObjectsInBackgroundWithBlock( { (count: Int32, error:NSError?) ->Void in
            if error == nil{
                header.followers.text = "\(count)"
            }
        })
        
        
        //count total followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        followings.countObjectsInBackgroundWithBlock( { (count: Int32, error:NSError?) ->Void in
            if error == nil{
                header.following.text = "\(count)"
            }
        })
        
        
        //Implement tap gestures
        //tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: "postsTap")
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: "followersTap")
        followersTap.numberOfTapsRequired = 1
        header.following.userInteractionEnabled = true
        header.following.addGestureRecognizer(followersTap)
        
        //tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: "followingsTap")
        followingsTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followingsTap)
        
        
        return header
    }
    
    //taped posts label
    func postsTap(){
        if !picArray.isEmpty{
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    //tapped followers label
    func followersTap (){
        user = PFUser.currentUser()!.username!
        show = "followers"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //tapped followings label
    func followingsTap(){
        user = PFUser.currentUser()!.username!
        show = "followings"
        
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        self.navigationController?.pushViewController(followings, animated: true)
        
    }

    

    //load more images when we reach bottom of pagination
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - self.view.frame.size.height) {
            self.loadMore()
        }
    }
    
    //paging more posts
    func loadMore() {
        //if there are more images to be retreived from server
        if page <= picArray.count {
           //increase page size
            page = page + 12
            let query = PFQuery(className:"posts")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    
                    self.uuidArray.removeAll(keepCapacity: false)
                    self.picArray.removeAll(keepCapacity: false)
                    
                    for object in objects! {
                        self.uuidArray.append(object.valueForKey("uuid") as! String)
                        self.picArray.append(object.valueForKey("pic") as! PFFile)
                    }
                    
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    // go to post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //push the uuid of the selected image onto the navVC stack
        postuuid.append(uuidArray[indexPath.row])
        
        //navigate to post view controller
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}
