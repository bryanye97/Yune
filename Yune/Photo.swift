//
//  Photo.swift
//  Yune
//
//  Created by Bryan Ye on 7/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import Foundation

import Foundation
import Parse
import Bond
import ConvenienceKit

class Photo: PFObject, PFSubclassing {
    
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    //  var image: Observable<UIImage?> = Observable(nil)
    var image: UIImage?
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    @NSManaged var toPost: Post?
    
    static func parseClassName() -> String {
        return "Photo"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
            Photo.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
    func uploadPhoto() {
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler{ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                
                if let error = error {
                    print("\(error) occurred")
                }
                
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    //    func downloadImage() {
    //        image.value = Photo.imageCache[self.imageFile!.name]
    //
    //        if image.value == nil {
    //            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
    //                if let data = data {
    //                    let image = UIImage(data: data, scale:1.0)!
    //                    self.image.value = image
    //
    //                    Photo.imageCache[self.imageFile!.name] = image
    //                }
    //            }
    //        }
    //    }
}