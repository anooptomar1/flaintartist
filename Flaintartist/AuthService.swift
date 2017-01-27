//
//  AuthService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/26/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import FirebaseAuth
import FirebaseDatabase
import SwiftyUserDefaults

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    

    func logIn(email: String, password: String, vc: UIViewController? = nil, onComplete: Completion?){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                //Successfully logged in
                onComplete?(nil, user)
                self.userType(id: (user?.uid)!)
                Defaults[.key_uid] = user?.uid
                Defaults[.email] = email

            }
        })
    }
    
    
    func userType(id: String) {
        let usersRef = FIRDatabase.database().reference().child("users").child(id)
        usersRef.observe(.value, with: { snapshot in
            if let type =  ((snapshot.value as? NSDictionary)?["userType"] as! String?) {
                if type == "artist" {
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logIn()
                }
            }
            return
        })
    }





    
    
//    func login(email: String, password: String, vc: UIViewController onComplete: Completion?) {
//        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
//            
//            if error != nil {
//                if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
//                    if errorCode == .errorCodeUserNotFound {
    
//                  }
//                } else {
//                    //Handle all other errors
//                    self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
//                }
//            } else {
//                //Successfully logged in
//                onComplete?(nil, user)
//            }
//            
//        })
//    }
//    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use", nil)
                break
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
