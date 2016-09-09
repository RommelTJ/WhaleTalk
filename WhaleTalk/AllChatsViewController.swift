//
//  AllChatsViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/21/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer, ChatCreationDelegate, ContextViewController {
    
    var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController<AnyObject>?
    private let tableView = UITableView(frame: CGRectZero, style: .plain)
    private let cellIdentifier = "MessageCell"
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new-chat"), style: .plain, target: self, action: #selector(AllChatsViewController.newChat))
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableHeaderView = createHeader()
        tableView.dataSource = self
        tableView.delegate = self
        fillViewWith(subView: tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Chat")
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching.")
            }
        }
        fakeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newChat() {
        let vc = NewChatViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    func fakeData() {
        guard let context = context else { return }
        let _ = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as? Chat
        //let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let cell = cell as! ChatCell
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else { return }
        guard let contact = chat.participants?.anyObject() as? Contact else { return }
        guard let lastMessage = chat.lastMessage, let timestamp = lastMessage.timestamp, let text = lastMessage.text else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = contact.fullName
        cell.dateLabel.text = formatter.stringFromDate(timestamp)
        cell.messageLabel.text = text
        
    }

    func created(chat chat: Chat, inContext context: NSManagedObjectContext) {
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createHeader() -> UIView {
        let header = UIView()
        let newGroupButton = UIButton()
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(newGroupButton)
        
        newGroupButton.setTitle("New Group", for: .normal)
        newGroupButton.setTitleColor(view.tintColor, for: .normal)
        newGroupButton.addTarget(self, action: #selector(AllChatsViewController.pressedNewGroup), for: .touchUpInside)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(border)
        
        border.backgroundColor = UIColor.lightGray
        
        //Constraints
        let constraints: [NSLayoutConstraint] = [
            newGroupButton.heightAnchor.constraint(equalTo: header.heightAnchor),
            newGroupButton.trailingAnchor.constraint(equalTo: header.layoutMarginsGuide.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        
        return header
    }
    
    func pressedNewGroup() {
        let vc = NewGroupViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}

extension AllChatsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else { return }
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
