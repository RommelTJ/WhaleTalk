//
//  FavoritesViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/28/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class FavoritesViewController: UIViewController, TableViewFetchedResultsDisplayer, ContextViewController {
    
    var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "FavoriteCell"
    private let store = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.registerClass(FavoriteCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        fillViewWith(tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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
        // Dispose of any resources that can be recreated.
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        guard let cell = cell as? FavoriteCell else { return }
        cell.textLabel?.text = contact.fullName
        cell.detailTextLabel?.text = "*** no status ***"
        cell.phoneTypeLabel.text = "mobile"
        cell.accessoryType = .DetailButton
    }

}