//
//  NewGroupViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/25/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    var chatCreationDelegate: ChatCreationDelegate?
    private let subjectField = UITextField()
    private let characterNumberLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Group"
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(NewGroupViewController.cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(NewGroupViewController.next))
        
        subjectField.placeholder = "Group Subject"
        subjectField.delegate = self
        subjectField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subjectField)
        
        characterNumberLabel.textColor = UIColor.grayColor()
        characterNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(characterNumberLabel)
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.lightGrayColor()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(bottomBorder)
        
        //Auto-layout Constraints
        let constraints: [NSLayoutConstraint] = [
            subjectField.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20),
            subjectField.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
            subjectField.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            bottomBorder.widthAnchor.constraintEqualToAnchor(subjectField.widthAnchor),
            bottomBorder.bottomAnchor.constraintEqualToAnchor(subjectField.bottomAnchor),
            bottomBorder.leadingAnchor.constraintEqualToAnchor(subjectField.leadingAnchor),
            bottomBorder.heightAnchor.constraintEqualToConstant(1),
            characterNumberLabel.centerYAnchor.constraintEqualToAnchor(subjectField.centerYAnchor),
            characterNumberLabel.trailingAnchor.constraintEqualToAnchor(subjectField.layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        
    }
    
    func next() {
        
    }

}
