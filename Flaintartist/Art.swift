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
    private var _artID: String!
    private var _imgUrl: String!
    private var _price: Int!
    private var _title: String!
    private var _description: String!
    private var _type: String!
    private var _artHeight: Int!
    private var _artWidth: Int!
    private var _artRef: DatabaseReference!
    private var _userUid: String!
    private var _userName: String = ""
    private var _profileImgUrl: String = ""
    private var _postDate: Int!
    
    var isPrivate: Bool = false
    
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
    
    var userName: String {
        return _userName
    }
    
    var profileImgUrl: String? {
        return _profileImgUrl
    }
    
    var postDate: Int {
        return _postDate
    }
    
    var price: Int {
        return _price
    }
    
    
    
    init(artID: String, imgUrl: String, price: Int, title: String, description: String, type: String, height: Int, width: Int, postDate: Int, isPrivate: Bool) {
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
        
        if let userName = artData["userName"] as? String {
            self._userName = userName
        }
        
        if let profileImgUrl = artData["profileImg"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        if let postDate = artData["postDate"] as? Int {
            self._postDate = postDate
        }
        
        if let price = artData["price"] as? Int {
            self._price = price
        }
        
        if let isPrivate = artData["private"] as? Bool {
            self.isPrivate = isPrivate
        }
        
       // _artRef = DataService.instance.REF_ARTS.child(self._artID)
    }
}
