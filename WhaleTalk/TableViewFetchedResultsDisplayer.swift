//
//  TableViewFetchedResultsDisplayer.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/28/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewFetchedResultsDisplayer {
    func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath)
}