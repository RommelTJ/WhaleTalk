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
}

protocol TableViewFetchedResultsDisplayer {
    func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath)
}
