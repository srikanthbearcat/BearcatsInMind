//
//  UpdateNameModalView.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 11/10/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class UpdateNameModalView: UIView {
    enum ObjectType : Int {
        case Course
        case Section
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    var object:AnyObject?
    
    var managedObjectContext:NSManagedObjectContext?
    
    var target:UIViewController?
    
    var selector:Selector?
    
    @IBOutlet weak var nameTextField : UITextField?
    
    var parent:UpdateNameModalViewController?
    
    @IBAction func save(sender:AnyObject) {
        
        if let name = nameTextField?.text! {
            if object is Course {
                let temp = object as! Course
                temp.name = name
            } else if object is Section {
                let temp = object as! Section
                temp.name = name
            }
            do {
                try managedObjectContext?.save()
            } catch {
                debugPrint("Couldn't save new name. Whoops.")
            }
        }
        dispatch_async(dispatch_get_main_queue()){
            NSNotificationCenter.defaultCenter().postNotificationName("name-updated", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("presentation-ended", object: nil)
        }
        parent!.dismiss()
    }
    
    @IBAction func cancel(sender:AnyObject) {
        dispatch_async(dispatch_get_main_queue()){
            NSNotificationCenter.defaultCenter().postNotificationName("presentation-ended", object: nil)
        }
        parent!.dismiss()
    }
    
    func getName(object:AnyObject) -> String{
        return (object is Course) ? (object as! Course).name! : (object as! Section).name!
    }
}
