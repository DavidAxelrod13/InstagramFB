//
//  NotificationCenterKeys.swift
//  InstagramFB
//
//  Created by David on 29/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

struct NotificationKey {
    static let UpdateFeed = NSNotification.Name(rawValue: "kUpdateFeed")
}

struct Settings {
    static let attributeNames: [String] = ["Name", "Username", "Website", "Bio", "Email address", "Phone", "Gender"]
}

struct isString {
    static func blank(string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
}
