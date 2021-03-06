//
//  Enrollment+CoreDataProperties.swift
//  Bearcats In Mind
//
//  Created by Sreekanth,Bandaru on 11/9/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Enrollment {

    @NSManaged var grade: String?
    @NSManaged var type: String?
    @NSManaged var course_section: Section?
    @NSManaged var student: Person?

}
