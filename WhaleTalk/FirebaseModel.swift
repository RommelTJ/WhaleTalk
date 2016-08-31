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
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext)
}

extension Contact: FirebaseModel {
    
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext) {
        print("Upload")
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else { return }
        for number in phoneNumbers {
            let userID = FIRAuth.auth()?.currentUser?.uid
            print("Upload:: USERID: \(userID)")
            rootRef.child("users").child(userID!).queryOrderedByChild("phoneNumber").queryEqualToValue(number.value).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                print("Checking for user.")
                
                guard let user = snapshot.value as? NSDictionary else {
                    print("We failed in guard for upload")
                    return
                }
                print("We got a user")
                print(user)
                print("\(user.allKeys)")
                print("\(user.allKeys.first)")
                
                let uid = user.allKeys.first as? String
                print("\(uid)")
                
                context.performBlock {
                    self.storageId = uid
                    number.registered = true
                    do {
                        print("Saving to CoreData")
                        try context.save()
                        print("Save.")
                    } catch {
                        print("Error saving")
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
}