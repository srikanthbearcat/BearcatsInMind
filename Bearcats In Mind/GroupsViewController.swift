//
//  ViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/6/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Groups"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 //not finished
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("group", forIndexPath: indexPath)
        let courseNameLabel:UILabel = cell.viewWithTag(3) as! UILabel
        let groupNameLabel:UILabel = cell.viewWithTag(2) as! UILabel
        let lastScoreLabel:UILabel = cell.viewWithTag(4) as! UILabel
        let courseImageView:UIImageView = cell.viewWithTag(1) as! UIImageView
        
        
        courseImageView.layer.borderWidth = 1
        courseImageView.layer.masksToBounds = true
        courseImageView.layer.borderColor = UIColor.blackColor().CGColor
        courseImageView.layer.cornerRadius = courseImageView.frame.height/2
        courseImageView.clipsToBounds = true
        
        courseNameLabel.text = "Course Name"
        groupNameLabel.text = "Group Name"
        lastScoreLabel.text = "100%"
        courseImageView.backgroundColor = CourseDataModeler.getCourse(indexPath.row).color
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "student" {
            //KINDA BROKEN RIGHT NOW - WE WERE TRYING TO IMPLEMENT COREDATA AND HAVE NOT FINISHED YET
            let dest:StudentViewController = segue.destinationViewController as! StudentViewController
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GroupsViewController.reloadTable(_:)), name: "groups-downloaded", object: nil)
    }
    
    func reloadTable(ns:NSNotification) {
        groupTableView.reloadData()
    }
}

