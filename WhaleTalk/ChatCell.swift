//
//  ChatCell.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/18/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    let messageLabel: UILabel = UILabel()
    private let bubbleImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Required when setting up constraints in code.
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Adding the views to the content view.
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        //Setting the AutoLayout constraints.
        messageLabel.centerXAnchor.constraintEqualToAnchor(bubbleImageView.centerXAnchor).active = true
        messageLabel.centerYAnchor.constraintEqualToAnchor(bubbleImageView.centerYAnchor).active = true
        //Adding 50 to the width to account for the Speech Bubble's tail.
        bubbleImageView.widthAnchor.constraintEqualToAnchor(messageLabel.widthAnchor, constant: 50).active = true
        bubbleImageView.heightAnchor.constraintEqualToAnchor(messageLabel.heightAnchor).active = true
        bubbleImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        bubbleImageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor).active = true
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0 //So that # of lines is unlimited and not clipped.
        
        //Adding the image to the bubbleImageView.
        //Note: imagewithRenderingMode with AlwaysTemplate rendering mode. 
        // This means that the image will be drawn ignoring its color information, so it's up to us
        // to color it. This is useful for drawing images in code.
        let image = UIImage(named: "MessageBubble")?.imageWithRenderingMode(.AlwaysTemplate)
        bubbleImageView.tintColor = UIColor.blueColor()
        bubbleImageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
