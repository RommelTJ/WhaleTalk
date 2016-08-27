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
                    print(cnContact)
                })
            } catch let error as NSError {
                print(error)
            } catch {
                print("Error with do-catch")
            }
        }
    }
}