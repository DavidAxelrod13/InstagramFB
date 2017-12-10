//
//  Message.swift
//  InstagramFB
//
//  Created by David on 11/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    //NEW
    var messageUID: String?

    var fromUserUID: String?
    var text: String?
    var timeStamp: Int?
    var toUserUID: String?
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        fromUserUID = dictionary["fromUserUID"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? Int
        toUserUID = dictionary["toUserUID"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
    }
    
    func chatPartnerUID() -> String? {
        if fromUserUID == Auth.auth().currentUser?.uid {
            return toUserUID
        } else {
            return fromUserUID
        }
    }
}
