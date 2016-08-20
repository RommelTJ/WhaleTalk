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
    private var outgoingConstraint: NSLayoutConstraint!
    private var incomingConstraint: NSLayoutConstraint!
    
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
        outgoingConstraint = bubbleImageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor)
        incomingConstraint = bubbleImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor)
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0 //So that # of lines is unlimited and not clipped.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func incoming(incoming: Bool) {
        if incoming {
            incomingConstraint.active = true
            outgoingConstraint.active = false
            bubbleImageView.image = bubble.incoming
        } else {
            incomingConstraint.active = false
            outgoingConstraint.active = true
            bubbleImageView.image = bubble.outgoing
        }
    }
}

let bubble = makeBubble()

func makeBubble() -> (incoming: UIImage, outgoing: UIImage) {
    let image = UIImage(named: "MessageBubble")!
    let outgoing = coloredImage(image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    let flippedImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
    let incoming = coloredImage(flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
    return (incoming, outgoing)
}

func coloredImage(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
    let rect = CGRect(origin: CGPointZero, size: image.size)
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.drawInRect(rect)
    CGContextSetRGBFillColor(context, red, green, blue, alpha)
    CGContextSetBlendMode(context, .SourceAtop)
    CGContextFillRect(context, rect)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result
}