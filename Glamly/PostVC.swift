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
}
