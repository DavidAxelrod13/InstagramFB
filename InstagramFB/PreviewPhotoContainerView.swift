//
//  PreviewPhotoContainerView.swift
//  InstagramFB
//
//  Created by David on 30/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave() {
        
        guard let previewImage = previewImageView.image else { return }
        
        let photoLibrary = PHPhotoLibrary.shared()
        
        photoLibrary.performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success: Bool, error: Error?) in
            if let error = error {
                print("Error saving image to Photo Library: ", error.localizedDescription)
            }
            
            print("Success saving image to Photo Library")
            DispatchQueue.main.async {
                self.createAndDisplaySavedLabel()
            }
        }
    }
    
    fileprivate func createAndDisplaySavedLabel() {
       
        let savedLabel = UILabel()
        savedLabel.text = "Saved Successfully!"
        savedLabel.textColor = .white
        savedLabel.numberOfLines = 0
        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        savedLabel.textAlignment = .center
        
        // when animation is going to be involved easier to work with frams rather than anchor
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = self.center
        
        self.addSubview(savedLabel)
        
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            
        }) { (completed: Bool) in
            // now animate out once the first animation completed
            
            UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                
                savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                savedLabel.alpha = 0

            }, completion: { (completed: Bool) in
                // competed second animation
                
                savedLabel.removeFromSuperview()
            })
            
        }
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        cancelButton.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        saveButton.anchor(top: nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 24, width: 50, height: 50)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
