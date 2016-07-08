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
    static let ParsePostCreatedAt = "createdAt"
    
    static let ParsePhotoClass = "Photo"
    static let ParsePhotoFromUser = "fromUser"
    static let ParsePhotoToPost = "toPost"
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParsePostClass)
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        query.skip = range.startIndex
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func answerRequestForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParsePhotoClass)
        query.whereKey(ParsePhotoToPost, equalTo: post)
        query.includeKey(ParsePhotoFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func likePost(user: PFUser, post: Post) {
        let likedObject = PFObject(className: ParseLikeClass)
        likedObject[ParseLikeFromUser] = user
        likedObject[ParseLikeToPost] = post
        
        likedObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
                }
            }
        }
    }
    
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
}