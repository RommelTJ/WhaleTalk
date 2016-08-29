//
//  ContactsViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/28/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class ContactsViewController: UIViewController, ContextViewController, TableViewFetchedResultsDisplayer {

    var context: NSManagedObjectContext?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    private var fetchedResultsController: NSFetchedResultsController?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = "All Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .Plain, target: self, action: #selector(ContactsViewController.newContact))
        automaticallyAdjustsScrollViewInsets = false
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        fillViewWith(tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching.")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func newContact() {
        //TODO
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath) {
        //TODO
    }
    
}
