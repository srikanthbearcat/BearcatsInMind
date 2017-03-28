//
//  MisidentifiedStudentsViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/26/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit

class MisidentifiedStudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var students:[Person]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Misidentified Students"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("student", forIndexPath: indexPath)
        let studentNameLabel:UILabel = cell.viewWithTag(2) as! UILabel
        let studentImageView:UIImageView = cell.viewWithTag(1) as! UIImageView
        
        
        studentImageView.layer.borderWidth = 1
        studentImageView.layer.masksToBounds = true
        studentImageView.layer.borderColor = UIColor.blackColor().CGColor
        studentImageView.layer.cornerRadius = studentImageView.frame.height/2
        studentImageView.clipsToBounds = true
        
        studentNameLabel.text = students[indexPath.row].name
        studentImageView.image = UIImage(data: students[indexPath.row].avatar!)
        
        return cell
    }
    @IBAction func closeQuiz(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.viewControllers.removeAtIndex((self.navigationController?.viewControllers.count)! - 2)
        self.navigationItem.hidesBackButton = true
    }
}
