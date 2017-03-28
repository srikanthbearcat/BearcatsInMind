//
//  ViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/6/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class SectionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var courseName: UILabel!
    
    @IBOutlet weak var sectionTableView: UITableView!
    
    var course:Course!
    
    var managedObjectContext:NSManagedObjectContext!
    
    var loadAlert:UIAlertController?
    
    var popupController:UpdateNameController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sections"
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        popupController = UpdateNameController(parent: self)
        
        let longGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longGR.delegate = self
        sectionTableView.addGestureRecognizer(longGR)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (course.sections == nil) ? 0 : (course.sections?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("section", forIndexPath: indexPath)
        let sectionNameLabel:UILabel = cell.viewWithTag(1) as! UILabel
        let lastScoreLabel:UILabel = cell.viewWithTag(3) as! UILabel
        let section = course.sections?.allObjects[indexPath.row] as! Section
        sectionNameLabel.text = section.name
        lastScoreLabel.text = (section.last_score == nil || section.last_score == 0) ? "-" : "\(section.last_score)"
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "student" {
            let dest:StudentViewController = segue.destinationViewController as! StudentViewController
            let sections = course.sections?.allObjects as! [Section]
            dest.callerObject = sections[(sectionTableView.indexPathForSelectedRow?.row)!]
            dest.caller = .Section
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SectionsViewController.reloadTable(_:)), name: "sections-downloaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SectionsViewController.reloadTable(_:)), name: "name-updated", object: nil)
        if (course.sections == nil || course.sections?.count == 0) {
            loadAlert = UIAlertController(title: "Please wait", message: "Downloading course information", preferredStyle: .Alert)
            self.presentViewController(loadAlert!, animated: true) { () -> Void in
                CanvasAPIQuery.fetchCourseSectionsJSON(self.course.id!)
            }
        }
    }
    
    func reloadTable(ns:NSNotification) {
        debugPrint("Notification received")
        debugPrint("Dismissing alert")
        loadAlert?.dismissViewControllerAnimated(true, completion: nil)
        reloadTable()
    }
    
    func reloadTable() {
        let result = fetchCourse()
        if (result != nil) {
            course = result
        } else {
            displayMessage("Could not retrieve course information")
        }
        sectionTableView.reloadData()
    }
    
    private func fetchCourse() -> Course? {
        do {
            let fetchRequest = NSFetchRequest(entityName: "Course")
            fetchRequest.predicate = NSPredicate(format: "id = %lld", (course.id?.longLongValue)!)
            let results =  try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
            if (results.count == 0) {
                return nil
            } else {
                return results [0]
            }
        } catch _ {
            debugPrint("Yeah, stuff broke....")
        }
        return nil
    }
    
    func displayMessage(message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title:"OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert,animated:true, completion:nil)
    }
    
    @IBAction func handleLongPress(gr:UILongPressGestureRecognizer) {
        let p : CGPoint = gr.locationInView(self.sectionTableView)
        let indexPath = self.sectionTableView.indexPathForRowAtPoint(p)
        let sections = course.sections?.allObjects as! [Section]
        let sectionToRename = sections[(indexPath?.row)!]
        if (indexPath == nil) {
            debugPrint("No press")
        } else if (gr.state == UIGestureRecognizerState.Began) {
            popupController?.object = sectionToRename
            popupController?.showPopup()
        } else {
            debugPrint(String.init(format: "gesture recognizer state: %ld", gr.state.rawValue))
        }
    }
}

