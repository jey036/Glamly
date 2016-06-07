//
//  InfoVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 6/6/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class InfoVC: UIViewController {

    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var itemTxt: UITextView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceTxt: UILabel!
    var userForDetails : String!
    var itemTitle : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "details")
        query.whereKey("to", equalTo: postuuid.last!)
        query.whereKey("item", equalTo: itemTitle)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if error == nil {
                
                //get only the first object, since it is unique
                self.itemTxt.text = self.itemTitle
                self.descriptionTxt.text = objects![0].objectForKey("link") as! String
                self.priceTxt.text = objects![0].objectForKey("price") as? String
            }
        }
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
