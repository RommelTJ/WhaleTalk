//
//  Chat+Firebase.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 9/5/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import FirebaseDatabase
extension Chat: FirebaseModel {
    
    static func new(forStorageId storageId:String, rootRef: FIRDatabaseReference!, inContext context: NSManagedObjectContext) -> Chat {
        let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as! Chat
        chat.storageId = storageId
        
        rootRef.child("chats\(storageId)/meta").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let participantsDict = data["participants"] as? NSMutableDictionary else { return }
            
            participantsDict.removeObjectForKey(FirebaseStore.currentPhoneNumber!)
            let participants = participantsDict.allKeys.map{
                (phoneNumber: AnyObject) -> Contact in
                let phoneNumber = phoneNumber as! String
                return Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context) ?? Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context)
            }
            
            let name = data["name"] as? String
            context.performBlock{
                chat.participants = NSSet(array: participants)
                chat.name = name
                do {
                    try context.save()
                } catch {
                    print("Error saving.")
                }
            }
        })
        
        return chat
    }
    
    
    static func existing(storageId storageId: String, inContext context: NSManagedObjectContext) -> Chat? {
        let request = NSFetchRequest(entityName: "Chat")
        request.predicate = NSPredicate(format: "storageId=%@", storageId)
        
        do {
            if let results = try context.executeFetchRequest(request) as? [Chat] where results.count > 0 {
                if let chat = results.first{
                    return chat
                }
            }
        } catch {
            print("Error Fetching")
        }
        
        return nil
    }
    
    func upload(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        guard storageId == nil else { return }
        
        let ref = rootRef.child("chats").childByAutoId()
        storageId = ref.key
        var data: [String: AnyObject] = [
            "id": ref.key,
            ]
        
        guard let participants = participants?.allObjects as? [Contact] else { return }
        var numbers = [FirebaseStore.currentPhoneNumber!: true]
        var userIds = [FIRAuth.auth()?.currentUser?.uid]
        
        for participant in participants {
            guard let phoneNumbers = participant.phoneNumbers?.allObjects as? [PhoneNumber] else { continue }
            guard let number = phoneNumbers.filter({$0.registered}).first else { continue }
            numbers[number.value!] = true
            userIds.append(participant.storageId!)
        }
        data["participants"] = numbers
        if let name = name {
            data["name"] = name
        }
        ref.setValue(["meta": data])
        for id in userIds {
            rootRef.child("users/\(id)/chats/\(ref.key)").setValue(true)
        }
    }
}