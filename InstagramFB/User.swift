//
//  User.swift
//  InstagramFB
//
//  Created by David on 28/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

struct User {
    
    var uid: String
    var username: String
    var profileImageDownloadUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = (dictionary["username"] as? String) ?? ""
        self.profileImageDownloadUrl = (dictionary["profileImageDownloadUrl"] as? String) ?? ""
        self.uid = uid
    }
}

