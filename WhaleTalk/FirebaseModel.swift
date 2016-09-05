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
                    self.observeStatus(rootRef, context: context)
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
