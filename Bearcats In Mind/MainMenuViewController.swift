//
//  ViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 10/6/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class MainMenuViewController: UIViewController {
    
    var managedObjectContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        navigationItem.title = "Main Menu"
        let fetchRequest = NSFetchRequest(entityName: "User")
        var users:[User]
        do {
            try users = managedObjectContext.executeFetchRequest(fetchRequest) as! [User]
            if (users.count == 0) {
                //logic to do login procedures - not implemented yet.
            }
        } catch {
            debugPrint("Could not retrieve users.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayMessage(message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title:"OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert,animated:true, completion:nil)
    }
    
    @IBAction func groupsSelected(sender: AnyObject) {
        displayMessage("Sorry, this feature has been disabled until further notice!")
    }
}

