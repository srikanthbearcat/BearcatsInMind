//
//  ViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/6/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class StudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    /*
        The label that display's the courses name
    */
    @IBOutlet weak var courseName: UILabel!
    
    /*
        Outlet for the TableView so we can reload data.
    */
    @IBOutlet weak var studentsTableView: UITableView!
    
    /*
        Data source for studentsTableView
    */
    var students:[Person]?
    
    /*
        Defines what view the StudentViewController is presented from.
    */
    var caller:Caller?
    
    /*
        Using AnyObject to store the caller's data.
        As of right now, it can be either a Course or Section
    */
    var callerObject:AnyObject?
    
    /*
        Used to retrieve objects from CoreData
    */
    var managedObjectContext:NSManagedObjectContext!
    
    /*
        The Alert displayed while information is being downloaded through the canvas API.
    */
    var loadAlert:UIAlertController!
    
    /*
        Used as a download queue - sections are removed as they are downloaded from the API.
    */
    var sectionDownloadQueue:[Section]?
    
    // MARK: ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Default navigation title. Should set this to something at some point.
        navigationItem.title = "Students"
        //Retrieving NSManagedObjectContext - should this be retrieved from CanvasAPIQuery instead? idk
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (students == nil) ? 0 : (students?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        let student:Person = students![indexPath.row]
        
        cell = tableView.dequeueReusableCellWithIdentifier("student", forIndexPath: indexPath)
        let studentImageView:UIImageView = cell.viewWithTag(1) as! UIImageView
        let studentNameLabel:UILabel = cell.viewWithTag(2) as! UILabel
        
        studentNameLabel.text = student.name
        studentImageView.image = UIImage(data: student.avatar!)
        
        return cell
    }
    
    /*
        Reloads the TableView to show changed information.
        To get here, we must have called something from the API.
    */
    func reloadTable() {
        //Shut the alert so the user can interact with the view
        loadAlert.dismissViewControllerAnimated(true, completion: nil)
        let result = fetchInfo() //retrieve the new data from CoreData
        if result == nil {
            displayMessage("Could not load data")
        } else {
            callerObject = result //store updated data where original callerObject was
            students = getPeople() //get array of students to be shown in array
        }
        studentsTableView.reloadData() //actually reloading the table
    }
    
    // MARK: ViewController Presentation Methods
    
    /*
        Called when the view is being removed from the navigation stack
    */
    override func viewWillDisappear(animated: Bool) {
        //If the view is no longer active, we no longer need to receive notifications
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
        Called when the view is about to be shown
        This is where we do all of our logic to load data.
    */
    override func viewWillAppear(animated: Bool) {
        //Subscribe to this method to receive notifications for when students have been downloaded
        //from the canvas API
        
        //If the view was presented from the CourseViewController
        if caller == Caller.Course {
            let data = callerObject as! Course //Cast data to the correct type
            if (data.sections?.count == 0) { //if we do not have any data for the course, download it
                //every course will have at least 1 section. '-' you just may not see it
                if data.enrollmentType == "Teacher" || data.enrollmentType == "Teaching Assistant" { //if you have access to sections, download all sections first
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sectionsReceived(_:)), name: "sections-downloaded", object: nil)
                    CanvasAPIQuery.fetchCourseSectionsJSON(data.id!)
                } else if data.enrollmentType == "Student" { //downloading sections is buggy if you're a student, so default to downloading all students for course
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTable(_:)), name: "course-students-downloaded", object: nil) //so that we can retrieve students from the course
                    CanvasAPIQuery.fetchCourseUsersJSON(data.id!)
                }
                showDownloadPopup()
            } else {
                students = getPeople()
            }
        } else if caller == Caller.Section { //if from section, assume you're a teacher
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentViewController.reloadTable(_:)), name: "students-downloaded", object: nil)
            let data = callerObject as! Section
            if (data.enrollments == nil || data.enrollments?.count == 0) { //if we have not downloaded students yet
                //download them
                CanvasAPIQuery.fetchSectionUsersJSON((data.parent_class?.id)!, sectionID: data.id!)
                showDownloadPopup()
            } else {
                students = getPeople()
            }
        }

    }
    
    // TODO: Fix this....and update QuizScreenViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "quiz" {
            let dest:QuizScreenViewController = segue.destinationViewController as! QuizScreenViewController
            dest.caller = caller
            dest.callerObject = callerObject
            
        }
    }
    
    // TODO: Make a controller for this.
    
    /*
        Creates an alert with no confirm/close button. 
        The user cannot interact with anything until it is closed.
    */
    private func showDownloadPopup() {
        loadAlert = UIAlertController(title: "Please wait", message: "Downloading users for this section", preferredStyle: .Alert)
        presentViewController(loadAlert, animated: true, completion: nil)
    }
    

    
    // MARK: JSON Callback Methods
    
    /*
        Reloads the TableView's data upon receiving a notification.
     
        - Parameter ns: The NSNotification received.
    */
    func reloadTable(ns:NSNotification) {
        reloadTable()
    }
    
    /*
        Called once sections for a course are downloaded.
 
        Should only be called if the user is enrolled as a Teaching Assistant or Teacher
        and has not previously downloaded information for the current course.
 
        - Parameter ns: The NSNotification received. 
    */
    func sectionsReceived(ns:NSNotification) {
        do {
            //Fetch the Course by using the previously-stored Course's ID
            let fetchRequest = NSFetchRequest(entityName: "Course")
            fetchRequest.predicate = NSPredicate(format: "id = %lld", ((callerObject as! Course).id?.longLongValue)!)
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
            let course = results[0]
            callerObject = course
            //Download queue is used to download all sections of a course
            sectionDownloadQueue = (course.sections?.allObjects as! [Section])
            //routing students-downloaded event to sectionStudentsReceived so that the queue works properly
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sectionStudentsReceived(_:)), name: "students-downloaded", object: nil)
            CanvasAPIQuery.fetchSectionUsersJSON(course.id!, sectionID: sectionDownloadQueue![(sectionDownloadQueue?.count)! - 1].id!)
            sectionDownloadQueue?.removeLast()
        } catch _ {
            debugPrint("messed up again")
        }
    }
    
    
    /*
        Called once students for a specific section are received.
 
        Used in conjunction with sectionsRecieved to create a download queue of sections
        Forces view to download students of all sections before allowing the user to interact with the view.
 
        - Parameter ns: The NSNotification received.
    */
    func sectionStudentsReceived(ns:NSNotification) {
        if (sectionDownloadQueue?.count == 0) { //if the queue is empty
            students = getPeople() //get all of the students for display
            reloadTable()
        } else { //Keep downloading students
            CanvasAPIQuery.fetchSectionUsersJSON((callerObject as! Course).id!, sectionID: sectionDownloadQueue![(sectionDownloadQueue?.count)! - 1].id!)
            sectionDownloadQueue?.removeLast()
        }
    }
    
    // MARK: CoreData Functionality
    
    /*
        Retrieves updated information from CoreData
     
        - Returns: updated information from CoreData
    */
    private func fetchInfo() -> AnyObject? {
        if caller == Caller.Course { //fetch course if course
            return fetchCourse()
        } else if caller == Caller.Section { //otherwise fetch section if section
            return fetchSection()
        }
        
        return nil //if we're here, something has gone horribly wrong
    }
    
    /*
        Retrieves an updated version of the current section from CoreData.
 
        Makes use of callerObject (casted to a Section).
 
        - Returns: the updated section
    */
    private func fetchSection() -> Section? {
        do {
            //Retrieving the section
            let fetchRequest = NSFetchRequest(entityName: "Section") //using current id to search
            fetchRequest.predicate = NSPredicate(format: "id = %lld", ((callerObject as! Section).id?.longLongValue)!)
            let results =  try managedObjectContext.executeFetchRequest(fetchRequest) as! [Section]
            if (results.count == 0) { //if no results, something has gone horribly wrong
                return nil
            } else if results.count == 1{ //should have only 1 result
                return results[0]
            }
        } catch _ {
            debugPrint("Yeah, stuff broke....")
        }
        return nil //something has gone horribly wrong if we get here.
    }
    
    /*
     Retrieves an updated version of the current course from CoreData.
     
     Makes use of callerObject (casted to a Course).
     
     - Returns: the updated course
     */
    private func fetchCourse() -> Course? {
        do {
            //Retrieving the course
            let fetchRequest = NSFetchRequest(entityName: "Course") //using current id to search
            fetchRequest.predicate = NSPredicate(format: "id = %lld", ((callerObject as! Course).id?.longLongValue)!)
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
            if (results.count == 0) { //if no results, something has gone horribly wrong
                return nil
            } else if results.count == 1{ //should only have 1 result
                return results[0]
            }
        } catch _ {
            debugPrint("Yeah, stuff broke....")
        }
        return nil //something has gone horribly wrong if we get here
    }
    
    // MARK: Utility
    
    /*
        Creates a list of all the current students in the current Course or Section.
        
        - Returns: A list of all students.
    */
    private func getPeople() -> [Person] {
        var people:[Person] = []
        if (caller == Caller.Course) { //if we're presenting from a course
            for section in ((callerObject as! Course).sections?.allObjects as! [Section]) {
                people.appendContentsOf(getSectionStudents(section)) //Append users of each section to people
            }
        } else if (caller == Caller.Section) { //if we're presenting from a section
            people = getSectionStudents(callerObject as! Section) //set people to users of section
        }
        
        return people
    }
    
    /*
        Creates a list of the students in a Section
    
        - Returns: A list of the section's students
    */
    private func getSectionStudents(section:Section) -> [Person] {
        var people:[Person] = []
        let enrollments = section.enrollments?.allObjects as! [Enrollment]
        for enrollment in enrollments { //go through all enrollments
            people.append(enrollment.student!) //and add each student to people
        }
        return people
    }
    
    /*
        Displays a message when things go wrong.
    */
    func displayMessage(message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title:"OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert,animated:true, completion:nil)
    }
}