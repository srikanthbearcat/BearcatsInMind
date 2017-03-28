//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var access_key: String?
    @NSManaged var id: NSNumber?

}
