//
//  AnswersViewController.swift
//  Yune
//
//  Created by Bryan Ye on 7/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import UIKit
import Parse

class AnswersViewController: UIViewController {
    
    var post: Post?
    
    @IBOutlet weak var questionLabel: UILabel!
    
    private var photoSource = [Photo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let post = post {
            ParseHelper.answerRequestForPost(post) { (result: [PFObject]?, error: NSError?) in
                self.photoSource = result as? [Photo] ?? []
                
                for photo in self.photoSource {
                    do {
                        let imageData = try photo.imageFile?.getData()
                        photo.image = UIImage(data: imageData!, scale:1.0)
                    } catch {
                        print("could not get image")
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = post?.title ?? ""
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AnswersViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoSource.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! AnswerTableViewCell
        cell.backgroundColor = .cyanColor()
        let imageSource = photoSource[indexPath.row]
        cell.photoImageView.image = imageSource.image.value
        return cell
    }
}
