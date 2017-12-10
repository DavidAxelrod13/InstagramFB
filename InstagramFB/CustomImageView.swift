//
//  CustomImageView.swift
//  InstagramFB
//
//  Created by David on 27/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()
class CustomImageView: UIImageView {
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImageWithUrlString(urlString: String) {
        
        self.image = nil
        
        lastUrlUsedToLoadImage = urlString
        
        if let alreadyCachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = alreadyCachedImage
            return
        }

        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Error fetching the post image: ", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode != 200 { return }
            
            if url.absoluteString != self.lastUrlUsedToLoadImage { return }
            
            guard let data = data else { return }
            
            let postImage = UIImage(data: data)
            
            guard let image = postImage else {return}
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                self.image = image
            }
            
        }.resume()
    }
}
