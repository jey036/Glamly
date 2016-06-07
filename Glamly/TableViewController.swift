//
//  TableViewController.swift
//  Glamly
//
//  Created by Kevin Grozav on 6/6/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    var itemLabels = [String]()
    var user = String()
    var itemArray = [String]()
    var nameArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide the addBtn and seque unless the posts belongs to the current user
        if !postuuid.last!.containsString(PFUser.currentUser()!.username!) {
            print("Should have hidden the button")
            self.addBtn = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
        loadDetails()
    }
    
    func loadDetails() {
        
        let query = PFQuery(className: "details")
        print("Here is the post uuid: \(postuuid.last!)")
        query.whereKey("to", equalTo: postuuid.last!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                
                self.itemArray.removeAll(keepCapacity: false)
                
                for object in objects! {
                    self.itemArray.append(object.objectForKey("item") as! String)
                }
                self.tableView.reloadData()
            }
        }
        
        
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TCell", forIndexPath: indexPath) as! detailCell
        cell.itemLabel.text = self.itemArray[indexPath.row]
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addDetails = segue.destinationViewController as! AddDetailsVC
        for item in itemArray {
            addDetails.initialList.append(item)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let info = self.storyboard?.instantiateViewControllerWithIdentifier("InfoVC") as! InfoVC
        info.userForDetails = self.user
        info.itemTitle =  itemArray[indexPath.row] //(self.tableView.cellForRowAtIndexPath(indexPath) as! detailCell).itemLabel.text!
        self.navigationController?.pushViewController(info, animated: true)
    }
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            //delete from table view
           // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let itemName = itemArray[indexPath.row]
            
            // Delete the row from the data source
            itemArray.removeAtIndex(indexPath.row)
            
            //delete the item from the server
            let query = PFQuery(className: "details")
            query.whereKey("to", equalTo: postuuid.last!)
            query.whereKey("item", equalTo: itemName)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground()
                    }
                    self.tableView.reloadData()
                }
            })
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
