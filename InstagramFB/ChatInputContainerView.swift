//
//  CustomInputContaierView.swift
//  InstagramFB
//
//  Created by David on 10/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

protocol ChatInputContainerViewDelegate: class {
    func didTapOnUploadImageView() -> ()
    func didTapOnSendButton() -> ()
}

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    weak var delegate: ChatInputContainerViewDelegate?
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(handleSendTap), for: .touchUpInside)
        return button
    }()
    
    lazy var uploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "uploaderCam").withRenderingMode(.alwaysTemplate)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        return iv
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.white
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.delegate = self
        tf.placeholder = "Write a message..."
        return tf
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(uploadImageView)
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(seperatorLineView)
        
        uploadImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 34, height: 30)
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: self.frame.height)
        sendButton.anchorCenterYToSuperview()
        
        inputTextField.anchor(top: topAnchor, left: uploadImageView.rightAnchor, bottom: bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        seperatorLineView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.7)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didTapOnSendButton()
        return true
    }
    
    @objc func handleSendTap() {
        delegate?.didTapOnSendButton()
    }
    
    @objc func handleUploadTap() {
        delegate?.didTapOnUploadImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
