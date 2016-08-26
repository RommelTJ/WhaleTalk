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
        updateNextButton(forCharCount: 0)
        
        subjectField.placeholder = "Group Subject"
        subjectField.delegate = self
        subjectField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subjectField)
        updateCharacterLabel(forCharCount: 0)
        
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func next() {
        guard let context = context, chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat else { return }
        chat.name = subjectField.text
        
        let vc = NewGroupParticipantsViewController()
        vc.context = context
        vc.chat = chat
        vc.chatCreationDelegate = chatCreationDelegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateCharacterLabel(forCharCount length: Int) {
        characterNumberLabel.text = String(25 - length)
    }
    
    func updateNextButton(forCharCount length: Int) {
        if length == 0 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }

}

extension NewGroupViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharCount = textField.text?.characters.count ?? 0
        let newLength = currentCharCount + string.characters.count - range.length
        
        if newLength <= 25 {
            updateCharacterLabel(forCharCount: newLength)
            updateNextButton(forCharCount: newLength)
            return true
        }
        return false
    }
}