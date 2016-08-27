//
//  Contact+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/27/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var contactId: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var chats: NSSet?
    @NSManaged var messages: NSSet?
    @NSManaged var phoneNumbers: NSSet?

}
