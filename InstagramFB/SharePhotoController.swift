//
//  SharePhotoController.swift
//  InstagramFB
//
//  Created by David on 27/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            self.postPhotoImageView.image = selectedImage
        }
    }
    
    let postPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let postCaptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    fileprivate func setupImageAndTextViews() {
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(postPhotoImageView)
        containerView.addSubview(postCaptionTextView)
        
        postPhotoImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        postCaptionTextView.anchor(top: containerView.topAnchor, left: postPhotoImageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handleShare() {
        
        guard let caption = postCaptionTextView.text, caption.count > 0 else { return }
        
        guard let postImage = selectedImage else { return }
        guard let postImageData = UIImageJPEGRepresentation(postImage, 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let postUid = UUID().uuidString
        Storage.storage().reference().child("posts").child(postUid).putData(postImageData, metadata: nil) { (metadata, error: Error?) in
            
            if error != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error uploading post image to Storage: ", error!.localizedDescription)
                return
            }
            
            guard let postImageDownloadUrl = metadata?.downloadURL()?.absoluteString else { return }

            self.saveToDatabaseWithImageUrl(postImageDownloadUrl: postImageDownloadUrl)
        }
    }
    
    
    fileprivate func saveToDatabaseWithImageUrl(postImageDownloadUrl: String) {
        
        guard let postImage = selectedImage else { return }
        
        let postImageWidth = postImage.size.width
        let postImageHeight = postImage.size.height
        
        let postCreationDate = Date().timeIntervalSince1970
        
        guard let postCaption = postCaptionTextView.text else { return }
        
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(userUid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["postImageDownloadUrl": postImageDownloadUrl, "postCaption" : postCaption, "postImageWidth" : postImageWidth, "postImageHeight" : postImageHeight, "postCreationDate" : postCreationDate] as [String : Any]
        
        ref.updateChildValues(values) { (error, ref) in
            
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error uploading post values to Database: ", error.localizedDescription)
                return
            }
            
            print("Success saving post to the Database")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: NotificationKey.UpdateFeed, object: nil)

        }
    }
}




