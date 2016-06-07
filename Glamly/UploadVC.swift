//
//  UploadVC.swift
//  Glamly
//
//  Created by Kevin Grozav on 5/27/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    @IBOutlet weak var removeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable the upload button
        uploadBtn.enabled = false
        uploadBtn.backgroundColor = glamlyColor //UIColor.lightGrayColor()
        
        //hide the remove button until an image is uploaded
        removeBtn.hidden = true
        
        //set the picImg to the standard blank image
        //set ourselves as the delegate
        titleText.delegate = self
        picImg.image = UIImage(named: "generic_profile_pic.jpg")
        self.titleText.text = "Add a caption..."
        self.titleText.textColor = UIColor.lightGrayColor()
        
        //dismiss the keyboard on tap
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardTap")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //select a photo on tap
        let picTap = UITapGestureRecognizer(target: self, action: "selectImg")
        picTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled  = true
        picImg.addGestureRecognizer(picTap)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //programtic layout
        alignment()
    }
    
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
    
    
    @IBAction func removeBtn_click(sender: AnyObject) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //hide the keyboard when called
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    //call image picker view controller to select image form library
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    //hold the selected in the picImage image property
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //enable the upload button on scree
        self.uploadBtn.enabled = true
        self.uploadBtn.backgroundColor = glamlyColor //UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        //show the remove button now 
        self.removeBtn.hidden = false
        
        //zoom in on the screen
        let zoomTap = UITapGestureRecognizer(target: self, action: "zoomImg")
        zoomTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    
    //zooming in the image
    func zoomImg() {
        
        //frame sizes for zoomed and unzoomed images
        let zoomed = CGRectMake(0, self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, self.view.frame.size.width, self.view.frame.size.width)
        let unzoomed = CGRectMake(15, 15, self.view.frame.size.width / 4.5, self.view.frame.size.width / 4.5)
        
        //check the current frame size and make zoom/unzoom frame size as necessary
        if picImg.frame == unzoomed {
            UIView.animateWithDuration(0.3, animations: { 
                //make the image larger and black out the rest of screen
                self.picImg.frame = zoomed
                self.view.backgroundColor = UIColor.blackColor()
                self.titleText.alpha = 0
                self.uploadBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
        } else {
            UIView.animateWithDuration(0.3, animations: { 
                //return to the original layout before having zoomed in
                self.picImg.frame = unzoomed
                self.view.backgroundColor = UIColor.whiteColor()
                self.titleText.alpha = 1
                self.uploadBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
    }
    
    
    func alignment() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        picImg.frame = CGRectMake(15, 15, width / 4.5, width / 4.5)
        titleText.frame = CGRectMake(picImg.frame.size.width + 25, picImg.frame.origin.y, width - titleText.frame.origin.x - 20, picImg.frame.size.height)
        uploadBtn.frame = CGRectMake(0, height / 1.09, width, width / 8)
        removeBtn.frame = CGRectMake(picImg.frame.origin.x, picImg.frame.origin.y + picImg.frame.size.height, picImg.frame.size.width, 20)
    }

    @IBAction func uploadBtn_click(sender: AnyObject) {
        self.view.endEditing(true)
        
        //sending photo details to parse server
        let object = PFObject(className:"posts")
        object["username"] = PFUser.currentUser()!.username
        object["ava"] = PFUser.currentUser()!.objectForKey("image") as! PFFile
        let uuid = NSUUID().UUIDString
        object["uuid"] = "\(PFUser.currentUser()!.username) \(uuid)"
        
        if titleText.text!.isEmpty || titleText.text! == "Add a caption..." {
            object["title"] = ""
        } else {
            //send text to server without whitespaces and new lines
            object["title"] = titleText.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        //send the image to the server
        let picData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let picFile = PFFile(name: "post.jpg", data: picData!)
        object["pic"] = picFile
        
        
        // send the hashtag to the server
        let words : [String] = titleText.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //define tagged words
        for var word in words {
            
            //save the hashtag in the server
            if word.hasPrefix("#") {
                //cut the symbols, just send the word
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className:"hashtags")
                hashtagObj["to"] =  "Optional(" + "\"" + PFUser.currentUser()!.username! + "\"" + ") " +  uuid
                hashtagObj["by"] = PFUser.currentUser()!.username!
                hashtagObj["hashtag"] = word.lowercaseString
                hashtagObj["comment"]  = titleText.text
                hashtagObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) in
                    if success {
                        print("saved hashtag: \(word)")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            }
        }

        
        
        
        //saving the changes on the server
        object.saveInBackgroundWithBlock { (success: Bool, error:NSError?) in
            if error == nil {
                //send notification that picture is uploaded and switch to another vc
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                self.tabBarController?.selectedIndex = 0
                
                //clear the components after upload
                //disable the upload button
                self.uploadBtn.enabled = false
                self.uploadBtn.backgroundColor = glamlyColor //UIColor.lightGrayColor()
                
                //hide the remove button until an image is uploaded
                self.removeBtn.hidden = true
                
                //set the picImg to the standard blank image
                //set ourselves as the delegate
                self.titleText.delegate = self
                self.picImg.image = UIImage(named: "generic_profile_pic.jpg")
                self.titleText.text = "Add a caption..."
                self.titleText.textColor = UIColor.lightGrayColor()

                self.viewDidLoad()
                
            } else {
                print(error!.localizedDescription)
            }
           
        }
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
   

}
