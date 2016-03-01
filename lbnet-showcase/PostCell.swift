//
//  PostCell.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/28/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var request: Request?   //url requests, so we can keep track of and cancel if not needed any more
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
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
    }
    
}
