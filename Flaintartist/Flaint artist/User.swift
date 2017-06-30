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
    
    var profilePicUrl: String?
    var name: String?
    var phoneNumber: String?
    var gender: String = "Not Specified"
    var artwork: Int?
    var bio: String?
    var website: String?
    var userId: String?
    var userRef: DatabaseReference?
    var arts = [Art?]()

    
    init(key: String, artistData: Dictionary<String, AnyObject>) {
        
        self.userId = key
        
        if let userId = artistData["uid"] as? String {
            self.userId = userId
        }
        
        if let name = artistData["name"] as? String {
            self.name = name
        }
        
        if let phoneNumber = artistData["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        
        if let gender = artistData["gender"] as? String {
            self.gender = gender
        }
        
        if let bio = artistData["biography"] as? String {
            self.bio = bio
        }
        
        if let profilePicUrl = artistData["profileImg"] as? String {
            self.profilePicUrl = profilePicUrl
        }
        
        if let website = artistData["website"] as? String {
            self.website = website
        }

        self.userRef = DataService.instance.REF_USERS.child(self.userId!)
    }
}


