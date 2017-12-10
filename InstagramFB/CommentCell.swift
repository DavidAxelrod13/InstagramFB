//
//  CommentCell.swift
//  InstagramFB
//
//  Created by David on 01/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
           
            guard let comment = self.comment else { return }
            
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " \(comment.commentText)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            self.textView.attributedText = attributedText
            
            profileImageView.loadImageWithUrlString(urlString: comment.user.profileImageDownloadUrl)
            
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false 
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40/2
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .purple
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(textView)
        addSubview(profileImageView)
        
        textView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
