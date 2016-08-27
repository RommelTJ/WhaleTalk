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

class ContactImporter {
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func formatPhoneNumber(number: CNPhoneNumber) -> String {
        return number.stringValue
            .stringByReplacingOccurrencesOfString(" ", withString: "")
            .stringByReplacingOccurrencesOfString("-", withString: "")
            .stringByReplacingOccurrencesOfString("(", withString: "")
            .stringByReplacingOccurrencesOfString(")", withString: "")
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { (granted, error) in
            if granted {
                do {
                    let req = CNContactFetchRequest(keysToFetch: [
                        CNContactGivenNameKey,
                        CNContactFamilyNameKey,
                        CNContactPhoneNumbersKey
                        ])
                    try store.enumerateContactsWithFetchRequest(req, usingBlock: { (cnContact, stop) in
                        guard let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: self.context) as? Contact else { return }
                        
                        contact.firstName = cnContact.givenName
                        contact.lastName = cnContact.familyName
                        contact.contactId = cnContact.identifier
                        let contactNumbers = NSMutableSet()
                        for cnVal in cnContact.phoneNumbers {
                            guard let cnPhoneNumber = cnVal.value as? CNPhoneNumber else { continue }
                            guard let phoneNumber = NSEntityDescription.insertNewObjectForEntityForName("PhoneNumber", inManagedObjectContext: self.context) as? PhoneNumber else { continue }
                            phoneNumber.value = self.formatPhoneNumber(cnPhoneNumber)
                            contactNumbers.addObject(phoneNumber)
                        }
                        contact.phoneNumbers  = contactNumbers
                    })
                } catch let error as NSError {
                    print(error)
                } catch {
                    print("Error with do-catch")
                }
            }
        }
    }
    
}

