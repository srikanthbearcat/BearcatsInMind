//
//  Section+CoreDataProperties.swift
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

extension Section {

    @NSManaged var id: NSNumber?
    @NSManaged var last_score: NSNumber?
    @NSManaged var name: String?
    @NSManaged var section_code: String?
    @NSManaged var enrollments: NSSet?
    @NSManaged var parent_class: Course?

}
