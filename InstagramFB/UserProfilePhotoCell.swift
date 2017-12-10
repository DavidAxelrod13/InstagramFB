//
//  UserProfilePhotoCell.swift
//  InstagramFB
//
//  Created by David on 27/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let postImageDownloadUrl = post?.postImageDownloadUrl else { return }

            postPhotoImageView.loadImageWithUrlString(urlString: postImageDownloadUrl)
        }
    }
    
    
    let postPhotoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postPhotoImageView)
        
        postPhotoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
