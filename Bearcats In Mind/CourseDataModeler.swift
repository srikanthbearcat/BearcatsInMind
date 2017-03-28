//
//  CourseDataModeler.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/7/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import Foundation
import UIKit

class CourseDataModeler {
    static let model:CourseDataModeler = CourseDataModeler()
    
    static var courses:[Class]!
    
    static var modelCreated = false
    
    static let courseSections = ["iOS":["Section 1", "Section 2", "Section 3"], "Internet of Things":["Section 1"], "Theory & Impl of Prog Langs":["Section 1", "Section 2"]]
    static let enrollmentType:[String] = ["Teaching Assistant", "Student", "Teacher"]
    static let lastScores:[String] = ["55%", "87%", "73%"]
    
    class func createModel() {
        if (modelCreated) {
            return
        }
        let ios1Students:[Student] = [Student(name: "Duncan Dufva"), Student(name: "Corey Ehlers"), Student(name: "Nathaniel Suddarth"), Student(name: "Harish"), Student(name: "Jeevitha"), Student(name: "Vamsy")]
        let ios2Students:[Student] = [Student(name: "Connor Jones"), Student(name: "Ryan Carly"), Student(name: "Filler Student 1"), Student(name: "Filler Student 2"), Student(name: "Want 5 Students")]
        let ios3Students:[Student] = [Student(name: "Darion Higgins"), Student(name: "Kenneth Mott"), Student(name: "Kevin Mott"), Student(name: "Derrick Miller"), Student(name: "Zachary McFerren")]
        
        let iot1Students:[Student] = [Student(name: "Duncan Dufva"), Student(name: "Sandip"), Student(name: "Darion Higgins"), Student(name: "Cher-Xa Thao"), Student(name: "Filler Student 1")]
        
        let theory1Students:[Student] = [Student(name: "Duncan Dufva"), Student(name: "Jamie Ford"), Student(name: "Kenny Mott"), Student(name: "David Bruce"), Student(name: "Who is in this class?")]
        let theory2Students:[Student] = [Student(name: "Corey Ehlers"), Student(name: "Barret Tony"), Student(name: "Connor Jones"), Student(name: "Nathaniel Suddarth"), Student(name: "Ryan Carly")]
        
        let iosSection1 = Section(name:"Section 1", score:50.05, students:ios1Students)
        let iosSection2 = Section(name:"Section 2", score:84.5, students:ios2Students)
        let iosSection3 = Section(name:"Section 3", score:99.3, students:ios3Students)
        
        let iotSection1 = Section(name:"Section 1", score:68.2, students: iot1Students)
        
        let theorySection1 = Section(name: "Section 1", score: 48.28, students: theory1Students)
        let theorySection2 = Section(name: "Section 2", score: 72.5, students: theory2Students)
        
        let ios = Class(name: "Mobile Computing - iOS!", sections: [iosSection1, iosSection2, iosSection3], color: UIColor.redColor(), enrollment: "Teaching Assistant")
        let iot = Class(name: "Internet of Things", sections: [iotSection1], color: UIColor.greenColor(), enrollment: "Student")
        let theory = Class(name: "Theory & Impl of Prog Langs", sections: [theorySection1, theorySection2], color: UIColor.blueColor(), enrollment: "Teacher")
        
        courses = [ios, iot, theory]
        modelCreated = true
    }
    
    class func getCourse(idx:Int) -> Class{
        if idx >= courses.count || idx < 0 {
            return Class()
        }
        
        return courses[idx]
    }
    
    class func getNumCourses() -> Int {
        return courses.count
    }
    
    struct Student {
        var name:String
        init (name:String) {
            self.name = name
        }
    }
    
    struct Class {
        var className, enrollmentType:String
        var sections:[Section]
        var color:UIColor
        
        init (name:String, sections:[Section], color:UIColor, enrollment:String) {
            className = name
            self.sections = sections
            self.color = color
            self.enrollmentType = enrollment
        }
        
        init() {
            self.init(name: "", sections: [], color: UIColor.blackColor(), enrollment: "")
        }
        
        func getAverageScore() -> Double {
            if (sections.count == 1) {
                return sections[0].sectionScore
            }
            
            var sum:Double = 0
            for section in sections {
                sum += section.sectionScore
            }
            
            return sum / Double(sections.count)
        }
    }
    
    struct Section {
        var sectionName:String
        var sectionScore:Double
        var sectionStudents:[Student]
        
        init (name:String, score:Double, students:[Student]) {
            sectionName = name
            sectionScore = score
            sectionStudents = students
        }
    }
}