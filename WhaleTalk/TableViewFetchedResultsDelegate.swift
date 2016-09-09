//
//  TableViewFetchedResultsDelegate.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/23/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class TableViewFetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {

    private var tableView: UITableView!
    private var displayer: TableViewFetchedResultsDisplayer!
 
    init(tableView: UITableView, displayer: TableViewFetchedResultsDisplayer) {
        self.tableView = tableView
        self.displayer = displayer
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController<AnyObject>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<AnyObject>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController<AnyObject>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath! as IndexPath)
            displayer.configureCell(cell: cell!, atIndexPath: indexPath!)
            tableView.reloadRows(at: [indexPath! as IndexPath], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<AnyObject>) {
        tableView.endUpdates()
    }
    
}

