//
//  UserProfileController.swift
//  InstagramFB
//
//  Created by David on 25/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let headerId = "headerId"
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var userId: String?
    
    var user: User?
    
    var isGridView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        fetchUser()
        
        setupLogoutButton()
        
    }
    
    var posts = [Post]()
    var isFinishedPaging: Bool = false
    
    fileprivate func paginatePosts() {
        
        guard let user = self.user else { return }
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        var query = ref.queryOrdered(byChild: "postCreationDate")
        
        if self.posts.count > 0 {
            let value = self.posts.last?.postCreationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dict: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
                
            })
            
            self.posts.forEach({ (post) in
                print(post.id ?? "")
            })
            
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Error paginating for posts in User Profile from FB DB: ", error.localizedDescription)
        }
    }
    
//    fileprivate func fetchOrderedPosts() {
//
//        guard let userUid = self.user?.uid else { return }
//
//        let ref = Database.database().reference().child("posts").child(userUid)
//
//        ref.queryOrdered(byChild: "postCreationDate").observe(.childAdded, with: { (snapshot) in
//
//            guard let dict = snapshot.value as? [String: Any] else { return }
//
//            guard let user = self.user else { return }
//
//            let post = Post(user: user, dict: dict)
//            self.posts.insert(post, at: 0)
//
//            DispatchQueue.main.async {
//                self.collectionView?.reloadData()
//            }
//
//        }) { (error) in
//             print("Error loading the posts from Database for the User Profile Controller: ", error.localizedDescription)
//        }
//    }

    fileprivate func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handelLogout))
    }
    
    @objc func handelLogout() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            
            do {
                try Auth.auth().signOut()
                
                // need to present login VC
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                 
            } catch let signOutError {
                print(signOutError.localizedDescription)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel action")
        }
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        
        header.delegate = self
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 {
            if !(isFinishedPaging) {
                print("Start pagination for more Posts")
                self.paginatePosts()
            }
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            
            cell.post = posts[indexPath.item]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            let width = view.frame.width
            
            var height: CGFloat = 40 + 8 + 8
            height += width
            height += 50
            height += 70
            
            return CGSize(width: width, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    fileprivate func fetchUser() {

        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")

        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = user.username

            self.collectionView?.reloadData()
            
            self.paginatePosts()
        }
    }
}

extension UserProfileController: UserProfileHeaderDelegate {
    func didChangeToListView() {
        self.isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        self.isGridView = true
        collectionView?.reloadData()
    }
    
    func didChooseToEditProfile() {
        let layout = UICollectionViewFlowLayout()
        let editProfileController = EditProfileController(collectionViewLayout: layout)
        editProfileController.user = self.user
        let navController = UINavigationController(rootViewController: editProfileController)
        self.present(navController, animated: true, completion: nil)
    }
    
}


