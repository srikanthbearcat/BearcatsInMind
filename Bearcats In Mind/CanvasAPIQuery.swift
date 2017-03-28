////
////  CanvasAPIQuery.swift
////  Bearcats In Mind
////
////  Created by Dufva,Duncan E on 10/24/16.
////  Copyright © 2016 Dufva,Duncan E. All rights reserved.
////

import Foundation
import UIKit
import CoreData

class CanvasAPIQuery {
    //The NSManagedObjectContex that will allow us to fetch and save objects from CoreData
    static var managedObjectContext:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //This is only for development purposes, it will be removed in the actual implementation
    static let fAccessToken = "7438~XXriNJJH4YKzFxs7gsX6AJCrlKMDzF51gh7668t2CWVhOCYYjs9DmBfjW1zutXJ0"
    
    //Used to verify section selection for view controllers...I think.
    //I really need to figure out why I made this.
    static var fActiveSection:NSNumber?
    
    /*
        Used for downloading users for a single course. As the API method does not return the ID of the queried class, we need to do this so that we can retrieve the Course object from CoreData.
     
        A bit inconvenient, but it works.
     */
    static var fActiveCourse:NSNumber?
    
    /*
        Queries the Canvas LMS API to get all of the courses the user is enrolled in.
        Calls the processCourseResults method.
    */
    class func fetchCourseJSON(){
        let url = "https://canvas.instructure.com/api/v1/courses?access_token=\(fAccessToken)&include[]=image_url"
        let session:NSURLSession = NSURLSession.sharedSession()
        session.dataTaskWithURL( NSURL(string: url)!, completionHandler: processCourseResults).resume()
    }
    
