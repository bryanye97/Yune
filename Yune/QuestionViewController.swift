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
    
    private var dataSource = [Post]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.kolodaRequestForCurrentUser {(result: [PFObject]?, error: NSError?) -> Void in
            
            self.dataSource = result as? [Post] ?? []
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "recordVideo":
                _ = segue.destinationViewController as! RecordViewController
            case "viewAnswers":
                _ = segue.destinationViewController as! AnswersViewController
            default:
                break
            }
        }
    }
}

extension QuestionViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! QuestionTableViewCell
        cell.backgroundColor = UIColor.greenColor()
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
        print("selected row")
        self.performSegueWithIdentifier("viewAnswers", sender: self)
    }
}

extension QuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let post = Post()
        post.title = textField.text
        post.uploadPost()
        textField.resignFirstResponder()
        return true
    }
}

extension QuestionViewController: UIGestureRecognizerDelegate {
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Ended {
            print("gesture worked!")
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let recordAction = UIAlertAction(title: "Record Answer", style: .Default) { (action) in
                self.performSegueWithIdentifier("recordVideo", sender: self)
            }
            alertController.addAction(recordAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}