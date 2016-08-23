//
//  NewChatViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/22/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
