//
//  UpdateNameController.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 11/10/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import UIKit
import Foundation

class UpdateNameController {
    var parent:UIViewController
    var object:AnyObject?
    var viewDimmer:UIView?
    var fadeInTimer:NSTimer?
    var fadeOutTimer:NSTimer?
    
    init (parent:UIViewController) {
        self.parent = parent
        
        let screenRect = UIScreen.mainScreen().bounds
        viewDimmer = UIView.init(frame: screenRect)
        
    }
    
    func showPopup() {
        parent.providesPresentationContextTransitionStyle = true
        parent.definesPresentationContext = true
        
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("updatename") as! UpdateNameModalViewController
        view.object = object
        view.modalPresentationStyle = .OverCurrentContext
        
        viewDimmer?.backgroundColor = UIColor.blackColor()
        viewDimmer?.alpha = 0
        parent.view.addSubview(viewDimmer!)
        
        parent.presentViewController(view, animated: true, completion: nil)
        
        fadeInTimer = NSTimer.init(timeInterval: 0.0125, target: self, selector: #selector(fadeIn), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer((fadeInTimer)!, forMode: NSRunLoopCommonModes)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(popupClosed), name: "presentation-ended", object: nil)
    }
    
    @objc private func fadeIn() {
        if viewDimmer?.alpha < 0.5 {
            viewDimmer?.alpha += 0.025
        } else {
            fadeInTimer!.invalidate()
        }
    }
    
    @objc private func fadeOut() {
        if viewDimmer?.alpha > 0 {
            viewDimmer?.alpha -= 0.025
        } else {
            viewDimmer?.removeFromSuperview()
            fadeOutTimer?.invalidate()
        }
    }
    
    @objc private func popupClosed() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        fadeOutTimer = NSTimer.init(timeInterval: 0.01, target: self, selector: #selector(fadeOut), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(fadeOutTimer!, forMode: NSRunLoopCommonModes)
    }
}
