//
//  followersVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/4/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse


var user = String()
var show = String()

class followersVC: UITableViewController {

    
    //loaded users and images from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var followArray = [String]()
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.navigationItem.title = show
        if show == "followers" {
            loadFollowers()
        }
        if show == "followings" {
            loadFollowings()
        }
    }
    
    func loadFollowers() {
        
        //STEP 1: Find in follow class those who follow current user
        //find the user's followers
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                
                //clean up the array
                self.followArray.removeAll(keepCapacity: false)
                
                //STEP 2 Hold recived data
                for object in objects! {
                    self.followArray.append(object.valueForKey("follower") as! String)
                    
                }
                
                //STEP 3: Find corresponding data in the _User table
                //find the users that we stroed in our followArray
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                    if error == nil {
                      self.usernameArray.removeAll(keepCapacity: false)
                      self.avaArray.removeAll(keepCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("image") as! PFFile)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
                } else {
                    print(error!.localizedDescription)
            }
        }
        
        print("Finished query")
    }
    
    
    func loadFollowings() {
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) in
            if error == nil {
                
                self.followArray.removeAll(keepCapacity: false)
                
                
                for object in objects! {
                    self.followArray.append(object.valueForKey("following") as! String)
                }
                
                //find users followed by user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                    if error == nil {
                        //clean up the userName array and ava image array
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("image") as! PFFile)
                            self.tableView.reloadData()
                         }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count

    }
    
    //cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        
        //connect data to the objects
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //color button if user is following or not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if count  == 0 {
                cell.followBtn.setTitle("Follow", forState: .Normal)
                cell.followBtn.backgroundColor = UIColor.lightGrayColor()
                tableView.reloadData()
            } else {
                cell.followBtn.setTitle("Following", forState: .Normal)
                cell.followBtn.backgroundColor = UIColor.greenColor()
                tableView.reloadData()
            }
        }
        
        if cell.usernameLbl.text! == PFUser.currentUser()?.username {
            cell.followBtn.hidden = true
        }
        
        return cell
    }

   
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //return a cell containg information for further action
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        //if current user is tapped, go home, if guest, go guest
        if cell.usernameLbl.text! == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
}
