//
//  Person+CoreDataProperties.swift
//  Bearcats In Mind
//
//  Created by Dufva,Duncan E on 11/9/16.
//  Copyright © 2016 Dufva,Duncan E. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var avatar: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var course_enrollments: NSSet?
    @NSManaged var groups: NSSet?

}
