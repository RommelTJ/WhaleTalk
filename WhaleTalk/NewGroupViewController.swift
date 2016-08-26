//
//  NewGroupViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/25/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    var chatCreationDelegate: ChatCreationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Group"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
