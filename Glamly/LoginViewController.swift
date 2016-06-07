//
//  LoginViewController.swift
//  Glamly
//
//  Created by Jessica on 4/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var GalmlyLbl: UILabel!
    
    // textfields
    @IBOutlet weak var usernameTxt: HoshiTextField!
    @IBOutlet weak var passwordTxt: HoshiTextField!
    
    // buttons
    @IBOutlet weak var loginBtn: ZFRippleButton!
    @IBOutlet weak var createBtn: ZFRippleButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GalmlyLbl.font = UIFont(name: "Pacifico", size: 40)
       var color = GalmlyLbl.textColor
        print("Here is the color \(color)")
        print("Here is second color \(self.view.backgroundColor)")
        //alignment
        GalmlyLbl.frame = CGRectMake(10, 80, self.view.frame.width - 20, 80)
        usernameTxt.frame = CGRectMake(10, GalmlyLbl.frame.origin.y + 120, self.view.frame.size.width - 20, 50)
        passwordTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 90, self.view.frame.size.width - 20, 50)
        forgotBtn.frame = CGRectMake(10, passwordTxt.frame.origin.y + 50, self.view.frame.size.width - 20, 50)
        loginBtn.frame = CGRectMake(20, forgotBtn.frame.origin.y + 60, self.view.frame.size.width / 4, 60)
        createBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, loginBtn.frame.origin.y, self.view.frame.size.width / 4, 60)
        
        // hide keyboard when user presses anywhere on the screen
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        
        // let view be interactive with taps
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //allow user to upload ava image from view
        let avaTap = UITapGestureRecognizer(target: self, action: "loadImg")
        avaTap.numberOfTapsRequired = 2
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    // hide keyboard when user tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        // remove keyboard
        self.view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Clicked login */
    @IBAction func loginBtn_click(sender: AnyObject) {
        
        //hide the keyboard
        self.view.endEditing(true)
        
        // If the fields are empty alert the user
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty  {
            let alert = UIAlertController(title: "PLEASE", message: "Enter all fields", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        PFUser.logInWithUsernameInBackground(usernameTxt.text!, password: passwordTxt.text!) { (user: PFUser?, error: NSError?)
            in
            if error == nil {
                
                print("ABOUT TO LOGIN")
                
                //save the user to the device if he is a valid user
                NSUserDefaults.standardUserDefaults().setObject(user!.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //login the user
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                
                let alert = UIAlertController(title: "ERROR", message: error!.localizedDescription, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
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
