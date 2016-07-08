//
//  QuestionViewController.swift
//  Yune
//
//  Created by Bryan Ye on 6/07/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class QuestionViewController: UIViewController, TimelineComponentTarget {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    
    var timelineComponent: TimelineComponent<Post, QuestionViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    var answerPost: Post?
    
    var photoTakingHelper: PhotoTakingHelper?
    
    private var postSource = [Post]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
    
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
        
            let postSource = result as? [Post] ?? []
            
            completionBlock(postSource)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        view.backgroundColor = UIColor(red: 0, green: 255/255, blue: 204/255, alpha: 1)
        self.view.addSubview(view)

        
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID("252eb1807af746fda7a9370b760340e8", withClientSecret: "c30fd81e-6e33-4c57-b1bd-bd8d94710366")
        
        timelineComponent = TimelineComponent(target: self)
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
            photo.toPost = self.timelineComponent.content[indexPath.row]
            photo.uploadPhoto()
        })
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAnswers" {
            let destinationViewController = segue.destinationViewController as! AnswersViewController
            destinationViewController.post = answerPost
            
        }
    }

    @IBAction func takePicture(sender: UIButton) {
    }

    @IBAction func unwindToQuestions(segue: UIStoryboardSegue) {
    }
}

extension QuestionViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineComponent.content.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! QuestionTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        post.fetchLikes()

        cell.title.text = post.title
        cell.post = post
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGestureRecognizer)
        
        return cell
    }
}

extension QuestionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.answerPost = self.timelineComponent.content[indexPath.row]
        self.performSegueWithIdentifier("showAnswers", sender: self)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
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
            
            let alertController = UIAlertController(title: "Would you like to answer this question?", message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let photoAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
                let cell = longPressGestureRecognizer.view as! QuestionTableViewCell
                self.takePhoto(self.tableView.indexPathForCell(cell)!)
            }
            alertController.addAction(photoAction)
            
            alertController.view.tintColor = UIColor(red: 0, green: 179/255, blue: 143/255, alpha: 1)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}