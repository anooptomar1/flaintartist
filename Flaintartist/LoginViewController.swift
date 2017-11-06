//
//  LoginViewController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import FirebaseDatabase
import SwiftyUserDefaults


class LoginViewController {
    
    func retrieveUserInfo(_ userUID: String?, completionBlock: @escaping (_ success: Bool, _ error: Error?, _ user: User) -> ()) {
        let ref = DataService.instance.REF_USERS
        ref.child(userUID!).observe(.value) { (snapshot: DataSnapshot) in
            if  let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                print("USER INFO: \(postDict)")
                let key = snapshot.key
                let user = User(key: key, data: postDict)
                completionBlock(true, nil, user)
            }
        }
    }
}
