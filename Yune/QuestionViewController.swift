//
//  QuestionViewController.swift
//  Yune
//
//  Created by Bryan Ye on 6/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import UIKit
import Parse

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    
    var answerPost: Post?
    
    var photoTakingHelper: PhotoTakingHelper?
    
    private var postSource = [Post]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser {(result: [PFObject]?, error: NSError?) -> Void in
            
            self.postSource = result as? [Post] ?? []
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID("252eb1807af746fda7a9370b760340e8", withClientSecret: "c30fd81e-6e33-4c57-b1bd-bd8d94710366")
        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhoto(indexPath: NSIndexPath) {
        photoTakingHelper = PhotoTakingHelper(viewController: self, callback: { (image: UIImage?) in
            let photo = Photo()
            photo.image = image
            photo.toPost = self.postSource[indexPath.row]
            photo.uploadPhoto()
        })
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAnswers" {
            let destinationViewController = segue.destinationViewController as! AnswersViewController
            destinationViewController.post = answerPost
            
        }
    }
    
    @IBAction func unwindToQuestions(segue: UIStoryboardSegue) {
    }
}

extension QuestionViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postSource.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = postSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! QuestionTableViewCell
        cell.title.text = post.title
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGestureRecognizer)
        
        return cell
    }
}

extension QuestionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.answerPost = self.postSource[indexPath.row]
        self.performSegueWithIdentifier("showAnswers", sender: self)
    }
}

extension QuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let post = Post()
        post.title = textField.text
        post.uploadPost()
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}

extension QuestionViewController: UIGestureRecognizerDelegate {
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            print("gesture worked!")
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let photoAction = UIAlertAction(title: "Answer Question", style: .Default) { (action) in
                let cell = longPressGestureRecognizer.view as! QuestionTableViewCell
                self.takePhoto(self.tableView.indexPathForCell(cell)!)
            }
            alertController.addAction(photoAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}