//
//  ProfileVC.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 3/2/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var nickNameLbl : UITextField!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var passwordLbl : UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func UpdateBtn(sender: AnyObject) {
        DataService.ds.printMyInfo()
        let nn = nickNameLbl.text!
        DataService.ds.updateFirebaseUser (nn)

        
    }
    
    func saveNickname (nickname : String) {
     //   DataService.ds.REF_USER_CURRENT
     // _postRef.childByAppendingPath("nickname").setValue(_nickname)
        
        
    }
    
  }
