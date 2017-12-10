//
//  Post.swift
//  InstagramFB
//
//  Created by David on 27/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

struct Post {
    
    var id: String?
    
    let user: User
    let postImageDownloadUrl: String
    let postCaption: String
    let postCreationDate: Date
//    let postImageHeight: Int
//    let postImageWidth: Int
    
    var hasLiked: Bool = false
    
    init(user: User, dict: [String: Any])  {
        
        self.user = user
        self.postImageDownloadUrl = dict["postImageDownloadUrl"] as? String ?? ""
        self.postCaption = dict["postCaption"] as? String ?? ""
        
        let secondsFrom1970 = dict["postCreationDate"] as? Double ?? 0
        self.postCreationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
    }
}

