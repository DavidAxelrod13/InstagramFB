//
//  Comment.swift
//  InstagramFB
//
//  Created by David on 01/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

struct Comment {
    
    let user: User
    let commentText: String
    let commentorUid: String
    
    init(user: User, dict: [String: Any]) {
        
        self.user = user
        self.commentText = dict["commentText"] as? String ?? ""
        self.commentorUid = dict["commentorUid"] as? String ?? ""
        
    }
}
