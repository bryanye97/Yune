//
//  ParseHelper.swift
//  Yune
//
//  Created by Bryan Ye on 6/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    static let ParsePostClass = "Post"
    static let ParsePostUser = "user"
    
    static let ParsePhotoClass = "Photo"
    static let ParsePhotoFromUser = "fromUser"
    static let ParsePhotoToPost = "toPost"
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func answerRequestForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Photo")
        query.whereKey("toPost", equalTo: post)
        query.includeKey("fromUser")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
}