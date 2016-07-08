//
//  QuestionTableViewCell.swift
//  Yune
//
//  Created by Bryan Ye on 6/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import UIKit
import Parse
import Bond

class QuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    var post: Post? {
        didSet {
            
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    
                    if let value = value {
                        
                        self.likesLabel.text = self.stringFromUserList(value)
                        
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        
                    } else {
                        
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonTapped(sender: UIButton) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    func stringFromUserList(userList: [PFUser]) -> String {
        
        let usernameList = userList.map { user in user.username! }
        
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }

}
