//
//  ViewController.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/25/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    @IBAction func fbBtnPRessed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        //this syntax is now deprecated
        /*facebookLogin.logInWithReadPermissions(["email"]) {
            (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) ->
            Void in
        */
        //new syntax is (as per Ralph Cachero)
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError:NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                // added otherwise app crashed
                print("Facebook login was cancelled.")
                
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: {  error, authData in
                
                    if error != nil {
                        print("login failed. \(error)")
                    } else {
                        print("logged in!\(authData)")
                        
                        // should be done using the if let syntax...
                        let user = ["provider": authData.provider!, "blah":"test"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        
                    }
                
                })
                
            } 
        }
        
    }
    
    @IBAction func attemptLogin (sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                error, authData in
                
                if error != nil {
                    
                    print(error)
                    
                    if error.code == STATUS_ACCOUNT_NONEXISTS {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create an account", msg: "Problem creating account. Please try again")
                                //here should give more info, like pwd complexity doesn't match, ...
                                
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                
                                let user = ["provider": authData.provider!, "blah":"email test"]
                                DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                }
                                    
                                // FROM earlier
                                //DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil
                                        //could add an error handler
                                    //  if so replace nil with { err, authData in }
                                )
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                        
                    } else if error.code == STATUS_INVALID_PASSWORD {
                        
                        self.showErrorAlert("Invalid Password", msg: "Please check your password and try again")
                        
                        
                    } else {
                        self.showErrorAlert("Could not log in", msg: "Please check your user name and password")
                    }
                    
                } else {
                    
                   //added as per Marc Aupont - because without auto login with email/pwd doesn't work if credentials are already in Firebase
                   NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    
                   self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
        } else {
            showErrorAlert("Email and password required", msg: "You must enter an email and a password")
        }
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil )
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
}

