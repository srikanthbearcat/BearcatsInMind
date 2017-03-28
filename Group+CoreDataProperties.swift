//
//  Group+CoreDataProperties.swift
//  Bearcats In Mind
//
//  Created by Sreekanth,Bandaru E on 11/9/16.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Group {

    @NSManaged var id: NSNumber?
    @NSManaged var last_score: NSNumber?
    @NSManaged var name: String?
    @NSManaged var members: NSSet?
    @NSManaged var parent_course: Course?

}
