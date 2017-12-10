//
//  SearchController.swift
//  InstagramFB
//
//  Created by David on 28/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    var sendingMessage: Bool = false
    
    var messagesController: MessagesController?
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.tintColor = .lightGray
        sb.delegate = self
        if let txfSearchField = sb.value(forKey: "_searchField") as? UITextField {
            txfSearchField.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        }
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.fileteredUsers = self.users
            
        } else {
            self.fileteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)   
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if sendingMessage {
            searchBar.showsCancelButton = true
        }
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavBar()
        
        fetchUsers()
        
    }
    
    private func setupNavBar() {
        let navBar = navigationController?.navigationBar
        
        navBar?.addSubview(searchBar)
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
        if sendingMessage {
            self.enableCancelButton(searchBar: searchBar)
        }
    }
    
    func enableCancelButton (searchBar : UISearchBar) {
        for view1 in searchBar.subviews {
            for view2 in view1.subviews {
                if view2.isKind(of: UIButton.self) {
                    let cancelButton = view2 as! UIButton
                    cancelButton.isEnabled = true
                    cancelButton.setTitleColor(UIColor.black, for: .normal)
                    cancelButton.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = fileteredUsers[indexPath.item]
        print(user.username)
        
        if sendingMessage == false {
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.userId = user.uid
            navigationController?.pushViewController(userProfileController, animated: true)
        } else if sendingMessage == true {
            self.messagesController?.showChatLogControllerForUser(user: user)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var fileteredUsers = [User]()
    var users = [User]()
    
    fileprivate func fetchUsers() {
        
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            
            dictionaries.forEach({ (key, value) in
               
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself, omit from list")
                    return
                }
                guard let userDict = value as? [String:Any] else {return}
                let user = User(uid: key, dictionary: userDict)
                self.users.append(user)
                
            })
            
            self.users.sort(by: { (user1, user2) -> Bool in
                
                return user1.username.compare(user2.username) == .orderedAscending
            })
            
            self.fileteredUsers = self.users
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Error to fetch users for search", error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = fileteredUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
}







