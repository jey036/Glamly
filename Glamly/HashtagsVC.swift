//
//  HashtagsVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/30/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

var hashtag = [String]()

class HashtagsVC: UICollectionViewController {

    //UI objects
    var refresher = UIRefreshControl()
    var page : Int = 24
    
    //arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up collection view and navigation controller
        self.collectionView?.alwaysBounceVertical   = true
        self.navigationItem.title = hashtag.last!
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn : UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        //nenable swipe back to page
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        loadHashtags()
        
    }

   
    
    func back(sender: UIBarButtonItem) {
        //push back
        self.navigationController?.popViewControllerAnimated(true)
        
        //clean guest user name, deduct the last guest user name from array
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    // refreshing function
    func refresh() {
        // call refreshing func
        loadHashtags()
    }
    
    //load the posts associated with the hashtags
    func loadHashtags() {
        
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                self.filterArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    //store users who made the post for the related hash
                    self.filterArray.append(object.valueForKey("to") as! String)
                }
                
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                    if error == nil {
                        self.picArray.removeAll(keepCapacity: false)
                        self.uuidArray.removeAll(keepCapacity:false)
                        
                        for object in objects! {
                            self.picArray.append(object.valueForKey("pic") as! PFFile)
                            self.uuidArray.append(object.valueForKey("uuid") as! String)
                        }
                        //reload collection view now that we have the data
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    } else {
                        print(error!.localizedDescription)
                    
                    }
                })
            } else {
                print(error!.localizedDescription)
            
            }
        }
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
    
    
    //pagination funciton
    func loadMore() {
        
        //if posts on the server are more than shown increase the page size
        if page <= uuidArray.count {
            page += 15
            
            
            //load the posts up to the new page limit
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    self.filterArray.removeAll(keepCapacity: false)
                    
                    for object in objects! {
                        //store users who made the post for the related hash
                        self.filterArray.append(object.valueForKey("to") as! String)
                    }
                    
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addAscendingOrder("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                        if error == nil {
                            self.picArray.removeAll(keepCapacity: false)
                            self.uuidArray.removeAll(keepCapacity:false)
                            
                            for object in objects! {
                                self.picArray.append(object.valueForKey("pic") as! PFFile)
                                self.uuidArray.append(object.valueForKey("uuid") as! String)
                            }
                            //reload collection view now that we have the data
                            self.collectionView?.reloadData()
                          
                        } else {
                            print(error!.localizedDescription)
                            
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                    
                }
            }
            
        }
    }
   
 override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    //cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
