//
//  AuthService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/26/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import FBSDKLoginKit
import Firebase
import SwiftyUserDefaults

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    static var instance: AuthService {
        return _instance
    }
    
    
    func logIn(email: String, password: String, onComplete: Completion?){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                //Successfully logged in
                onComplete?(nil, user)
                Analytics.setUserID(user?.uid)
                Defaults[.key_uid] = user?.uid
                Defaults[.email] = email
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.logIn()
                
            }
        })
    }
    
    
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("Kurbs: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    DataService.instance.createFirebaseDBUser(user.uid, userData: userData)
                }
            }
        })
    }
    
    
    // Sign Up
    func signUp (name: String, email: String, password: String, pictureData: NSData? = nil, userType: String, onComplete: Completion?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("ERROR:\(String(describing: error?.localizedDescription))")
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                DataService.instance.setUserInfo(name: name, user: user, password: password, pictureData: pictureData, userType: userType)
            }
        })
    }
    
    
    // Handle Errors
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
                
                
                
//            case .errorCodeInvalidEmail:
//                onComplete?("Invalid email address", nil)
//                break
//            case .errorCodeWrongPassword:
//                onComplete?("Invalid password.", nil)
//                break
//            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
//                onComplete?("Could not create account. Email already in use.", nil)
//                break
//            case .errorCodeNetworkError:
//                onComplete?("The internet connection appears to be offline.", nil)
//                break
//            case .errorCodeUserNotFound:
//                onComplete?("User not found.", nil)
//                break
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
