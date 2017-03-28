//
//  Course+CoreDataProperties.swift
//  Bearcats In Mind
//
//  Created by Sreekanth,Bandaru E on 11/9/16.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Course {

    @NSManaged var avatar: NSData?
    @NSManaged var course_code: String?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var enrollmentType: String?
    @NSManaged var groups: NSSet?
    @NSManaged var sections: NSSet?

}
