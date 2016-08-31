//
//  FirebaseModels.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import Firebase
import FIRDatabase
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
                //TODO
            })
        }
    }
    
}