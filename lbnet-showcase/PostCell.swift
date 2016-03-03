//
//  PostCell.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/28/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postedByImg: UIImageView!
    
    var post: Post!
    var request: Request?   //url requests, so we can keep track of and cancel if not needed any more
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
    }

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.layer.cornerRadius = profileImg.frame.size.width / 2
        showcaseImg.clipsToBounds = true
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        
        // refernce to the likes of this specific post within the our account (did we like the post?)
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
  
        print("Description = \(post.postDescription)")
        
        if let pUID = post.postedByUID {
            // let's look up the nickname for the user who made the post - if post.postedByUID is valid (not nil)
            print ("pUID= \(pUID)")
            let nickURL = DataService.ds.REF_USERS.childByAppendingPath(pUID) //.childByAppendingPath("nickname")
            
            nickURL.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let nickname = snapshot.value.objectForKey("nickname") as? String {
                    // this does not seem necessary
                    /*
                    if snapshot.value is NSNull {
                        print("The posting user does not have a nickname")
                    } else {
                        print("Posting user's nickname is \(nickname)")
                    }
                    */
                    self.postedBy.text = nickname
                } else {
                    print("nickname can't be converted")
                }
                
            }, withCancelBlock: { error in
                print(error.description)
            })
        }

        
        if post.imageURL != nil {
            if img != nil {
                //image is cached
                self.showcaseImg.image = img
            } else {
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        
                        //let img = UIImage(data: data!)! // but should do it with if let like below
                        if let img = UIImage(data: data!) {
                            self.showcaseImg.image = img
                            //add to cache
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                        }
                    }
                })
            }
            // this below was causing problems because the image didn't get reset to visible when scrolled back up. 
            //   commented out because the above if let img = ... captures this condition
        //} else {
            //self.showcaseImg.hidden = true
        }
        
        
        //let likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {   //firebase returns NSNull if no data exists
                // no like for the specific post
                self.likeImg.image = UIImage(named: "heart-empty")
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
        
        })
    }
    
    
    func likeTapped(sender: UITapGestureRecognizer ) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {   //firebase returns NSNull if no data exists
                // if we didn't like it before and tapped on the heart, then we are liking it now
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true) //increment like on the post
                self.likeRef.setValue(true) //set it to "true" under the user's own account
            } else {
                // if we liked it before and tapped on the heart, then we don't like it any more
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()  // delete the like key from under the user's own account
            }
            
        })
    }
    
    
}
