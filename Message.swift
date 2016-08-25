//
//  Message.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/21/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    var isIncoming: Bool {
        return sender != nil
    }

}
