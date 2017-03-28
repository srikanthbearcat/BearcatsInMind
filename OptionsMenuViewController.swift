//
//  OptionsMenuViewController.swift
//  Bearcats In Mind
//
//  Created by Sreekanth,Bandaru E on 11/11/16.

import UIKit

class OptionsMenuViewController: UIViewController {
    var userPrefs:NSUserDefaults?
    
    @IBOutlet weak var numAnswersLabel: UILabel!
    
    @IBOutlet weak var numAnswerStepper: UIStepper!
    
    @IBOutlet weak var showSectionSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPrefs = NSUserDefaults.standardUserDefaults()
        
        numAnswerStepper.wraps = false
        numAnswerStepper.maximumValue = 10
        numAnswerStepper.minimumValue = 3
        numAnswerStepper.autorepeat = true
        
        let numAnswers:Int = (userPrefs?.integerForKey(UserPrefKeys.NumberOfQuestions.rawValue))!
        let showSection:Bool = (userPrefs?.boolForKey(UserPrefKeys.ShowSectionsIfAvailable.rawValue))!
        
        showSectionSwitch.on = showSection
        numAnswerStepper.value = Double(numAnswers)
        
        numAnswersLabel.text = "\(numAnswers)"
    }
    @IBAction func stepNumAnswers(sender: UIStepper) {
        numAnswersLabel.text = "\(sender.value)"
        userPrefs?.setInteger(Int(sender.value), forKey: UserPrefKeys.NumberOfQuestions.rawValue)
        userPrefs?.synchronize()
    }
    @IBAction func showSectionsChanged(sender: UISwitch) {
        userPrefs?.setBool(sender.on, forKey: UserPrefKeys.ShowSectionsIfAvailable.rawValue)
        userPrefs?.synchronize()
    }
}
