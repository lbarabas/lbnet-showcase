//
//  Post.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/29/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    
    var postDescription: String { return _postDescription }
    var imageURL: String? { return _imageURL }
    var likes: Int { return _likes }
    var userName: String { return _username }
    var postKey: String { return _postKey }
    
    
    init (description: String, imageURL: String?, username: String) {
        _postDescription = description
        _imageURL = imageURL
        _username = username
    }
    
    init (postKey: String, dictionary: Dictionary<String, AnyObject>) {
        _postKey = postKey
        if let likes = dictionary["likes"] as? Int { _likes = likes } else { _likes = 0  } //so the app won't crash if "likes" is not in the data structure
        if let imgURL = dictionary["imageUrl"] as? String { _imageURL = imgURL }
        if let desc = dictionary["description"] as? String { _postDescription = desc }
  
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        //if true add a like, if false then remove a like
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        //replace the value of "likes" following the firebase URL
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
    
}