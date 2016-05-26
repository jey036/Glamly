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

    // textfields
    @IBOutlet weak var usernameTxt: HoshiTextField!
    @IBOutlet weak var passwordTxt: HoshiTextField!
    
    // buttons
    @IBOutlet weak var loginBtn: ZFRippleButton!
    @IBOutlet weak var createBtn: ZFRippleButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
