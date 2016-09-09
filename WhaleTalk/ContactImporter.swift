//
//  ContactImporter.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/26/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData
import Contacts

class ContactImporter: NSObject {
    
    private var context: NSManagedObjectContext
    private var lastCNNotificationTime: NSDate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func listenForChanges() {
        CNContactStore.authorizationStatus(for: .contacts)
        NotificationCenter.defaultCenter.addObserver(self, selector: #selector(ContactImporter.addressBookDidChange(_:)), name: CNContactStoreDidChangeNotification, object: nil)
    }
    
    func addressBookDidChange(notification: NSNotification) {
        let now = NSDate()
        guard lastCNNotificationTime == nil || now.timeIntervalSince(lastCNNotificationTime! as Date) > 1 else { return }
        lastCNNotificationTime = now
        fetch()	
    }
    
    func formatPhoneNumber(number: CNPhoneNumber) -> String {
        return number.stringValue
            .stringByReplacingOccurrencesOfString(" ", withString: "")
            .stringByReplacingOccurrencesOfString("-", withString: "")
            .stringByReplacingOccurrencesOfString("(", withString: "")
            .stringByReplacingOccurrencesOfString(")", withString: "")
    }
    
    private func fetchExisting() -> (contacts: [String: Contact], phoneNumbers: [String: PhoneNumber]) {
        var contacts = [String: Contact]()
        var phoneNumbers = [String: PhoneNumber]()
        do {
            let request = NSFetchRequest(entityName: "Contact")
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            if let contactsResults = try self.context.executeFetchRequest(request) as? [Contact] {
                for contact in contactsResults {
                    contacts[contact.contactId!] = contact
                    for phoneNumber in contact.phoneNumbers! {
                        phoneNumbers[phoneNumber.value] = phoneNumber as? PhoneNumber
                    }
                }
            }
        } catch {
            print("Error")
        }
        return (contacts, phoneNumbers)
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            
            self.context.perform({ 
                if granted {
                    do {
                        let (contacts, phoneNumbers) = self.fetchExisting()
                        
                        let req = CNContactFetchRequest(keysToFetch: [
                            CNContactGivenNameKey as CNKeyDescriptor,
                            CNContactFamilyNameKey as CNKeyDescriptor,
                            CNContactPhoneNumbersKey as CNKeyDescriptor
                            ])
                        try store.enumerateContacts(with: req, usingBlock: { (cnContact, stop) in
                            guard let contact = contacts[cnContact.identifier] ?? NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else { return }
                            
                            contact.firstName = cnContact.givenName
                            contact.lastName = cnContact.familyName
                            contact.contactId = cnContact.identifier

                            for cnVal in cnContact.phoneNumbers {
                                guard let cnPhoneNumber = cnVal.value as? CNPhoneNumber else { continue }
                                guard let phoneNumber = phoneNumbers[cnPhoneNumber.stringValue] ?? NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: self.context) as? PhoneNumber else { continue }
                                phoneNumber.kind = CNLabeledValue.localizedString(forLabel: cnVal.label!)
                                phoneNumber.value = self.formatPhoneNumber(number: cnPhoneNumber)
                                phoneNumber.contact = contact
                            }
                            if contact.isInserted {
                                contact.favorite = true
                            }
                        })
                        try self.context.save()
                    } catch let error as NSError {
                        print(error)
                    } catch {
                        print("Error with do-catch")
                    }
                }
            })
            
        }
    }
    
}

