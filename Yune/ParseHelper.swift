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

static func kolodaRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
    let query = PFQuery(className: "Post")
    query.includeKey("user")
    query.findObjectsInBackgroundWithBlock(completionBlock)
    }
}