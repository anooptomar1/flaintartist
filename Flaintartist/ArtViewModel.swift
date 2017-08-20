//
//  ArtViewModel.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-19.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import AVFoundation

struct ArtViewModel {
    
    var artID: String?
    var imgUrl: String?
    var title: String?
    var description: String?
    var price: NSNumber?
    var type: String?
    var artHeight: NSNumber?
    var artWidth: NSNumber?
    var postDate: NSNumber?
    
    init(art: Art) {
        title = art.title
        imgUrl = art.imgUrl
        description = art.description
        price = art.price
        type = art.type
        artHeight = art.artHeight
        artWidth = art.artWidth
        postDate = art.postDate
    }
    
    init(key: String, artData: Dictionary<String, AnyObject>) {
        
        self.artID = key
        
        if let title = artData["title"] as? String {
            self.title = title
        }
        
        if let description = artData["description"] as? String {
            self.description = description
        }
        
        if let type = artData["type"] as? String {
            self.type = type
        }
        
        if let height = artData["height"] as? NSNumber {
            self.artHeight = height
        }
        
        if let width = artData["width"] as? NSNumber {
            self.artWidth = width
        }
        
        if let img = artData["imageUrl"] as? String {
            self.imgUrl = img
        }
        
        
        if let postDate = artData["postDate"] as? NSNumber {
            self.postDate = postDate
        }
        
        if let price = artData["price"] as? NSNumber {
            self.price = price
        }
    }
}

