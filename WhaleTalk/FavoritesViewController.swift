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
    private var fetchedResultsController: NSFetchedResultsController<AnyObject>?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    private let tableView = UITableView(frame: CGRectZero, style: .plain)
    private let cellIdentifier = "FavoriteCell"
    private let store = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.dataSource = self
        tableView.delegate = self
        fillViewWith(subView: tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            //request.predicate = NSPredicate(format: "storageId != nil AND favorite = true")
            request.predicate = NSPredicate(format: "favorite = true")
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(FavoritesViewController.deleteAll))
        } else {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = nil
            guard let context = context , context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                print("Error saving")
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        guard let cell = cell as? FavoriteCell else { return }
        cell.textLabel?.text = contact.fullName
        cell.detailTextLabel?.text = contact.status ?? "*** no status ***"
        cell.phoneTypeLabel.text = contact.phoneNumbers?.filter({
            number in guard let number = number as? PhoneNumber else { return false }
            return number.registered
        }).first?.kind
        cell.accessoryType = .detailButton
    }
    
    func deleteAll() {
        guard let contacts = fetchedResultsController?.fetchedObjects as? [Contact] else { return }
        for contact in contacts {
            context?.deleteObject(contact)
        }
    }

}

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else { return nil }
        let currentSection = sections[section]
        return currentSection.name
    }
    
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        
        let chat = Chat.existing(directWith: contact, inContext: chatContext) ?? Chat.new(directWith: contact, inContext: chatContext)
        
        let vc = ChatViewController()
        vc.context = chatContext
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        guard let id = contact.contactId else { return }
        let cnContact: CNContact
        do {
            cnContact = try store.unifiedContactWithIdentifier(id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            return
        }
        let vc = CNContactViewController(for: cnContact)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else { return }
        contact.favorite = false
    }
    
}
