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
    func upload(context: NSManagedObjectContext)
}

extension Contact: FirebaseModel {
    
    func upload(context: NSManagedObjectContext) {
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else { return }
        for number in phoneNumbers {
            let reference = FIRDatabase.database().reference()
            reference.child("users").queryOrderedByChild("phoneNumber").queryEqualToValue(number.value).observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                guard let user = snapshot.value as? NSDictionary else { return }
                let uid = user.allKeys.first as? String
                context.performBlock{
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
    
}