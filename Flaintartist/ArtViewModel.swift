//
//  ArtViewModel.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-19.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import AVFoundation

struct ArtViewModel {
    
    let artID: String
    let imgUrl: String
    let title: String
    let description: String
    let price: NSNumber
    let type: String
    let artHeight: NSNumber
    let artWidth: NSNumber
    let postDate: NSNumber
    
    init(art: Art) {
        artID = art.artID
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

