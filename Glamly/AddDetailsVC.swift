//
//  AddDetailsVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/31/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class AddDetailsVC: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var itemText: UITextField!
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var linkText: UITextView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceText: UITextField!
    
    var initialList = [String]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    var scrollViewHeight:CGFloat = 0
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Link Items"
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "addItem")
        
        //set up the height of the scroll view
        self.scrollView.frame = CGRectMake(0,0,self.view.frame.width, self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        // receive notification when keyboard is showing or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateAccountViewController.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateAccountViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //set the link text as placeholder using delegate funcs
        self.linkText.delegate = self
        self.linkText.textColor = UIColor.lightGrayColor()
        self.linkText.text = "Add links..."
        
        //add a tap gesture to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.scrollView.userInteractionEnabled = true
        self.scrollView.addGestureRecognizer(backSwipe)
        
    }
    
    // if keyboard is shown, launch this function
    func showKeyboard(notification:NSNotification) {
        
        // calculate and receive keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        // animation of current view - move up current user interface
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    // if keyboard is hidden, launch this function
    func hideKeyboard(notification:NSNotification) {
        
        // move down keyboard animation
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    
    //text view delegate methods
    //clear the place holder when the user begins to enter text
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    //if text view on end editing display the placeholder
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text!.isEmpty {
            textView.text! = "Add a caption..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    //dismiss the keyboard on tap
    func hideKeyboard() {
        self.view.endEditing(true)
    }

    func backSwipe() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    
    //save the information to the server and transition back to table view
    func addItem() {
        
        //if item and link are empty, alert the user
        if itemText!.text!.isEmpty && linkText!.text!.isEmpty {
            let emptyFields = UIAlertController(title: "Please", message: "Enter item and link below", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            emptyFields.addAction(okAction)
            self.presentViewController(emptyFields, animated: true, completion: nil)
        } else {
            
            //prepare to send information to the server
            let detailsObj = PFObject(className: "details")
            detailsuuid.append(postuuid.last! as! String)
            detailItem.append(itemText.text! as! String)
            print("Here is uuid count: \(detailsuuid.count)")
            print("Here is items count: \(detailItem.count)")
            detailsObj["to"] = postuuid.last!
            detailsObj["item"] = itemText.text!.lowercaseString
            detailsObj["link"] = linkText.text!.lowercaseString
            if priceText.text! == "" {
                detailsObj["price"] = ""
            } else {
                detailsObj["price"] = priceText.text!.lowercaseString
            }
            
            detailsObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if !success {
                    print(error!.localizedDescription)
                }
            })
        }
        
        
        
        //go back to the previous view
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        //if item and link are empty, alert the user
        if itemText!.text!.isEmpty && linkText!.text!.isEmpty {
            let emptyFields = UIAlertController(title: "Please", message: "Enter item and link below", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            emptyFields.addAction(okAction)
            self.presentViewController(emptyFields, animated: true, completion: nil)
        } else {
            
            //prepare to send information to the server
            let detailsObj = PFObject(className: "details")
            detailsuuid.append(postuuid.last! as! String)
            detailItem.append(itemText.text! as! String)
            print("Here is uuid count: \(detailsuuid.count)")
            print("Here is items count: \(detailItem.count)")
            detailsObj["to"] = postuuid.last!
            detailsObj["item"] = itemText.text!.lowercaseString
            detailsObj["link"] = linkText.text!.lowercaseString
            if priceText.text! == "" {
                detailsObj["price"] = ""
            } else {
                detailsObj["price"] = priceText.text!.lowercaseString
            }
            
            detailsObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                if !success {
                    print(error!.localizedDescription)
                }
            })
        }
        
        let tableVC = segue.destinationViewController as! TableViewController
        
        //add the previous items
        for item in initialList {
            tableVC.itemArray.append(item)
        }
        //add the new item
        tableVC.itemArray.append(itemText!.text!)
        
    }
    
    
    func functionToPassAsAction() {
        var controller: UINavigationController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("NavBarHome") as! UINavigationController
       
        
        //controller.yourTableViewArray = localArrayValue
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}
