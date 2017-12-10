//
//  UserCell.swift
//  InstagramFB
//
//  Created by David on 11/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImage()
         
            self.lastMessageLabel.text = message?.text
            
            if let numberOfSecondsInt = message?.timeStamp {
                let tampStampDate = Date(timeIntervalSince1970: TimeInterval(numberOfSecondsInt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: tampStampDate)
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        
        if let uid = message?.chatPartnerUID() {
            let ref = Database.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String: AnyObject] else { return }
                
                self.usernameLabel.text = dict["username"] as? String
                if let profileImageUrl = dict["profileImageDownloadUrl"] as? String {
                    self.profileImageView.loadImageWithUrlString(urlString: profileImageUrl)
                }
                
            }, withCancel: { (error) in
                print("Error fetching user from FB DB: ", error.localizedDescription)
            })
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.text = "Sample last message text"
        return label
    }()
    
    let unreadMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.instagramBlueChatMessageBubble
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(usernameLabel)
        addSubview(lastMessageLabel)
        addSubview(unreadMessageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.anchorCenterYToSuperview()
        
        timeLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 30)
        
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: frame.width - 60, height: 40)
        usernameLabel.anchorCenterYToSuperview(constant: -10)
        
        lastMessageLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: frame.width - 60, height: 40)
        lastMessageLabel.anchorCenterYToSuperview(constant: 10)
        
        unreadMessageView.anchorCenterYToSuperview()
        unreadMessageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
