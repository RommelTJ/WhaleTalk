//
//  UITableView+Scroll.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/20/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func scrollToBottom() {
        if numberOfRowsInSection(0) > 0 {
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: (self.numberOfRowsInSection(0)-1), inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
}