//
//  CommentVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse


//global variables
var commentuuid = [String]()
var commentowner = [String]()

class CommentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //UI objects
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var refresher : UIRefreshControl = UIRefreshControl()
    
    //assign default values for resetting UI to default
    var tableViewHeight : CGFloat = 0
    var commentY :CGFloat = 0
    var commentHeight :CGFloat = 0

    //arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [NSDate?]()
    var page : Int32 = 15
    //keyboard frame
    var keyboard = CGRect()
    
    //preload function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //modify navigation controls
        self.navigationItem.title = "Comments"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back:", style: .Plain, target: self, action: "back:")
        
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        //catch notification for keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        sendBtn.enabled = false
        
//        //dismiss keyboard tap
//        let keyboardTap = UITapGestureRecognizer(target: self, action: "hideKeyboardOnTap")
//        keyboardTap.numberOfTapsRequired = 1
//        self.view.userInteractionEnabled = true
//        self.view.addGestureRecognizer(keyboardTap)
//        
//        let textTap = UITapGestureRecognizer(target:self, action:"showKeyboardOnTap")
//        textTap.numberOfTapsRequired = 1
//        self.commentTxt.userInteractionEnabled = true
//        self.commentTxt.addGestureRecognizer(textTap)
        
        //delegates
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource  = self
        
        //modify the alignment and presentation
        self.view.backgroundColor = glamlyColor
        self.commentTxt.layer.cornerRadius = 5
        alignment()
        
        //load the comments
        loadComments()
    }
    
    
    
    //postload function
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func sendBtn_click(sender: AnyObject) {
        
        //step 1 show the comment directly on screen without going to server
        usernameArray.append(PFUser.currentUser()!.username!)
        avaArray.append(PFUser.currentUser()!.objectForKey("image") as! PFFile)
        dateArray.append(NSDate())
        
        let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        commentArray.append(commentTxt.text!.stringByTrimmingCharactersInSet(characterSet))
        tableView.reloadData()
        
        //send information to server
        let commentObj = PFObject(className: "comments")
        commentObj["username"] = PFUser.currentUser()!.username!
        commentObj["ava"] = PFUser.currentUser()!.objectForKey("image")
        commentObj["to"] = commentuuid.last!
        commentObj["comment"] = commentTxt.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        commentObj.saveEventually()
        
        //scroll to the bottom and see the written comment
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: commentArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        
        // send the hashtag to the server
        let words : [String] = commentTxt.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //define tagged words
        for var word in words {
            
            //save the hashtag in the server
            if word.hasPrefix("#") {
                //cut the symbols, just send the word
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className:"hashtags")
                hashtagObj["to"] = commentuuid.last!
                hashtagObj["by"] = PFUser.currentUser()!.username!
                hashtagObj["hashtag"]  = word.lowercaseString
                hashtagObj["comment"] = commentTxt.text
                hashtagObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                    if success {
                        print("saved hashtag: \(word)")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            }
        }
        
        
        //reset the UI
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y =  sendBtn.frame.origin.y
        
        //reset the table view
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
        
        //disable the button
        sendBtn.enabled = false
    }
    
    //load comments
    func loadComments() {
        
        //step 1 count total comments in order to skip all except page size
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo:commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            
            //if comments on the server are more than 15, implement pull to refresh function
            if self.page < count {
                self.refresher.addTarget(self, action: "loadMore", forControlEvents: UIControlEvents.ValueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    
                    //clean up
                    self.usernameArray.removeAll(keepCapacity: false)
                    self.avaArray.removeAll(keepCapacity: false)
                    self.commentArray.removeAll(keepCapacity: false)
                    self.dateArray.removeAll(keepCapacity: false)
                    
                    
                    for object in objects! {
                        self.usernameArray.append(object.objectForKey("username") as! String)
                        self.avaArray.append(object.objectForKey("ava") as! PFFile)
                        self.commentArray.append(object.objectForKey("comment") as! String)
                        self.dateArray.append(object.createdAt)
                        self.tableView.reloadData()
                     
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.commentArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    }
                } else {
                    print(error!.localizedDescription)
                }
                
            })
        }
    }
    
    //pagination
    func loadMore() {
        let countQuery = PFQuery(className:"comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) in
            self.refresher.endRefreshing()
            if self.page > count {
                self.refresher.removeFromSuperview()
            }
            
            //increase page size to load more
            if self.page < count {
                self.page += 15
                
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                    if error == nil {
                    
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        self.commentArray.removeAll(keepCapacity: false)
                        self.dateArray.removeAll(keepCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.commentArray.append(object.objectForKey("comment") as! String)
                            self.dateArray.append(object.createdAt)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
            
            
        }
    }
    
    
    //table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //cell config
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //declare cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! commentCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: .Normal)
        cell.usernameBtn.sizeToFit()
        
        
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
            
        }
    
        //calculate date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        
        if difference.second > 0 {
            cell.date.text! = "now"
        }
        
        if difference.second > 0 && difference.minute == 0 {
            cell.date.text! = "\(difference.second)s."
        }
        
        if difference.minute > 0 && difference.hour == 0 {
            cell.date.text! = "\(difference.minute)m."
        }
        
        if difference.hour > 0 && difference.day == 0 {
            cell.date.text! = "\(difference.hour)h."
        }
        
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.date.text! = "\(difference.day)d."
        }
        
        if difference.weekOfMonth > 0 {
            cell.date.text! = "\(difference.weekOfMonth)w."
        }
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        // the user taps an @mention
        cell.commentLbl.userHandleLinkTapHandler  = { label, handle, rang in
            
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
        cell.commentLbl.hashtagLinkTapHandler = { label, handle, range in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercaseString)
            let hash = self.storyboard?.instantiateViewControllerWithIdentifier("HashtagsVC")  as! HashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        return cell
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        //disable button if no text is eterened
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        if !commentTxt.text!.stringByTrimmingCharactersInSet(spacing).isEmpty {
            sendBtn.enabled = true
        } else {
            sendBtn.enabled = false
        }
        
        //+ paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.size.height < 130 {
            let difference = textView.contentSize.height - textView.frame.size.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            //move up the table view
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        
        // - paragraph
        else if textView.contentSize.height < tableView.frame.size.height {
            
            let difference  = textView.frame.size.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            //move down the table view
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height {
                tableView.frame.size.height += difference
            }
            
        }
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //obtain the cell, we perform the action on
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! commentCell
        
        //ACTION to delete a comment
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "   ") { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            
            //delete the comment from the server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    
                    //delete the objects that meet restrictions above
                    for object in objects! {
                        print("DELETED")
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                            
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            
            //delete the hashtag from the server if it exists
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last!)
            hashtagQuery.whereKey("by", equalTo:cell.usernameBtn.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if success {
                                print("deleted hashtag object from server")
                            }
                        })
                    }
                }
            })
            
        
            self.tableView.setEditing(false, animated: true)
            
            //delete the comment from table view
            self.commentArray.removeAtIndex(indexPath.row)
            self.dateArray.removeAtIndex(indexPath.row)
            self.usernameArray.removeAtIndex(indexPath.row)
            self.avaArray.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
        
        //ACTION to mention someone in a comment
        let address = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "   ") { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            //include user name in text view
            self.commentTxt.text! = "\(self.commentTxt.text! + "@" + self.usernameArray[indexPath.row] + " ")"
            self.sendBtn.enabled = true
            tableView.setEditing(false, animated: true)
        }
        
        //ACTION to complain about a comment
        let complain = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "   ") { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            
            //send complaint to server regarding selected comment
            let complaintObj = PFObject(className: "complain")
            complaintObj["by"] = PFUser.currentUser()!.username!
            complaintObj["post"] = commentuuid.last!
            complaintObj["to"] =  cell.commentLbl.text!
            complaintObj["owner"] = cell.usernameBtn.titleLabel!.text!
            
            complaintObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if success {
                    self.alert("Complaint has been successfully registered", message: "Thank you! We will consider your complaint")
                } else {
                    print(error!.localizedDescription)
                }
            })
            tableView.setEditing(false, animated: true)
        }
        
        //buttons background color
        delete.backgroundColor = UIColor(patternImage: UIImage(named:"deleteBtn.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named:"addressBtn.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named:"complaintBtn.png")!)
        
        //when comments belong to the user
        if cell.usernameBtn.titleLabel!.text! == PFUser.currentUser()!.username! {
            return [delete,address]
        } else if commentowner.last! == PFUser.currentUser()!.username! {
            return [delete, address, complain]
        } else {
            return [address, complain]
        }
    }
    
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //hide the tabbar
    override func viewWillAppear(animated: Bool) {
        // hide bottom bar
        self.tabBarController?.tabBar.hidden = true
        
        //call our keyboard
        commentTxt.becomeFirstResponder()
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //move the user interface up with animation
        UIView.animateWithDuration(0.4) { 
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.commentTxt.frame.origin.y  = self.commentY - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
       
        //loading function when keyboard is not shown
        
        //move the user interface down with animatin
        UIView.animateWithDuration(0.4) { 
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        }
    }
    
//    func keyboardTap() {
//        self.view.endEditing(true)
//    }
    
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRectMake(0, 0, width, height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.3333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        commentTxt.frame = CGRectMake(10, tableView.frame.size.height + height / 56.8, width / 1.306, 33)
        sendBtn.frame = CGRectMake(commentTxt.frame.origin.x + commentTxt.frame.size.width +  (width / 32), commentTxt.frame.origin.y, width - (commentTxt.frame.origin.x + commentTxt.frame.size.width) - ((width / 32) * 2), 33)
        
        //assign reseting values 
        tableViewHeight = tableView.frame.size.height
        commentY = commentTxt.frame.origin.y
        commentHeight = commentTxt.frame.size.height
        
    }
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        //get the appropriate cell
        let idx = sender.layer.valueForKey("index") as! NSIndexPath
        let cell = tableView.cellForRowAtIndexPath(idx) as! commentCell
        
        
        //if user tapped on himeself go home, else go guest
        if cell.usernameBtn.titleLabel!.text! == PFUser.currentUser()!.username! {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: false)
        }
        
    }

    func back(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        //clean comment uuid
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
        //celan comment owner
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}
