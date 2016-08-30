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
    
    var isGroupChat: Bool {
        return participants?.count > 1
    }
    
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
    
    func add(participant contact: Contact) {
        mutableSetValueForKey("participants").addObject(contact)
    }
    
    static func existing(directWith contact: Contact, inContext context: NSManagedObjectContext) -> Chat? {
        let request = NSFetchRequest(entityName: "Chat")
        request.predicate = NSPredicate(format: "ANY participants = %@ AND participants.@count = 1", contact)
        do {
            guard let results = try context.executeFetchRequest(request) as? [Chat] else { return nil }
            return results.first
        } catch {
            print("Error fetching")
        }
        return nil
    }
    
}