    /*
        Queries the Canvas LMS API to get all of the sections for a specified course.
        Calls the processSectionResults method.
    
        - Parameter courseID: The ID if the course to retrieve sections for
    */
    class func fetchCourseSectionsJSON(courseID:NSNumber) {
        let url = "https://canvas.instructure.com/api/v1/courses/\(courseID)/sections?access_token=\(fAccessToken)"
        let session:NSURLSession = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: url)!, completionHandler: processSectionResults).resume()
    }
    
    /*
        Queries the Canvas LMS API to get all of the groups the user is a member of.
        Calls the processGroupResults method.
    */
    class func fetchUserGroupsJSON() {
        let url = "https://canvas.instructure.com/api/v1/users/self/groups?access_token=\(fAccessToken)"
        let session:NSURLSession = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: url)!, completionHandler: processGroupResults).resume()
    }

    /*
        Queries the Canvas LMS API to get the users for a specific section of a course.
        Calls the processStudentResults method.
        
        - Parameter courseID: The ID of the course you wish to retrieve users from
        - Parameter sectionID: The ID of the section for the course
    */
    class func fetchSectionUsersJSON(courseID:NSNumber, sectionID:NSNumber) {
        fActiveSection = sectionID
        let url = "https://canvas.instructure.com/api/v1/courses/\(courseID)/sections/\(sectionID)?access_token=\(fAccessToken)&include[]=students&include[]=avatar_url&limit=500" //likely incorrect
        debugPrint(url)
        let session:NSURLSession = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: url)!, completionHandler: processStudentResults).resume()
        debugPrint("Retrieving data")
    }
    
    /*
     Queries the Canvas LMS API to get the users for a specific course.
     Calls the processCourseStudentResults method.
     
     A default section for the course will be created. Students will be stored within it.
     
     - Parameter courseID: The ID of the course you wish to retrieve users from
     */
    class func fetchCourseUsersJSON(courseID:NSNumber) {
        fActiveCourse = courseID
        let url = "https://canvas.instructure.com/api/v1/courses/\(courseID)/search_users?access_token=\(fAccessToken)&include[]=avatar_url&limit=500" //likely incorrect
        debugPrint(url)
        let session:NSURLSession = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: url)!, completionHandler: processCourseStudentResults).resume()
        debugPrint("Retrieving data")
    }

    /*
        Processes data retrieved from the Canvas LMS API to add courses to CoreData.
        Called by fetchCourseJSON.
 
        Posts the "courses-downloaded" notification so that data can be reloaded in relevant views.
 
        - Parameter data: The JSON data retrieved
        - Parameter response: The response from the webserver
        - Parameter error: Errors thrown, if any
    */
    private class func processCourseResults(data:NSData?,response:NSURLResponse?,error:NSError?)->Void {
        var courseJSON:[AnyObject]! //Object to store parsed JSON in. (Data returned in Array format)
        do { //Parsing info (or trying to...)
            try courseJSON = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            for course in courseJSON { //For each course we retrieved
                //Create a new entity to save
                let courseEntity = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as! Course
                //Add the required fields
                courseEntity.name = course["name"] as? String
                courseEntity.id = course["id"] as? NSNumber
                courseEntity.course_code = course["course_code"] as? String
                let enrollmentObject = (course["enrollments"] as! NSArray)[0]
                let enrollmentRole = enrollmentObject["role"] as! String
                let enrollmentType = enrollmentObject["type"] as! String
                if enrollmentType == "student" {
                    courseEntity.enrollmentType = "Student"
                } else if enrollmentType == "teacher" {
                    if enrollmentRole.lowercaseString == "co-teacher" {
                        courseEntity.enrollmentType = "Teaching Assistant"
                    } else {
                        courseEntity.enrollmentType = "Teacher"
                    }
                }
            }

            //Try to save info
            try managedObjectContext.save()

            dispatch_async(dispatch_get_main_queue()){ //Posting the notification so information can be updated in relevant view controllers
                NSNotificationCenter.defaultCenter().postNotificationName("courses-downloaded", object: nil)
            }
        } catch {
            debugPrint("Couldn't download JSON - things broke.")
        }
    }

    /*
     Processes data retrieved from the Canvas LMS API to add Person and Enrollment objects to CoreData
     Called by fetchSectionUsersJSON.
     
     Posts the "courses-downloaded" notification so that data can be reloaded in relevant views.
     
     - Parameter data: The JSON data retrieved
     - Parameter response: The response from the webserver
     - Parameter error: Errors thrown, if any
     */
    private class func processStudentResults(data:NSData?,response:NSURLResponse?,error:NSError?)->Void {
        debugPrint("Processing")
        var sectionJSON:AnyObject!
        do {
            try sectionJSON = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            debugPrint(sectionJSON)
            var fetchRequest = NSFetchRequest(entityName: "Section")
            fetchRequest.predicate = NSPredicate(format: "id = %lld", (sectionJSON["id"] as? NSNumber)!.longLongValue)
            let sectionResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Section]
            let activeSection = sectionResults[0]

            let students = sectionJSON["students"] as! NSArray //Get the student array and convert it to an NSArray so we can iterate over it
            for student in students {
                debugPrint(student["name"])
                        //First, see if the current student already exists within CoreData
                fetchRequest = NSFetchRequest(entityName: "Person") //Make a search that checks for ID
                fetchRequest.predicate = NSPredicate(format: "id = %lld", (student["id"] as? NSNumber)!.longLongValue)
                let studentResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Person]
                var studentEntity:Person!
                if (studentResults.count < 1) { //If there is no person, make one
                    studentEntity = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: managedObjectContext) as! Person
                            //And set all required parameters
                    let userImage = downloadImage(student["avatar_url"] as! String) //Get url of avatar and download it
                    if (userImage != nil) {
                        studentEntity.avatar = UIImagePNGRepresentation(userImage!) //convert image to NSData to store in CoreData
                    }
                    studentEntity.id = student["id"] as? NSNumber //Other required fields - id & name
                    studentEntity.name = student["name"] as? String
                } else {
                    studentEntity = studentResults[0] //otherwise, the student already exists, so we use them
                }
                        
                        //Create our NSManagedObjectEntity to save in CoreData (for Enrollment)
                let enrollmentEntity = NSEntityDescription.insertNewObjectForEntityForName("Enrollment", inManagedObjectContext: managedObjectContext) as! Enrollment
                enrollmentEntity.student = studentEntity //Set the associated student
                enrollmentEntity.course_section = activeSection //Set the associated section
                enrollmentEntity.grade = "" //No grade for now
                //TODO: Implement enrollment type (perhaps as a field of Course, as they're all Courses the user is enrolled in).
                        
                //Adding the enrollment to both our Student and Section entity
                studentEntity.course_enrollments = studentEntity.course_enrollments?.setByAddingObject(enrollmentEntity)
                activeSection.enrollments = activeSection.enrollments?.setByAddingObject(enrollmentEntity)
                    }

            
            try managedObjectContext.save() //Save all of our new information.
            
            //Send a notification back to the Student View Controller so that it can reload its data
            dispatch_async(dispatch_get_main_queue()){
                debugPrint("LIGHTING THE BEACON.")
                NSNotificationCenter.defaultCenter().postNotificationName("students-downloaded", object: nil)
            }
        } catch {
            debugPrint("Couldn't download JSON - things broke.")
        }
    }
    
    /*
     Processes data retrieved from the Canvas LMS API to add Person and Enrollment objects to CoreData
     Called by fetchCourseUsersJSON.
     
     Posts the "course-students-downloaded" notification so that data can be reloaded in relevant views.
     
     - Parameter data: The JSON data retrieved
     - Parameter response: The response from the webserver
     - Parameter error: Errors thrown, if any
     */
    private class func processCourseStudentResults(data:NSData?,response:NSURLResponse?,error:NSError?)->Void {
        //TODO: REWORK THIS METHOD. I HAVE TO GO TO CLASS NOW.
        debugPrint("Processing")
        var students:NSArray!
        do {
            //First, parse our JSON
            try students = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            debugPrint(students) //For debug purposes until it is fully implemented
            //Get the course associated with it (if it does not exist at this time, something has gone horribly wrong.
            var fetchRequest = NSFetchRequest(entityName: "Course")
            fetchRequest.predicate = NSPredicate(format: "id = %lld", fActiveCourse!.longLongValue)
            let courseResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
            let activeCourse = courseResults[0]
            
            var defaultSection:Section
            //If we have no default section, make one
            if activeCourse.sections?.count == 0 {
                defaultSection = NSEntityDescription.insertNewObjectForEntityForName("Section", inManagedObjectContext: managedObjectContext) as! Section //Inserting new section into CoreData
                defaultSection.name = "Default Section" //Default name
                //This should be okay, because we'll never be directly searching for these default sections.
                //but...
                //TODO: ensure unique id creation.
                defaultSection.id = 0
                defaultSection.parent_class = activeCourse
                defaultSection.section_code = "01"
                
                activeCourse.sections = activeCourse.sections?.setByAddingObject(defaultSection)
            } else {
                defaultSection = (activeCourse.sections?.allObjects[0])! as! Section
            }//Get the student array and convert it to an NSArray so we can iterate over it
            for student in students {
                debugPrint(student["name"])
                //First, see if the current student already exists within CoreData
                fetchRequest = NSFetchRequest(entityName: "Person") //Make a search that checks for ID
                fetchRequest.predicate = NSPredicate(format: "id = %lld", (student["id"] as? NSNumber)!.longLongValue)
                let studentResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Person]
                var studentEntity:Person
                if (studentResults.count < 1) { //If there is no person, make one
                    studentEntity = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: managedObjectContext) as! Person
                    //And set all required parameters
                    let userImage = downloadImage(student["avatar_url"] as! String) //Get url of avatar and download it
                    if (userImage != nil) {
                        studentEntity.avatar = UIImagePNGRepresentation(userImage!) //convert image to NSData to store in CoreData
                    }
                    studentEntity.id = student["id"] as? NSNumber //Other required fields - id & name
                    studentEntity.name = student["name"] as? String
                } else {
                    studentEntity = studentResults[0] //otherwise, the student already exists, so we use them
                }
                
                //Create our NSManagedObjectEntity to save in CoreData (for Enrollment)
                let enrollmentEntity = NSEntityDescription.insertNewObjectForEntityForName("Enrollment", inManagedObjectContext: managedObjectContext) as! Enrollment
                enrollmentEntity.student = studentEntity //Set the associated student
                enrollmentEntity.course_section = defaultSection //Set the associated section
                //TODO: Implement enrollment type (perhaps as a field of Course, as they're all Courses the user is enrolled in).
                
                //Adding the enrollment to both our Student and Section entity
                studentEntity.course_enrollments = studentEntity.course_enrollments?.setByAddingObject(enrollmentEntity)
                defaultSection.enrollments = defaultSection.enrollments?.setByAddingObject(enrollmentEntity)
            }
            
            
            try managedObjectContext.save() //Save all of our new information.
            
            //Send a notification back to the Student View Controller so that it can reload its data
            dispatch_async(dispatch_get_main_queue()){
                debugPrint("LIGHTING THE BEACON.")
                NSNotificationCenter.defaultCenter().postNotificationName("course-students-downloaded", object: nil)
            }
        } catch {
            debugPrint("Couldn't download JSON - things broke.")
        }
    }
    
    /*
     Processes data retrieved from the Canvas LMS API to add sections to CoreData.
     Called by fetchCourseSectionsJSON.
     
     Posts the "courses-downloaded" notification so that data can be reloaded in relevant views.
     
     - Parameter data: The JSON data retrieved
     - Parameter response: The response from the webserver
     - Parameter error: Errors thrown, if any
     */
    private class func processSectionResults(data:NSData?,response:NSURLResponse?,error:NSError?)->Void {
        var sectionJSON:[AnyObject]!
        do {
            debugPrint("Received data")
            //Try to parse the JSON
            try sectionJSON = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            for section in sectionJSON { //Go through each section (as it's returned in an array
                debugPrint(section)
                //And create a new entity to store info in
                let sectionEntity:Section = NSEntityDescription.insertNewObjectForEntityForName("Section", inManagedObjectContext: managedObjectContext) as! Section
                //Then store the required fields
                sectionEntity.name = section["name"] as? String
                sectionEntity.id = section["id"] as? NSNumber
                sectionEntity.last_score = 0.0
                
                //Fetching the Course associated with this section.
                let courseID = section["course_id"] as? NSNumber
                let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Course")
                fetchRequest.predicate = NSPredicate(format: "id == %lld", (courseID?.longLongValue)!)
                var courses:[Course]!
                try courses = managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
                if courses.count == 1 {
                    debugPrint("Links between course and section created")
                    sectionEntity.parent_class = courses[0]
                    courses[0].sections = courses[0].sections?.setByAddingObject(sectionEntity)
                }
            }
            
            try managedObjectContext.save()
            
            dispatch_async(dispatch_get_main_queue()){
                debugPrint("notification posted")
                NSNotificationCenter.defaultCenter().postNotificationName("sections-downloaded", object: nil)
            }
        } catch {
            debugPrint("Couldn't download JSON - things broke.")
        }
    }

    /*
     Processes data retrieved from the Canvas LMS API to add sections to CoreData.
     Called by fetchUserGroupsJSON.
     
     COURSE DATA MUST BE DOWNLOADED PRIOR TO THIS, OTHERWISE THINGS WILL BREAK.
     
     Posts the "courses-downloaded" notification so that data can be reloaded in relevant views.
     
     - Parameter data: The JSON data retrieved
     - Parameter response: The response from the webserver
     - Parameter error: Errors thrown, if any
     */
    private class func processGroupResults(data:NSData?,response:NSURLResponse?,error:NSError?)->Void {
        var groupJSON:[AnyObject]!
        do {
            try groupJSON = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [AnyObject]
            for group in groupJSON {
                let groupEntity = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: managedObjectContext) as! Group
                groupEntity.name = group["name"] as? String
                groupEntity.last_score = 0.0
                groupEntity.id = group["id"] as? NSNumber
                let fetchRequest = NSFetchRequest(entityName: "Course")
                fetchRequest.predicate = NSPredicate(format: "id = %@", (group["course_id"] as? NSNumber)!)
                let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Course]
                let activeCourse = results[0]
                groupEntity.parent_course = activeCourse
                activeCourse.groups = activeCourse.groups?.setByAddingObject(groupEntity)
            }
            
            try managedObjectContext.save()
            
            dispatch_async(dispatch_get_main_queue()){
                NSNotificationCenter.defaultCenter().postNotificationName("groups-downloaded", object: nil)
            }
        } catch {
            debugPrint("Couldn't download JSON - things broke")
        }
    }
    
    private class func downloadImage(url:String) -> UIImage?{
        let url = NSURL(string: url)
        let data = NSData(contentsOfURL:url!)
        if data != nil {
            return UIImage(data:data!)
        }
        return nil
    }
}
