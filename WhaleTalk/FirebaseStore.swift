//
//  FirebaseStore.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import CoreData

class FirebaseStore {
    
    private let context: NSManagedObjectContext
    private var currentPhoneNumber: String? {
        set(phoneNumber) {
            NSUserDefaults.standardUserDefaults().setObject(phoneNumber, forKey: "phoneNumber")
        }
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("phoneNumber") as? String
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func hasAuth() -> Bool {
        var authentication = false
        
        FIRAuth.auth()?.addAuthStateDidChangeListener{ auth, user in
            if user != nil {
                //User signed in
                authentication = true
            } else {
                //User not authenticated
                authentication = false
            }
        }
        
        return authentication
    }
}

extension FirebaseStore: RemoteStore {
    
    func startSyncing() {
        //TODO
    }
    
    func store(inserted inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        //TODO
    }
    
    func signUp(phoneNumber phoneNumber: String, email: String, password: String, success: () -> (), error: (errorMessage: String) -> ()) {
        //TODO
    }
    
}