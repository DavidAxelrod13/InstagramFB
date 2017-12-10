//
//  InfoCell.swift
//  InstagramFB
//
//  Created by David on 07/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

protocol EditProfileCellDelegate {
    
    func didEditAttribute(attributeName: String, newInfo: String) -> ()
}

class EditProfileInfoCell: UICollectionViewCell {
    
    var delegate: EditProfileCellDelegate?
    
    var name: String? {
        didSet{
            userEdittableTextField.text = name
        }
    }
    
    var username: String? {
        didSet{
            userEdittableTextField.text = username
        }
    }
    
    var email: String? {
        didSet{
            userEdittableTextField.text = email
        }
    }
    
    var attributeName: String? {
        didSet {
            attributeLabel.text = attributeName
        }
    }
    
    var userEdittableTextFieldPlaceholderText: String? {
        didSet{
            userEdittableTextField.placeholder = userEdittableTextFieldPlaceholderText
        }
    }
    
    
    let attributeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var userEdittableTextField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .whileEditing
        tf.font = UIFont.systemFont(ofSize: 13)
        tf.addTarget(self, action: #selector(handleAttributeEdit), for: .editingDidEnd)
        return tf
    }()
    
    @objc func handleAttributeEdit() {
        guard let attributeName = self.attributeLabel.text else { return }
        guard let newInfo = self.userEdittableTextField.text else { return }
        
        delegate?.didEditAttribute(attributeName: attributeName, newInfo: newInfo)
        
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupView()
        
    }
    
    private func setupView() {
        
        addSubview(attributeLabel)
        addSubview(userEdittableTextField)
        addSubview(dividerLine)
        
        attributeLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 95, height: 0)
        
        userEdittableTextField.anchor(top: topAnchor, left: attributeLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 14, width: 0, height: 0)
        
        dividerLine.anchor(top: bottomAnchor, left: userEdittableTextField.leftAnchor, bottom: nil, right: userEdittableTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
