//
//  EditProfileHeader.swift
//  InstagramFB
//
//  Created by David on 07/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class EditProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet{
            
            guard let user = user else { return }
            
            let dummyImageView = CustomImageView()
            dummyImageView.loadImageWithUrlString(urlString: user.profileImageDownloadUrl)
            let loadedImage = dummyImageView.image
            profileImageButton.setImage(loadedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
    }
        
    lazy var profileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "placeholder").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    lazy var changeProfilePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return button
    }()
    
    let aboveHeaderDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let belowHeaderDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.instagramSettingsWhite
        
        setupViews()
    }
    
    
    func setupViews() {
        
        addSubview(profileImageButton)
        addSubview(changeProfilePhotoButton)
        addSubview(aboveHeaderDividerLine)
        addSubview(belowHeaderDividerLine)
        
        profileImageButton.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageButton.anchorCenterXToSuperview()
        
        changeProfilePhotoButton.anchor(top: profileImageButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 20)
        changeProfilePhotoButton.anchorCenterXToSuperview()
        
        aboveHeaderDividerLine.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        belowHeaderDividerLine.anchor(top: bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
