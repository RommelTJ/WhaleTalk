//
//  ChatCreationDelegate.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/23/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData

protocol ChatCreationDelegate {
    func created(chat chat: Chat, inContext context: NSManagedObjectContext)
}