//
//  NewGroupParticipantsViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/25/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {

    var context: NSManagedObjectContext?
    var chat: Chat?
    var chatCreationDelegate: ChatCreationDelegate?
    private var searchField: UITextField!
    private let tableView = UITableView(frame: CGRectZero, style: .plain)
    private let cellIdentifier = "ContactCell"
    private var displayedContacts = [Contact]()
    private var allContacts = [Contact]()
    private var selectedContacts = [Contact]()
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Participants"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(NewGroupParticipantsViewController.createChat))
        showCreateButton(show: false)
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        searchField = createSearchField()
        searchField.delegate = self
        tableView.tableHeaderView = searchField
        fillViewWith(subView: tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.predicate = NSPredicate(format: "storageId!=nil")
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key: "firstName", ascending: true)]
            do {
                if let result = try context.executeFetchRequest(request) as? [Contact] {
                    allContacts = result
                }
            } catch {
                print("There was a problem fetching.")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createSearchField() -> UITextField {
        let searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        searchField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        searchField.placeholder = "Type contact name"
        
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchField.leftView = holderView
        searchField.leftViewMode = .always
        
        let image = UIImage(named: "contact_icon")?.withRenderingMode(.alwaysTemplate)
        let contactImage = UIImageView(image: image)
        contactImage.tintColor = UIColor.darkGray
        
        holderView.addSubview(contactImage)
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            contactImage.widthAnchor.constraint(equalTo: holderView.widthAnchor, constant: -20),
            contactImage.heightAnchor.constraint(equalTo: holderView.heightAnchor, constant: -20),
            contactImage.centerXAnchor.constraint(equalTo: holderView.centerXAnchor),
            contactImage.centerYAnchor.constraint(equalTo: holderView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return searchField
    }
    
    private func showCreateButton(show: Bool) {
        if show {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func endSearch() {
        isSearching = false
        displayedContacts = selectedContacts
        tableView.reloadData()
    }
    
    func createChat() {
        guard let chat = chat, let context = context else { return }
        chat.participants = NSSet(array: selectedContacts)
        chatCreationDelegate?.created(chat: chat, inContext: context)
        dismiss(animated: false, completion: nil)
    }

}

extension NewGroupParticipantsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let contact = displayedContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        cell.selectionStyle = .None
        return cell
    }
    
}

extension NewGroupParticipantsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard isSearching else { return }
        let contact = displayedContacts[indexPath.row]
        guard !selectedContacts.contains(contact) else { return }
        selectedContacts.append(contact)
        allContacts.removeAtIndex(allContacts.indexOf(contact)!)
        searchField.text = ""
        endSearch()
        showCreateButton(true)
    }
    
}

extension NewGroupParticipantsViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        isSearching = true
        guard let currentText = textField.text else {
            endSearch()
            return true
        }
        
        let text = NSString(string: currentText).replacingCharacters(in: range, with: string)
        if text.characters.count == 0 {
            endSearch()
            return true
        }
        
        displayedContacts = allContacts.filter({ (contact: Contact) -> Bool in
            let match = contact.fullName.rangeOfString(text) != nil
            return match
        })
        tableView.reloadData()
        return true
    }
    
}
