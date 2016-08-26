//
//  NewGroupParticipantsViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/25/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {

    var context: NSManagedObjectContext?
    var chat: Chat?
    var chatCreationDelegate: ChatCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Participants"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
