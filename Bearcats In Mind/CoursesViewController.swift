//
//  ViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/6/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class ClassesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var managedObjectContext:NSManagedObjectContext!
    
    @IBOutlet weak var classTableView: UITableView!
    
    var loadAlert:UIAlertController?
    
    private enum TableViewTags:Int {
        case ImageView = 0, ClassNameLabel, EnrollmentTypeLabel, LastScoreLabel
    }
    
    var fadeInTimer:NSTimer?
    var fadeOutTimer:NSTimer?
    
    var dimView:UIView?
    
    var courses:[Course]?
    
    var popupController:UpdateNameController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CourseDataModeler.createModel()
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let results = fetchCourses()
        if results == nil {
            displayMessage("Could retrieve courses")
        } else if results!.count == 0 {
            loadAlert = UIAlertController(title: "Please wait", message: "Downloading course information", preferredStyle: .Alert)
            self.presentViewController(loadAlert!, animated: true, completion: nil)
            CanvasAPIQuery.fetchCourseJSON()
            courses = []
        } else {
            debugPrint(results)
            courses = results
        }
        navigationItem.title = "Courses"
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let longGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longGR.delegate = self
        classTableView.addGestureRecognizer(longGR)
        
        popupController = UpdateNameController(parent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (courses == nil) ? 0 : (courses?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("class", forIndexPath: indexPath)
        let courseNameLabel:UILabel = cell.viewWithTag(TableViewTags.ClassNameLabel.rawValue) as! UILabel
        let enrollmentTypeLabel:UILabel = cell.viewWithTag(TableViewTags.EnrollmentTypeLabel.rawValue) as! UILabel
        let lastScoreLabel:UILabel = cell.viewWithTag(TableViewTags.LastScoreLabel.rawValue) as! UILabel
        let courseImageView:UIImageView = cell.viewWithTag(4) as! UIImageView
        
        
        courseImageView.layer.borderWidth = 1
        courseImageView.layer.masksToBounds = true
        courseImageView.layer.borderColor = UIColor.blackColor().CGColor
        courseImageView.layer.cornerRadius = courseImageView.frame.height/2
        courseImageView.clipsToBounds = true
        
        let curClass:Course = courses![indexPath.row]
        
        courseNameLabel.text = curClass.name
        enrollmentTypeLabel.text = curClass.enrollmentType
        let average = curClass.getCourseAverage()
        lastScoreLabel.text = (average == 0) ? "-" : "\(average)%"
        courseImageView.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "sections") {
            let viewController:SectionsViewController = segue!.destinationViewController as! SectionsViewController
            let index = classTableView.indexPathForSelectedRow!.row
            viewController.course = courses![index]
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ClassesViewController.reloadTable(_:)), name: "courses-downloaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ClassesViewController.reloadTable(_:)), name: "name-updated", object: nil)
        
        reloadTable()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadTable(ns:NSNotification) {
        reloadTable()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = courses![indexPath.row]
        if (course.enrollmentType == "Student" || !NSUserDefaults.standardUserDefaults().boolForKey(UserPrefKeys.ShowSectionsIfAvailable.rawValue)) {
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("students") as! StudentViewController
            view.caller = .Course
            view.callerObject = course
            self.navigationController?.pushViewController(view, animated: true)
            //TODO - set needed fields
        } else if (course.enrollmentType == "Teacher" || course.enrollmentType == "Teaching Assistant" && NSUserDefaults.standardUserDefaults().boolForKey(UserPrefKeys.ShowSectionsIfAvailable.rawValue)) {
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sections") as! SectionsViewController
            view.course = course
            navigationController?.pushViewController(view, animated: true)
        }
    }
    
    func reloadTable() {
        loadAlert?.dismissViewControllerAnimated(true, completion: nil)
        
        let results = fetchCourses()
        if results == nil {
            displayMessage("Could retrieve courses")
        } else {
            courses = results
            debugPrint(courses)
        }
        
        classTableView.reloadData()
    }
    
    private func fetchCourses() -> [Course]? {
        do {
            let fetchRequest = NSFetchRequest(entityName: "Course")
            let results =  try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
            return results
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
        let p : CGPoint = gr.locationInView(self.classTableView)
        let indexPath = self.classTableView.indexPathForRowAtPoint(p)
        let courseToRename = courses![(indexPath?.row)!]
        if (indexPath == nil) {
            debugPrint("No press")
        } else if (gr.state == UIGestureRecognizerState.Began) {
            popupController?.object = courseToRename
            popupController?.showPopup()
        } else {
            debugPrint(String.init(format: "gesture recognizer state: %ld", gr.state.rawValue))
        }
    }
}

