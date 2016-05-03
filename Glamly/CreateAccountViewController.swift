//
//  CreateAccountViewController.swift
//  Glamly
//
//  Created by Jessica on 4/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    // buttons
    @IBOutlet weak var createBtn: ZFRippleButton!
    @IBOutlet weak var cancelBtn: ZFRippleButton!
    
    
    // textfields
    @IBOutlet weak var usernameTxt: HoshiTextField!
    @IBOutlet weak var emailTxt: HoshiTextField!
    @IBOutlet weak var passwordTxt: HoshiTextField!
    @IBOutlet weak var reenterTxt: HoshiTextField!
    
    // scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    // reset defualt size of scroll view
    var scrollViewHeight : CGFloat = 0
    
    // keyboard frame size
    var keyboard = CGRect()

    // main defualt function, runs when application is launched
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // reset scroll view height
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        // scrolling height content size equal to view controller size
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        // receive notification when keyboard is showing or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateAccountViewController.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateAccountViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // hide keyboard when user presses anywhere on the screen
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        
        // let view be interactive with taps
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }
    
    // hide keyboard when user tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        // remove keyboard
        self.view.endEditing(true)
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
    
    @IBAction func signupBtn_click(sender: AnyObject) {
    }
    
    @IBAction func cancelBtn_click(sender: AnyObject) {
        // dismiss this view controller and go back to main view controller
        // true - wanted to be animated
        // no function when completed
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
