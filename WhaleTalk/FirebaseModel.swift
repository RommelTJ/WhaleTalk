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
