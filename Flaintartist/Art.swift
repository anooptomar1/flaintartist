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
    
    var artID: String
    var imgUrl: String
    var title: String
    var price: NSNumber
    var description: String
    var type: String
    var artHeight: NSNumber
    var artWidth: NSNumber
    var postDate: NSNumber
    
    
    init(key: String, imgUrl: String, price: NSNumber, title: String, description: String, type: String, height: NSNumber, width: NSNumber, postDate: NSNumber) {
        self.artID = key
        self.imgUrl = imgUrl
        self.title = title
        self.price = price
        self.description = description
        self.type = type
        self.artHeight = height
        self.artWidth = width
        self.postDate = postDate
    }
 }
