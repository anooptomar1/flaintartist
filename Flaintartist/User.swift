//
//  User.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class Users {
    
    fileprivate var _profilePicUrl: String!
    fileprivate var _name: String!
    fileprivate var _artwork: Int!
    fileprivate var _color: String!
    fileprivate var _website: String!
    fileprivate var _userType: String!
    fileprivate var _userId: String!
    fileprivate var _userRef: FIRDatabaseReference!
    fileprivate var _arts = [Art?]()
    
    
    var userId: String? {
        return _userId
    }
    
    var profilePicUrl: String? {
        return _profilePicUrl
    }
    
    var name: String {
        return _name
    }
    
    var artwork: Int {
        return _artwork
    }
    
    var userType: String {
        return _userType
    }
    
    var website: String? {
        return _website
    }
    
    var art: [Art?] {
        return _arts
    }

    init(userId: String ,profilePicUrl: String, name: String, userType: String, website: String, artwork: Int, art: [Art]) {
        
        self._profilePicUrl = profilePicUrl
        self._name = name
        self._artwork = artwork
        self._website = website
        self._userId = userId
        self._arts = art
    }
    
    init(key: String, artistData: Dictionary<String, AnyObject>) {
        
        self._userId = key
        
        if let userId = artistData["uid"] as? String {
            self._userId = userId
        }
        
        if let name = artistData["name"] as? String {
            self._name = name
        }
        
        if let profilePicUrl = artistData["profileImg"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let website = artistData["website"] as? String {
            self._website = website
        }
        
        if let type = artistData["userType"] as? String {
            self._userType = type
        }
        
        
        
        self._userRef = DataService.instance.REF_USERS.child(self._userId)
    }
}


