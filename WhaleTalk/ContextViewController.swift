//
//  ContextViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/27/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import CoreData

protocol ContextViewController {
    var context: NSManagedObjectContext? { get set }
}