//
//  FeedVC.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/28/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var postField: MaterialTextField!
    
    @IBOutlet weak var imageSelectorImage: UIImageView!
    var imageSelected = false
    
    var posts = [Post]()
    
    var imagePicker : UIImagePickerController!
    
    
    static var imageCache = NSCache()   //for caching images - 1 instance only
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 352
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            // this here is only called when data is changed in Firebase
            // print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                        
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            //cancel pending request if the cell is gone
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            
            return cell
        } else {
            return PostCell()
        }
        
        //return tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
        
        // this is just so we can compile without error
        //return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            // if no img make the cell smaller
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            
            if let img = imageSelectorImage.image where imageSelected == true {
                // the imageSelected == true is to check to make sure that the image is not the "camera" - which is the default
                
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
                                            
                                            print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                        
                                    }
                                    
                                }
                                
                            })
                        case .Failure(let error):
                            print(error)
                        }
                        
                }
            } else {
                // post without an image
                self.postToFirebase(nil)
            }
        }
        
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func postToFirebase (imgUrl: String?) {
        var post : Dictionary<String,AnyObject> = [
            "description": postField.text!,
            "likes": 0
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
        
        
    }

}
