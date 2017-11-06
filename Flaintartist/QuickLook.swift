//
//  QuickLook.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import IGListKit

class QuickLook: NSObject{
    
    var title: String?
    var image: UIImage?
    var color: UIColor?
    
    init(title: String, image: UIImage, color: UIColor) {
        self.title = title
        self.image = image
        self.color = color
    }
}

extension QuickLook: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
}

