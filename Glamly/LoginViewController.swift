//
//  LoginViewController.swift
//  Glamly
//
//  Created by Jessica on 4/28/16.
//  Copyright © 2016 UCSD. All rights reserved.
//

import UIKit

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Clicked login */
    @IBAction func loginBtn_click(sender: AnyObject) {
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
