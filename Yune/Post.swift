//
//  Post.swift
//  Yune
//
//  Created by Bryan Ye on 6/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import Foundation
import Parse
import Bond
import ConvenienceKit


class Post: PFObject, PFSubclassing {
    
    @NSManaged var title: String?
    @NSManaged var user: PFUser?
    var photos: Observable<[Photo]?> = Observable(nil)
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        user = PFUser.currentUser()!
        let post = PFObject(className:"Post")
        post["title"] = title
        post["user"] = user
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("upload success")
            } else {
                print("upload fail")
            }
        }
    }
    
    func fetchLikes() {
        if (likes.value != nil) {
            return
        }
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    func stringFromUserList(userList: [PFUser]) -> String {
        
        let usernameList = userList.map { user in user.username! }
        
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }

}