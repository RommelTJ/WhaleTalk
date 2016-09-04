//
//  FirebaseModels.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreData

protocol FirebaseModel {
    func upload(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext)
}

extension Contact: FirebaseModel {
    
    static func new(forPhoneNumber phoneNumberVal: String, rootRef: FIRDatabaseReference!, inContext context: NSManagedObjectContext)-> Contact {
        let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as! Contact
        let phoneNumber = NSEntityDescription.insertNewObjectForEntityForName("PhoneNumber", inManagedObjectContext: context) as! PhoneNumber
        
        phoneNumber.contact = contact
        phoneNumber.registered = true
        phoneNumber.value = phoneNumberVal
        contact.getContactId(context, phoneNumber: phoneNumberVal, rootRef: rootRef)
        
        return contact
    }
    
    static func existing(withPhoneNumber phoneNumber: String, rootRef: FIRDatabaseReference!, inContext context: NSManagedObjectContext)-> Contact? {
        let request = NSFetchRequest(entityName: "PhoneNumber")
        request.predicate = NSPredicate(format: "value=%@", phoneNumber)
        
        do {
            if let results = try context.executeFetchRequest(request) as? [PhoneNumber]
                where results.count > 0 {
                let contact = results.first!.contact!
                if contact.storageId == nil {
                    contact.getContactId(context, phoneNumber: phoneNumber, rootRef: rootRef)
                }
                return contact
            }
        } catch {
            print("Error fetching")
        }
        
        return nil
    }
    
    func getContactId(context: NSManagedObjectContext, phoneNumber: String, rootRef: FIRDatabaseReference!) {
        rootRef.child("users").queryOrderedByChild("phoneNumber").queryEqualToValue(phoneNumber).observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            guard let user = snapshot.value as? NSDictionary else { return }
            
            let uid = user.allKeys.first as? String
            context.performBlock({ 
                self.storageId = uid
                do {
                    try context.save()
                } catch {
                    print("Error saving")
                }
            })
        })
    }
    
    func upload(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else { return }
        for number in phoneNumbers {
            let userID = FIRAuth.auth()?.currentUser?.uid
            rootRef.child("users").child(userID!).queryOrderedByChild("phoneNumber").queryEqualToValue(number.value).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                guard let user = snapshot.value as? NSDictionary else { return }
                let uid = user.allKeys.first as? String
                context.performBlock {
                    self.storageId = uid
                    number.registered = true
                    do {
                        try context.save()
                    } catch {
                        print("Error saving")
                    }
                }
            })
        }
    }
    
    func observeStatus(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        rootRef.child("users/\(storageId!)/status").observeEventType(.Value, withBlock: {
            snapshot in
            guard let status = snapshot.value as? String else{ return }
            context.performBlock{
                self.status = status
                do {
                    try context.save()
                } catch {
                    print("Error saving.")
                }
            }
        })
    }
    
}

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

extension Message: FirebaseModel {
    
    func upload(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        if chat?.storageId == nil {
            chat?.upload(rootRef, context: context)
        }
        let data = [
            "message" : text!,
            "sender" : FirebaseStore.currentPhoneNumber!
        ]
        guard let chat = chat, timestamp = timestamp, storageId = chat.storageId else { return }
        let timeInterval = String(Int(timestamp.timeIntervalSince1970 * 100000))
        rootRef.child("chats/\(storageId)/messages/\(timeInterval)").setValue(data)
    }

}
