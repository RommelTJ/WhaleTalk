//
//  Contact.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/22/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData


class Contact: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    var sortLetter: String {
        let letter = lastName?.characters.first ?? firstName?.characters.first
        let s = String(letter!)
        return s
    }
    
    var fullName: String {
        var fullName = ""
        if let firstName = firstName {
            fullName += firstName
        }
        if let lastName = lastName {
            if fullName.characters.count > 0 {
                fullName += " "
            }
            fullName += lastName
        }
        return fullName
    }

}
