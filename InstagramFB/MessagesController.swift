//
//  MessagesController.swift
//  InstagramFB
//
//  Created by David on 09/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    private let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        view.backgroundColor = .white
        
        setUpNavBarAndFetchMessagesForUser()
        
        tableView.allowsMultipleSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.handleTableReload()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerUid = messages[indexPath.row].chatPartnerUID() else { return }
        
        let ref = Database.database().reference().child("user-messages").child(userUid).child(chatPartnerUid)
        
        ref.removeValue { (error, reference) in
            if let error = error {
                print("Failed to delete message: ", error.localizedDescription)
                return
            }
            
            self.messagesDict.removeValue(forKey: chatPartnerUid)
            self.handleTableReload()
            
        }
        
    }
    
    var messages = [Message]()
    var messagesDict = [String: AnyObject]()
    var initialFullLoad = true
    
    private func observeUserMessages() {
        
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(currentUserUID)
        
        var counter = 0
        var numberOfTotalMessages = 0

        ref.observe(.childAdded, with: { (snapshot) in
            
            let userUID = snapshot.key
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(currentUserUID).child(userUID)
            
            userMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                numberOfTotalMessages = numberOfTotalMessages + Int(snapshot.childrenCount)
                print("Number of Messages: ", numberOfTotalMessages)
            })
            
            userMessagesRef.observe(.childAdded, with: { (snapshot) in
                
                let messageUID = snapshot.key
                
                let messagesRef = Database.database().reference().child("messages").child(messageUID)
                
                messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if self.initialFullLoad == false {
                        numberOfTotalMessages += 1
                    }
                    counter += 1
                
                    guard let dict = snapshot.value as? [String: AnyObject] else { return }
                    let message = Message(dictionary: dict)
                    
                    if let chatPartnerUID = message.chatPartnerUID() {
                        self.messagesDict[chatPartnerUID] = message
                    }
                    
                    if counter == numberOfTotalMessages {
                        self.handleTableReload()
                    }
                    
                }, withCancel: nil)
      
            }, withCancel: { (error) in
                print("Error fetching from user-messages node in DB: ", error.localizedDescription)
            })
        }) { (error) in
            print("Error fetching from user-messages node in DB: ", error.localizedDescription)
        }
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDict.removeValue(forKey: snapshot.key)
            self.handleTableReload()
            
        }) { (error) in
            print("Error removing the child from FB DB: ", error.localizedDescription)
        }
    }
    
    private func handleTableReload() {
        self.messages = Array(self.messagesDict.values) as! [Message]
        
        if self.messages.count > 2 {
            self.messages.sort(by: { (m1, m2) -> Bool in
                return m1.timeStamp! > m2.timeStamp!
            })
        }
        DispatchQueue.main.async {
            self.initialFullLoad = false
            print("Reloading Table")
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = self.messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let message = self.messages[indexPath.row]
        
        guard let chatPartnerUID = message.chatPartnerUID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerUID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String : AnyObject] else { return }
            let chatPartner = User(uid: chatPartnerUID, dictionary: dict)
            
            self.showChatLogControllerForUser(user: chatPartner)
            
        }) { (error) in
            print("Error fetching the chat partner from FB DB: ", error.localizedDescription)
        }
    }
    
    func showChatLogControllerForUser(user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.chatPartner = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    private func setUpNavBarAndFetchMessagesForUser() {
        navigationItem.title = "Direct"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonForMessagesController").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleGoingBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newChatButtonImg").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleNewChat))
        
        messages.removeAll()
        messagesDict.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
    }
    
    @objc func handleGoingBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNewChat() {
        let layout = UICollectionViewFlowLayout()
        let searchController = UserSearchController(collectionViewLayout: layout)
        searchController.sendingMessage = true
        searchController.messagesController = self
        let navController = UINavigationController(rootViewController: searchController)
        self.present(navController, animated: true, completion: nil)
    }
}
