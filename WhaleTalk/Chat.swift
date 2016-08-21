//
//  Chat.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/21/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData


class Chat: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    var lastMessage: Message? {
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        do {
            guard let results = try self.managedObjectContext?.executeFetchRequest(request) as? [Message] else { return nil }
            return results.first
        } catch {
            print("Error for request")
        }
        return nil
    }

}
