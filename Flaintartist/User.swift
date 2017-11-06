//
//  User.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class User {
    
    var profilePicUrl: String?
    var email: String?
    var name: String?
    var phoneNumber: String?
    var gender: String = "Not Specified"
    var artwork: Int?
    var bio: String?
    var website: String?
    var userId: String?
    //var userRef: DatabaseReference?
    var arts = [Art?]()
    
    init(key: String, data: Dictionary<String, AnyObject>) {
        
        self.userId = key
        
        if let userId = data["uid"] as? String {
            self.userId = userId
        }
        
        if let name = data["name"] as? String {
            self.name = name
        }
        
        if let email = data["email"] as? String {
            self.email = email
        }
        
        if let phoneNumber = data["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        
        if let gender = data["gender"] as? String {
            self.gender = gender
        }
        
        if let bio = data["biography"] as? String {
            self.bio = bio
        }
        
        if let profilePicUrl = data["profileImg"] as? String {
            self.profilePicUrl = profilePicUrl
        }
        
        if let website = data["website"] as? String {
            self.website = website
        }
        //self.userRef = DataService.instance.REF_USERS.child(self.userId!)
    }
}


extension User: Equatable {
    
    static public func ==(rhs: User, lhs: User) -> Bool {
        return  rhs.userId == lhs.userId
    }
}

extension User: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return userId! as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? User else { return false }
        
        return self.userId == object.userId
    }
}



