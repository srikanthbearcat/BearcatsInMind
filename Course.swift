//
//  Course.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 11/9/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//

import Foundation
import CoreData


class Course: NSManagedObject {

    func getCourseAverage() -> Int{
        if self.sections == nil || self.sections?.count == 0 {
            return 0
        } else {
            var sum:Double = 0
            for i in 0 ..< (sections?.count)! {
                let section = sections!.allObjects[i] as! Section
                sum += section.last_score as! Double
            }
            return Int((sum / Double((sections?.count)!)) * 100)
        }
    }

}
