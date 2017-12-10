//
//  EditProfileController.swift
//  InstagramFB
//
//  Created by David on 07/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let infoCellId = "infoCellId"
    private let headerId = "headerId"
    
    private var userEmail: String?
    
    var user: User? {
        didSet{
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.isScrollEnabled = true
        collectionView?.alwaysBounceVertical = true
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        collectionView?.register(EditProfileInfoCell.self, forCellWithReuseIdentifier: infoCellId)
        collectionView?.register(EditProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        setupNavBar()
        
        fetchCurrentUserEmail()
    }
      
    private func setupNavBar() {
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.backgroundColor = UIColor.instagramSettingsWhite
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleDoneButtonTap))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancelButtonTap))
    }
    
    private func fetchCurrentUserEmail() {
        self.userEmail = Auth.auth().currentUser?.email
    }
    
    @objc func handleDoneButtonTap() {
        self.view.endEditing(true)
        
        // save the data from
        
    }
    
    @objc func handleCancelButtonTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: infoCellId, for: indexPath) as! EditProfileInfoCell
        
        let settingName = Settings.attributeNames[indexPath.item]
        
        cell.attributeName = settingName
        cell.userEdittableTextFieldPlaceholderText = settingName
        cell.delegate = self
        
        if indexPath.item == 0 {
            // Users name
        } else if indexPath.item == 1 {
            cell.username = user?.username
        } else if indexPath.item == 4 {
            cell.email = self.userEmail
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Settings.attributeNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! EditProfileHeader
        header.user = self.user
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
}

extension EditProfileController: EditProfileCellDelegate {
    
    func didEditAttribute(attributeName: String, newInfo: String) {
        if attributeName == "Name" {
            if !(isString.blank(string: newInfo)) {
                
            }
        } else if attributeName == "Username" {
            if !(isString.blank(string: newInfo)) {
                
            }
        }
    }
}





