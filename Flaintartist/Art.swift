//
//  Art.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class Art {
    
    var artID: String?
    var imgUrl: String?
    var title: String?
    var description: String?
    var artHeight: NSNumber?
    var artWidth: NSNumber?
    var postDate: NSNumber?
    
    
    init(artID: String, imgUrl: String, price: NSNumber, title: String, description: String, type: String, height: NSNumber, width: NSNumber, postDate: NSNumber) {
        self.artID = artID
        self.imgUrl = imgUrl
        self.title = title
        self.description = description
        self.artHeight = height
        self.artWidth = width
        self.postDate = postDate
    }
    
    init(key: String, data: Dictionary<String, AnyObject>) {
        
        self.artID = key
        
        if let title = data["title"] as? String {
            self.title = title
        }
        
        if let description = data["description"] as? String {
            self.description = description
        }
        
        if let height = data["height"] as? NSNumber {
            self.artHeight = height
        }
        
        if let width = data["width"] as? NSNumber {
            self.artWidth = width
        }
        
        if let img = data["imageUrl"] as? String {
            self.imgUrl = img
        }
        
        if let postDate = data["postDate"] as? NSNumber {
            self.postDate = postDate
        }
        //_artRef = DataService.instance.REF_ARTS.child(self._artID)
    }
}

extension Art: Equatable {
    
    static public func ==(rhs: Art, lhs: Art) -> Bool {
        return  rhs.artID == lhs.artID
    }
}

extension Art: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return artID! as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? Art else { return false }
        
        return self.artID == object.artID
    }
}








