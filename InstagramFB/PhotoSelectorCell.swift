//
//  PhotoSelectorCell.swift
//  InstagramFB
//
//  Created by David on 26/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true 
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        addSubview(photoImageView)
        photoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
