//
//  imageStore.swift
//  informedPublic
//
//  Created by Jonathon Day on 2/8/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation
import UIKit

class ImageStore {
    
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage {
        return cache.object(forKey: key as NSString)
    }
    
    func removeImage(forKey key: Stirng) {
        cache.removeObject(forKey: key as NSString)
    }
    
}
