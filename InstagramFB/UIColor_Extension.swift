//
//  UIColor_Extension.swift
//  InstagramFB
//
//  Created by David on 28/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    static let instagramSettingsWhite = UIColor.rgb(red: 250, green: 250, blue: 250)
    
    static let instagramBlueChatMessageBubble = UIColor.rgb(red: 0, green: 137, blue: 249)
}
