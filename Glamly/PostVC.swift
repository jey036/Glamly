//
//  PostVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/27/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()
var detailsuuid = [String]()
var detailItem = [String]()

class PostVC: UITableViewController {

    //information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var picArray = [PFFile]()
    var dateArray = [NSDate?]()
    var uuidArray = [String]()
    var titleArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a new back button
        self.navigationItem.title = "Photo"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        //create a swipe recognizer for swiping back to previous view
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        //catch the like notificaiotn
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "liked", object: nil)
        
        
        
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                
                //clean up
                self.avaArray.removeAll(keepCapacity: false)
                self.usernameArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                self.titleArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    self.avaArray.append(object.valueForKey("ava") as! PFFile)
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.titleArray.append(object.valueForKey("title") as! String)
                }
                
                self.tableView.reloadData()
            }
        }
    }

    func refresh() {
        self.tableView.reloadData()
    }
    
    //number of cells in the table view
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //only one picture will be shown at a time
        return usernameArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! postCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: .Normal)
        cell.usernameBtn.sizeToFit()    
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                    print(error!.localizedDescription)
            }
        }
        
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //caclulate post data
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        
        //logic for showing the correct unit of time since post.
        if difference.second <= 0 {
            cell.dateLbl.text! = "now"
        }
        
        if difference.second > 0 && difference.minute == 0 {
            cell.dateLbl.text! = "\(difference.second)s."
        }
        
        if difference.minute > 0 && difference.hour == 0 {
            cell.dateLbl.text! = "\(difference.minute)m."
        }
        
        if difference.hour > 0 && difference.day == 0 {
            cell.dateLbl.text! = "\(difference.hour)h."
        }
        
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.dateLbl.text! = "\(difference.day)d."
        }
        
        if difference.weekOfMonth > 0 {
            cell.dateLbl.text! = "\(difference.weekOfMonth)w."
        }
        
        //display the correct icon depending on current user likes
        let didLike = PFQuery(className:"likes")
        didLike.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackgroundWithBlock { (count: Int32, error:NSError?) in
            if count == 0 {
                cell.likeBtn.setTitle("unlike", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named:"unlike2.png"), forState: .Normal)
            } else {
                cell.likeBtn.setTitle("like", forState: .Normal)
                cell.likeBtn.setBackgroundImage(UIImage(named:"like2.png"), forState: .Normal)
            }
        }
        
        //count the total likes of current post
        let countLikes = PFQuery(className:"likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            cell.likeLbl.text! = "\(count)"
        }
        
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        
        // the user taps a @mention
        cell.titleLbl.userHandleLinkTapHandler  = { label, handle, rang in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            if mention.lowercaseString == PFUser.currentUser()!.username! {
                let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercaseString)
                let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
                
            }
            
        }
        
        // the user taps a #hashtag
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercaseString)
            let hash = self.storyboard?.instantiateViewControllerWithIdentifier("HashtagsVC")  as! HashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        
        return cell
    }
    
    
    //go guest to the username page clicked
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        //call index of button
        let idx = sender.layer.valueForKey("index") as! NSIndexPath
        let cell = tableView.cellForRowAtIndexPath(idx) as! postCell
        
        if cell.usernameBtn.titleLabel?.text! == PFUser.currentUser()!.username! {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    
    @IBAction func moreBtn_click(sender: AnyObject) {
        let idx = sender.layer.valueForKey("index") as! NSIndexPath
        let cell = tableView.cellForRowAtIndexPath(idx) as! postCell
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) in
            
            
            //delete post from data structures
            self.usernameArray.removeAtIndex(idx.row)
            self.avaArray.removeAtIndex(idx.row)
            self.dateArray.removeAtIndex(idx.row)
            self.picArray.removeAtIndex(idx.row)
            self.titleArray.removeAtIndex(idx.row)
            self.uuidArray.removeAtIndex(idx.row)
            
            //delete the post form server
            let postQuery = PFQuery(className:"posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            
                            if success {
                                
                                //send notification to root view controller, to update shown posts
                                //i.e. simply reload the data, i.e. call loadPosts form HomeVC
                                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                                
                                
                                //push back
                                self.navigationController?.popViewControllerAnimated(true)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //we must delete comments, hashtags, likes to avoid server footprint
            
            //delete likes associated with this post
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            if !success {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            
            //delete comments associated with this post
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl!.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        print("DELETING A COMMENT")
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            if !success {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            
            //delete the hashtags associated with the post
            let hashtagsQuery = PFQuery(className: "hashtags")
            hashtagsQuery.whereKey("to", equalTo: cell.uuidLbl!.text!)
            hashtagsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            if !success {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        let complain = UIAlertAction(title: "Complain", style: .Default) { (UIAlertAction) in
            
            //send complaint to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.currentUser()!.username!
            complainObj["to"] = cell.uuidLbl!.text!
            complainObj["owner"] = cell.usernameBtn.titleLabel!.text!
            complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success {
                    self.alert("Complain has been successfully registered.", message: "Thank you! We will consider your complaint")
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .ActionSheet)
        let detail = UIAlertAction(title:"Details", style: .Default) { (UIAlertAction) in
            
            let details = self.storyboard?.instantiateViewControllerWithIdentifier("DetailsVC") as! TableViewController
            details.user = cell.uuidLbl.text!
            self.navigationController?.pushViewController(details, animated: true)
        }
        
        //check if the post is operated on by current user or guest user,
        //add the appropriate actions depedning on case
        if cell.usernameBtn.titleLabel!.text! == PFUser.currentUser()!.username! {
            menu.addAction(deleteAction)
            menu.addAction(detail)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(detail)
            menu.addAction(cancel)
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
        
    }
    
    
    func alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func commentBtn_click(sender: AnyObject) {
        
        let idx = sender.layer.valueForKey("index") as! NSIndexPath
        let cell = tableView.cellForRowAtIndexPath(idx) as! postCell
        
        //send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
        
        //remove the most recent uuid from the array
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
