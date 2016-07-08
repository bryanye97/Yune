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
}