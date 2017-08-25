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

}

