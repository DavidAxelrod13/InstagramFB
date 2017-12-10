//
//  Firebase_Extension.swift
//  InstagramFB
//
//  Created by David on 28/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (_ user: User) -> ()) {
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDict = snapshot.value as? [String : Any] else { return }
            
            let user = User(uid: uid, dictionary: userDict)
            
            completion(user)
            
        }) { (error) in
            
            print("Error fetching user from Database: ", error.localizedDescription)
            
        }
        
    }
}
