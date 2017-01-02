//
//  Art.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ArtModel {
    
    fileprivate var _artID: String!
    fileprivate var _imgUrl: String!
    fileprivate var _price: Int!
    fileprivate var _title: String!
    fileprivate var _description: String!
    fileprivate var _type: String!
    fileprivate var _artHeight: Int!
    fileprivate var _artWidth: Int!
    fileprivate var _artLenght: Int!
    fileprivate var _artRef: FIRDatabaseReference!
    fileprivate var _userUid: String!
    fileprivate var _postDate: Int!
    
    
    
    var title: String {
        return _title
    }
    
    var description: String {
        return _description
    }
    
    var type: String {
        return _type
    }
    
    var artHeight: Int {
        return _artHeight
    }
    
    var artWidth: Int {
        return _artWidth
    }
    
    var imgUrl: String {
        return _imgUrl
    }
    
    var artID: String {
        return _artID
    }
    
    var userUid: String {
        return _userUid
    }
    
    var postDate: Int {
        return _postDate
    }
    
    var price: Int {
        return _price
    }
    
    init(artID: String, imgUrl: String, price: Int, title: String, description: String, type: String, height: Int, width: Int, postDate: Int) {
        self._artID = artID
        self._imgUrl = imgUrl
        self._title = title
        self._description = description
        self._type = type
        self._artHeight = height
        self._artWidth = width
        self._postDate = postDate
        self._price = price
        
    }
    
    init(key: String, artData: Dictionary<String, AnyObject>) {
        
        self._artID = key
        
        if let userUId = artData["userUID"] as? String {
            self._userUid = userUId
        }
        
        if let title = artData["title"] as? String {
            self._title = title
        }
        
        if let description = artData["description"] as? String {
            self._description = description
        }
        
        if let type = artData["type"] as? String {
            self._type = type
        }
        
        if let height = artData["height"] as? Int {
            self._artHeight = height
        }
        
        if let width = artData["width"] as? Int {
            self._artWidth = width
        }
        
        if let img = artData["imageUrl"] as? String {
            self._imgUrl = img
        }
        
        if let postDate = artData["postDate"] as? Int {
            self._postDate = postDate
        }
        
        if let price = artData["price"] as? Int {
            self._price = price
        }
        
        _artRef = DataService.ds.REF_ARTS.child(self._artID)
    }
}


