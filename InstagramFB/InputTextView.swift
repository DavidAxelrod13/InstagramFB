//
//  InputTextView.swift
//  InstagramFB
//
//  Created by David on 06/01/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation
import UIKit

class InputTextView: UITextView, UITextViewDelegate {
    
    fileprivate let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .lightGray
        return lbl
    }()
    
    func showPlaceholderLabel() {
        placeholderLabel.isHidden = false
    }
    
    var placeholderText: String?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
    }
    
    convenience init(placeholderText: String, frame: CGRect = .zero, textContainer: NSTextContainer?) {
        self.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        self.placeholderText = placeholderText
        placeholderLabel.text = placeholderText
        
        addSubview(placeholderLabel)
        
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
}
