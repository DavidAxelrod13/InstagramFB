//
//  CommentsController.swift
//  InstagramFB
//
//  Created by David on 01/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = .white
        
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
    }
    
    var commentsForPost = [Comment]()
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        
        let ref = Database.database().reference().child("comments").child(postId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            
            guard let commentorUid = dict["commentorUid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: commentorUid, completion: { (user) in
                
                let comment = Comment(user: user, dict: dict)
                self.commentsForPost.append(comment)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            })
            
        }) { (error) in
            print("Error observing the comments in FB DB: ", error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false 
    }
    
    lazy var commentContainerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = commentsForPost[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsForPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = commentsForPost[indexPath.item]
        dummyCell.layoutIfNeeded()

        let estimatedSize = dummyCell.systemLayoutSizeFitting(UILayoutFittingExpandedSize)

        let height = max(40 + 8 + 8, estimatedSize.height)

        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    override var inputAccessoryView: UIView? {
        get {
            return commentContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension CommentsController: CommentInputAccessoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        guard let commentorUid = Auth.auth().currentUser?.uid else { return }
        if comment.isEmpty { return } 
        guard let postId = self.post?.id else { return }
        
        let ref = Database.database().reference().child("comments").child(postId).childByAutoId()
        let values = ["commentText": comment, "commentCreationDate": Date().timeIntervalSince1970, "commentorUid" : commentorUid] as [String : Any]
        
        ref.updateChildValues(values) { (error: Error?, ref) in
            if let error = error {
                print("Error saving comment to FB DB: ", error.localizedDescription)
                return
            }
            print("Success saving comment to FB DB")
            
            self.commentContainerView.clearComment()
        }
    }
}
