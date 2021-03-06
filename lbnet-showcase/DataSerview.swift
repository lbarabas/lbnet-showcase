//
//  DataSerview.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/27/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://lbnet.firebaseio.com"

class DataService {
    static let ds = DataService()  // there will be only one instance - globally accessible
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")

    
    var REF_BASE: Firebase { return _REF_BASE }
    
    var REF_POSTS: Firebase { return _REF_POSTS }
    
    var REF_USERS: Firebase { return _REF_USERS }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
         // above is equivalent to     let user = Firebase(url: "\(URL_BASE)/users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser (uid: String, user: Dictionary<String,String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
        
    }
    
    func updateFirebaseUser (key: String, value : String) {
        
        let post : Dictionary<String,AnyObject> = [ key : value ]
        // this method however erases any other data and only keeps the
        //    REF_USER_CURRENT.setValue(post)
        // so the right method to use is
        REF_USER_CURRENT.updateChildValues(post)
        
    }
    
    func printCurrentUserURL () {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let userUrl = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        
        print(userUrl)
    }
    
    
}