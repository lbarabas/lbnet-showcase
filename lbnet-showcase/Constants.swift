//
//  Constants.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/25/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import Foundation
import UIKit

//no class, so everything here is globally accessible

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

// Keys
let KEY_UID = "uid"

//Segues
let SEGUE_LOGGED_IN = "loggedIn"

//Status codes
//  they are listed at the bottom of page https://www.firebase.com/docs/ios/guide/user-auth.html

let STATUS_ACCOUNT_NONEXISTS = -8  // equivalent to ErrorUserDoesNotExist as returned by FAuthentication()
let STATUS_INVALID_PASSWORD = -6
let STATUS_INVALID_EMAIL = -5


