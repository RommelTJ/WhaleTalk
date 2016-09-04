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
