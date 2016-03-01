//
//  Post.swift
//  lbnet-showcase
//
//  Created by Laszlo Barabas on 2/29/16.
//  Copyright © 2016 Laszlo Barabas. All rights reserved.
//

import Foundation

class Post {
    
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    
    var postDescription: String { return _postDescription }
    var imageURL: String? { return _imageURL }
    var likes: Int { return _likes }
    var userName: String { return _username }
    
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
  
    }
    
}