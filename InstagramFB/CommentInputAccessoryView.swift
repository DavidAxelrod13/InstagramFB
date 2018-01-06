//
//  CommentInputAccessoryView.swift
//  InstagramFB
//
//  Created by David on 06/01/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import UIKit

protocol CommentInputAccessoryViewDelegate: class {
    func didSubmit(forComment comment: String)
}

class CommentInputAccessoryView: UIView {
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    func clearComment() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    lazy var submitButton: UIButton = {
        let but = UIButton(type: .system)
        but.setTitle("Submit", for: .normal)
        but.setTitleColor(.black, for: .normal)
        but.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        but.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return but
    }()
    
    fileprivate let commentTextView: InputTextView = {
        let tv = InputTextView(placeholderText: "Enter Comment ...", textContainer: nil)
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    fileprivate let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return view
    }()
    
    // 2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        // 1
        autoresizingMask = .flexibleHeight
        
        setupSubviews()
        
    }
    
    fileprivate func setupSubviews() {
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: nil, right:  rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        addSubview(commentTextView)
        // 3
        if #available(iOS 11.0, *) {
            commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        } else {
            // Fallback on earlier versions
        }
        
        addSubview( dividerLineView)
        dividerLineView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.8)
    }
    
    
    @objc private func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        delegate?.didSubmit(forComment: commentText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
