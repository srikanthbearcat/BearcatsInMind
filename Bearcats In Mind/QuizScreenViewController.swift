//
//  QuizScreenViewController.swift
//  Bearcats In Mind
//
//  Created by Bandaru,Sreekanth on 10/7/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class QuizScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var answerImageView: UIImageView!
 
    var caller:Caller!
    var callerObject:AnyObject!
    var sectionMap:[Person:Section] = [:]
    var sections:[Section] = []
    var sectionScores:[Section:Int] = [:]
    var answers:[Person] = []
    var incorrectAnswers:[Person] = []
    var shuffledAnswersOrder:[Int]! //The order in which to pick students from the
    let NUM_ANSWERS:Int = NSUserDefaults.standardUserDefaults().integerForKey(UserPrefKeys.NumberOfQuestions.rawValue)
    var correctAnswerIndex:Int = -1 //The index in answers which stores the correct student's name
    var hasAnswered = false;
    var students:[Person] = []
    
    var managedObjectContext:NSManagedObjectContext?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NUM_ANSWERS
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("student_cell", forIndexPath: indexPath)
        cell.textLabel?.text = answers[indexPath.row].name
        
        if (hasAnswered) {
            if (indexPath.row == correctAnswerIndex) {
                cell.contentView.backgroundColor = UIColor.greenColor()
            } else {
                cell.contentView.backgroundColor = UIColor.redColor()
            }
        } else {
            cell.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != correctAnswerIndex && !hasAnswered) {
            let person = students[shuffledAnswersOrder[0]]
            let section = sectionMap[person]
            sectionScores[section!]! -= 1
            incorrectAnswers.append(students[shuffledAnswersOrder[0]])
        }
        hasAnswered = true
        answerTableView.reloadData()
    }
    
    @IBAction func nextPerson(sender: AnyObject) {
        shuffledAnswersOrder.removeFirst() //Remove the previous 'answer' index to get a new student from 'students'
        if (shuffledAnswersOrder.count == 0) {
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("misidentified_students") as! MisidentifiedStudentsViewController
            saveQuizResults()
            vc.students = incorrectAnswers
            // TODO: Add caller.
            self.navigationController?.pushViewController(vc, animated:true)
        } else {
            hasAnswered = false
            getNextAnswerSet()
            answerTableView.reloadData()
        }
    }
    
    private func getSections(caller:Caller, data:AnyObject) -> [Section]{
        if caller == Caller.Course {
            return ((data as! Course).sections?.allObjects as! [Section])
        } else {
            return [data as! Section]
        }
    }
    
    private func getSectionStudents(section:Section) -> [Person]{
        var users:[Person] = []
        let enrollments = section.enrollments?.allObjects as! [Enrollment]
        for enrollment in enrollments {
            users.append(enrollment.student!)
        }
        return users
    }
    
    private func saveQuizResults() {
        for section in sections {
            let score:Double = Double(sectionScores[section]!) / Double((section.enrollments?.count)!)
            section.last_score = score
        }
        do {
            try managedObjectContext?.save()
        } catch _ {
            debugPrint("Clould not save results.")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        sections = getSections(caller, data: callerObject)
        for section in sections {
            let people:[Person] = getSectionStudents(section)
            for person in people {
                sectionMap[person] = section
            }
            sectionScores[section] = people.count
            students.appendContentsOf(people)
        }
        
        shuffledAnswersOrder = []
        for i in 0 ..< students.count {
            shuffledAnswersOrder.append(i)
        }
        
        for i in 0 ..< students.count {
            let select = Int(rand()) % (students.count - i)
            let tempNum = shuffledAnswersOrder[select]
            shuffledAnswersOrder[select] = shuffledAnswersOrder[i]
            shuffledAnswersOrder[i] = tempNum
        }
        getNextAnswerSet()
        
    }
    
    func getNextAnswerSet() {
        answerImageView.image = UIImage(data: students[shuffledAnswersOrder[0]].avatar!)
        correctAnswerIndex = Int(rand()) % NUM_ANSWERS //Pick which value in the answers will be the correct answer
        answers = [] //new empty array of student objects to use as answers
        var usedIndexes = [shuffledAnswersOrder[0]] //cannot use correct answer twice
        for i in 0 ..< NUM_ANSWERS { //for the number of answers in the table, select a student as the answer
            if (i == correctAnswerIndex) { //if on correct answer slot, insert correct answer
                answers.append(students[shuffledAnswersOrder[0]])
                continue //restart loop
            } //otherwise try to find a student that isn't the correct answer and hasn't been used yet
            var randomStudentIndex = shuffledAnswersOrder[0]
            while (usedIndexes.contains{$0 == randomStudentIndex}) { //while the student has already been included in the answers
                randomStudentIndex = Int(rand()) % students.count //randomly select a student from the 'students' array
            }
            answers.append(students[randomStudentIndex]) //add student to answers
            usedIndexes.append(randomStudentIndex) //make it so that we cannot select the same student again
        }
    }
}