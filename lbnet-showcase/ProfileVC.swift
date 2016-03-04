//
//  ProfileVC.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 3/2/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nickNameLbl : UITextField!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var passwordLbl : UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    
    var profileImgChanged = false
    var imagePicker : UIImagePickerController!
    
    var requestUsr: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // if there is a nickname for the user already let's show it
        //DataService.ds.printCurrentUserURL()
        getNickname()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func UpdateBtn(sender: AnyObject) {
       saveUpdates()
    }
    
    
    @IBAction func profileImgBtn(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        profileImgChanged = true
    }
    
    
    func saveUpdates () {
        
        let nn = nickNameLbl.text!
        DataService.ds.updateFirebaseUser ("nickname", value: nn)
       
        if let img = profileImg.image where profileImgChanged == true {
            
            let urlStr = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlStr)!
            
            //let's convert the image to JPG and compress it  (1 = no compression, 0 = max compression)
            let imgData = UIImageJPEGRepresentation(img, 0.2)!
            // this key is Mark Price's paid account key - do not use elsewhere
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
            
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                
                multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                }) { encodingResult in
                    //this is what happens when upload is done
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String,AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String,AnyObject> {
                                    
                                    if let imgLink = links["image_link"] as? String {
                                        
                                        print("LINK to profile image: \(imgLink)")
                                        DataService.ds.updateFirebaseUser ("profileUrl", value: imgLink)
                                        self.profileImgChanged = false
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        })
                    case .Failure(let error):
                        print(error)
                    }
                    
            }
        }

       
        //somewhere here needs to say success, then dismiss this VC
        
    }
    
    
    func getNickname () {
        
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let userUrl = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        
        userUrl.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let nick = snapshot.value.objectForKey("nickname") as? String {
                //print("nick= \(nick)")
                self.nickNameLbl.text = nick
            } else {
                print("nickname can't be converted")
            }
            
            if let postedByProfileUrl = snapshot.value.objectForKey("profileUrl") as? String {
                //print("profileUrl=\(postedByProfileUrl)")
                
                
                //at this point we have to get the image - should check if in cache....
                // imageCache is statis from FeedVC
                
                var img: UIImage?
                
                img = FeedVC.imageCache.objectForKey(postedByProfileUrl) as? UIImage
                
                if img != nil {
                    //image is cached
                    self.profileImg.image = img
                } else {
                    
                    //print("profileUrl=\(postedByProfileUrl)")
                    self.requestUsr = Alamofire.request(.GET, postedByProfileUrl)
                        .validate(contentType: ["image/*"])
                        .response(completionHandler: { (request, response, data, err) in
                            if err == nil {
                                if let img = UIImage(data: data!) {
                                    self.profileImg.image = img
                                    //add to cache
                                    FeedVC.imageCache.setObject(img, forKey: postedByProfileUrl)
                                }
                            }
                        })
                }
                
                
                
                
                
            }
            
            
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }

    
    
  }
