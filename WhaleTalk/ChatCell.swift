//
//  ChatCell.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/21/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let dateLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightBold)
        messageLabel.textColor = UIColor.grayColor()
        dateLabel.textColor = UIColor.grayColor()
        
        let labels = [nameLabel, messageLabel, dateLabel]
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

}
