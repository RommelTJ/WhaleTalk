//
//  FirebaseStore.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import CoreData

class FirebaseStore {
    
    private let context: NSManagedObjectContext
    var rootRef: FIRDatabaseReference!
    private(set) static var currentPhoneNumber:String? {
        set(phoneNumber) {
            NSUserDefaults.standardUserDefaults().setObject(phoneNumber, forKey: "phoneNumber")
        }
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("phoneNumber") as? String
        }
    }
    
    init(context: NSManagedObjectContext) {
        rootRef = FIRDatabase.database().reference()
        self.context = context
    }
    
    func hasAuth() -> Bool {
        var authentication = false
        
        if FIRAuth.auth()?.currentUser != nil {
            authentication = true
        }
        
        return authentication
    }
    
    private func upload(model: NSManagedObject) {
        guard let model = model as? FirebaseModel else { return }
        model.upload(rootRef, context: context)
    }
    
    private func listenForNewMessages(chat: Chat) {
        chat.observeMessages(rootRef, context: context)
    }
    
    private func fetchAppContacts()->[Contact]{
        do {
            let request = NSFetchRequest(entityName: "Contact")
            request.predicate = NSPredicate(format: "storageId != nil")
            if let results = try self.context.executeFetchRequest(request) as? [Contact] {
                return results
            }
        } catch {print("Error fetching Contacts")}
        return []
    }
    
    private func observeUserStatus(contact: Contact){
        contact.observeStatus(rootRef, context: context)
    }
    
    private func observeStatuses(){
        let contacts = fetchAppContacts()
        contacts.forEach(observeUserStatus)
    }
    
    private func observeChats() {
        self.rootRef.child("users/\(FIRAuth.auth()?.currentUser?.uid)/chats").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let uid = snapshot.key
            let chat = Chat.existing(storageId: uid, inContext: self.context) ?? Chat.new(forStorageId: uid, rootRef: self.rootRef, inContext: self.context)
            if chat.inserted {
                do {
                    try self.context.save()
                } catch {
                    print("Error saving.")
                }
            }
            self.listenForNewMessages(chat)
        })
    }
    
}

extension FirebaseStore: RemoteStore {
    
    func startSyncing() {
        context.performBlock{
            self.observeStatuses()
            self.observeChats()
        }
    }
    
    func store(inserted inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        inserted.forEach(upload)
        do {
            try context.save()
        } catch {
            print("Error saving")
        }
    }
    
    func signUp(phoneNumber phoneNumber: String, email: String, password: String, success: () -> (), error errorCallback: (errorMessage: String) -> ()) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            if let error = error {
                errorCallback(errorMessage: error.localizedDescription)
            } else {
                let newUser = ["phoneNumber": phoneNumber]
                FirebaseStore.currentPhoneNumber = phoneNumber
                
                self.rootRef.child("users").child(user!.uid).setValue(newUser)
                
                FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                    if let error = error {
                        errorCallback(errorMessage: error.localizedDescription)
                    } else {
                        success()
                    }
                } // end signInWithEmail
            }
        } //end createUserWithEmail
    } // end signUp

}