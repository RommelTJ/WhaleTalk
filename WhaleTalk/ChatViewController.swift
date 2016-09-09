//
//  ChatViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/15/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let newMessageField = UITextView()
    private var sections = [NSDate: [Message]]()
    private var dates = [NSDate]()
    private var bottomConstraint: NSLayoutConstraint!
    private let cellIdentifier = "Cell"
    var context: NSManagedObjectContext?
    var chat: Chat?
    
    private enum Error: Error {
        case NoChat
        case NoContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            guard let chat = chat else { throw Error.NoChat }
            guard let context = context else { throw Error.NoContext }
            
            let request = NSFetchRequest(entityName: "Message")
            request.predicate = NSPredicate(format: "chat=%@", chat)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if let result = try context.executeFetchRequest(request) as? [Message] {
                for message in result {
                    addMessage(message)
                }
            }
        } catch {
            print("We couldn't fetch!")
        }
        automaticallyAdjustsScrollViewInsets = false
        
        //Message Area
        let newMessageArea = UIView()
        newMessageArea.backgroundColor = UIColor.lightGray
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(newMessageField)
        newMessageField.isScrollEnabled = false
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(ChatViewController.pressedSend(_:)), for: .TouchUpInside)
        sendButton.setContentHuggingPriority(255, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(751, for: .horizontal)
        bottomConstraint = newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        //Message Area constraints
        let messageAreaConstraints: [NSLayoutConstraint] = [
            newMessageArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newMessageArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newMessageField.leadingAnchor.constraint(equalTo: newMessageArea.leadingAnchor, constant: 10),
            newMessageField.centerYAnchor.constraint(equalTo: newMessageArea.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: newMessageArea.trailingAnchor, constant: -10),
            newMessageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: newMessageField.centerYAnchor),
            newMessageArea.heightAnchor.constraint(equalTo: newMessageField.heightAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(messageAreaConstraints)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.backgroundView = UIImageView(image: UIImage(named: "whaletalk-Bg"))
        tableView.separatorColor = UIColor.clear
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
        
        NotificationCenter.defaultCenter.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.defaultCenter.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if let mainContext = context?.parent ?? context {
            NotificationCenter.defaultCenter.addObserver(self, selector: #selector(ChatViewController.contextUpdated(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: mainContext)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.scrollToBottom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillHide(notification: NSNotification) {
        updateBottomConstraint(notification: notification)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        updateBottomConstraint(notification: notification)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func updateBottomConstraint(notification: NSNotification) {
        if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            let newFrame = view.convert(frame, from: (UIApplication.shared.delegate?.window)!)
            bottomConstraint.constant = newFrame.origin.y - view.frame.height
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
            tableView.scrollToBottom()
        }
    }
    
    func pressedSend(button: UIButton) {
        guard let text = newMessageField.text , text.characters.count > 0 else { return }
        checkTemporaryContext()
        guard let context = context else { return }
        guard let message = NSEntityDescription
                            .insertNewObject(forEntityName: "Message", into: context)
                            as? Message else { return }
        message.text = text
        message.timestamp = NSDate()
        message.chat = chat
        chat?.lastMessageTime = message.timestamp
        do {
            try context.save()
        } catch {
            print("There was a problem saving the message.")
            return
        }
        newMessageField.text = ""
        view.endEditing(true)
    }
    
    func addMessage(message: Message) {
        guard let date = message.timestamp else { return }
        let calendar = NSCalendar.current
        let startDay = calendar.startOfDayForDate(date)
        
        var messages = sections[startDay]
        if messages == nil {
            dates.append(startDay)
            dates = dates.sorted(by: {$0.earlierDate($1 as Date) == $0 as Date})
            messages = [Message]()
        }
        messages!.append(message)
        messages!.sortInPlace({$0.timestamp!.earlierDate($1.timestamp!) == $0.timestamp!})
        sections[startDay] = messages
    }
    
    func contextUpdated(notification: NSNotification) {
        guard let set = (notification.userInfo![NSInsertedObjectsKey] as? NSSet) else { return }
        let objects = set.allObjects
        for obj in objects {
            guard let message = obj as? Message else { continue }
            if message.chat?.objectID == chat?.objectID {
                addMessage(message: message)
            }
        }
        tableView.reloadData()
        tableView.scrollToBottom()
    }
    
    func checkTemporaryContext() {
        if let mainContext = context?.parent, let chat = chat {
            let tempContext = context
            context = mainContext
            do {
                try tempContext?.save()
            } catch {
                print("Error saving tempContext.")
            }
            self.chat = mainContext.object(with: chat.objectID) as? Chat
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension ChatViewController: UITableViewDataSource {
    
    func getMessages(section: Int) -> [Message] {
        let date = dates[section]
        return section[date]!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMessages(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageCell
        let messages = getMessages(section: indexPath.section)
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(message.isIncoming)
        cell.backgroundColor = UIColor.clearColor()
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Constraints
        let constraints: [NSLayoutConstraint] = [
            paddingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paddingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            paddingView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraint(equalTo: dateLabel.widthAnchor, constant: 10),
            view.heightAnchor.constraint(equalTo: paddingView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formatter.stringFromDate(dates[section])
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
