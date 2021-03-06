//
//  Message+Firebase.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 9/5/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import FirebaseDatabase

extension Message: FirebaseModel {
    
    func upload(rootRef: FIRDatabaseReference!, context: NSManagedObjectContext) {
        if chat!.storageId == nil {
            chat!.upload(rootRef: rootRef, context: context)
        }
        let data = [
            "message" : text!,
            "sender" : FirebaseStore.currentPhoneNumber!
        ]
        guard let chat = chat, let timestamp = timestamp, let storageId = chat.storageId else { return }
        let timeInterval = String(Int(timestamp.timeIntervalSince1970 * 100000))
        rootRef.child("chats/\(storageId)/messages/\(timeInterval)").setValue(data)
    }
    
}
