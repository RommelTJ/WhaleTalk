//
//  FirebaseModels.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/30/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import Firebase
import CoreData

protocol FirebaseModel {
    func upload(context: NSManagedObjectContext)
}
