//
//  HomeController.swift
//  InstagramFB
//
//  Created by David on 28/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView?.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: NotificationKey.UpdateFeed, object: nil)
        
        setupNavigationItems()
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserUIDs()
    }
    
    fileprivate func fetchFollowingUserUIDs() {
        guard let currentLoggedInUserUID = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(currentLoggedInUserUID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userUIDsDictionary = snapshot.value as? [String: Any] else { return }
            
            userUIDsDictionary.forEach({ (key, value) in
                
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
        }) { (error) in
            print("Error to fetch following user ids: ", error.localizedDescription)
        }
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "instagram"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cameraNew").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sendNew").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSend))
        
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    @objc func handleSend() {
        
        let messagesController = MessagesController()
        let navController = UINavigationController(rootViewController: messagesController)
        self.present(navController, animated: true, completion: nil)        
    }
    
    fileprivate func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                guard let dict = value as? [String: Any] else { return }
                
                var post = Post(user: user, dict: dict)
                post.id = key
                
                guard let userUid = Auth.auth().currentUser?.uid else { return }
                let ref = Database.database().reference().child("likes").child(key).child(userUid)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort(by: { (post1, post2) -> Bool in
                        return post1.postCreationDate.compare(post2.postCreationDate) == .orderedDescending
                    })
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }, withCancel: { (error) in
                    print("Error fetching Like information: ", error.localizedDescription)
                })
            })
        }) { (error) in
            print("Error fetching posts from Database: ", error.localizedDescription)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if posts.count != 0 {
            cell.post = posts[indexPath.item]
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        
        var height: CGFloat = 40 + 8 + 8
        height += width
        height += 50
        height += 70
        
        return CGSize(width: width, height: height)
    }
    
}

extension HomeController: HomePostCellDelegate {
    
    func didLike(for cell: HomePostCell) {
        
        print("Handling like inside the controler")
        
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.posts[indexPath.item]
        
        guard let postId = post.id else { return }
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("likes").child(postId)
        
        let values = [userUid: post.hasLiked == true ? 0 : 1]
        
        ref.updateChildValues(values) { (error: Error?, ref) in
            
            if let error = error {
                print("Error saving like to FB DB: ", error.localizedDescription)
                return
            }
            
            print("Sucess saving like for user uid: ", userUid)
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
            
        }
    }
    
    func didTapCommentButton(post: Post) {
        
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
        
    }
    
}




