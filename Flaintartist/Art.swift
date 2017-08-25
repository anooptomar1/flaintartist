//
//  Art.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct Art  {
    
    var artID: String?
    var imgUrl: String?
    var title: String?
    var price: NSNumber?
    var description: String?
    var type: String?
    var artHeight: NSNumber?
    var artWidth: NSNumber?
    var postDate: NSNumber?
    
    
    init(artID: String, imgUrl: String, price: NSNumber, title: String, description: String, type: String, height: NSNumber, width: NSNumber, postDate: NSNumber) {
        self.artID = artID
        self.imgUrl = imgUrl
        self.title = title
        self.price = price
        self.description = description
        self.type = type
        self.artHeight = height
        self.artWidth = width
        self.postDate = postDate
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
        
        
        //_artRef = DataService.instance.REF_ARTS.child(self._artID)
    }
}







