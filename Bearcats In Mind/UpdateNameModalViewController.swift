//
//  UpdateNameModalViewController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 11/10/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import CoreData

class UpdateNameModalViewController: UIViewController {

    @IBOutlet weak var popup:UpdateNameModalView?
    
    var object:AnyObject?
    
    enum ObjectType : Int {
        case Course
        case Section
    }
    
    var selector:Selector?
    
    func drawRect(rect: CGRect) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        popup?.object = object
        popup?.parent = self
        popup?.nameTextField?.text = getName(object!)
    }
    
    func getName(object:AnyObject) -> String{
        return (object is Course) ? (object as! Course).name! : (object as! Section).name!
    }
    
    override func viewWillLayoutSubviews() {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        view.layer.borderColor = UIColor.grayColor().CGColor
        view.layer.borderWidth = 0.5
        
        view.clipsToBounds = false
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
