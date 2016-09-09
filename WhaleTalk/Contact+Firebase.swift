//
//  Contact+Firebase.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 9/5/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseAuth

extension Contact: FirebaseModel {
    
    static func new(forPhoneNumber phoneNumberVal: String, rootRef: FIRDatabaseReference!, inContext context: NSManagedObjectContext)-> Contact {
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
        let phoneNumber = NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: context) as! PhoneNumber
        
        phoneNumber.contact = contact
        phoneNumber.registered = true
        phoneNumber.value = phoneNumberVal
        contact.getContactId(context: context, phoneNumber: phoneNumberVal, rootRef: rootRef)
        
        return contact
    }
    
    static func existing(withPhoneNumber phoneNumber: String, rootRef: FIRDatabaseReference!, inContext context: NSManagedObjectContext)-> Contact? {
        let request = NSFetchRequest(entityName: "PhoneNumber")
        request.predicate = NSPredicate(format: "value==%@", phoneNumber)
        
        do {
            if let results = try context.executeFetchRequest(request) as? [PhoneNumber], results.count > 0 {
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
        rootRef.child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: phoneNumber).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let user = snapshot.value as? NSDictionary else { return }
            
            let uid = user.allKeys.first as! String
            context.perform({
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
            rootRef.child("users").child(userID!).queryOrdered(byChild: "phoneNumber").queryEqual(toValue: number.value).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let user = snapshot.value as? NSDictionary else { return }
                let uid = user.allKeys.first as? String
                context.perform {
                    self.storageId = uid
                    number.registered = true
                    do {
                        try context.save()
                    } catch {
                        print("Error saving")
                    }
                    self.observeStatus(rootRef: rootRef, context: context)
                }
            })
        }
    }
    
    func observeStatus(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        rootRef.child("users/\(storageId!)/status").child(userID!).observe(.value, with: {
            (snapshot) in
            guard let status = snapshot.value as? String else{ return }
            context.perform{
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
