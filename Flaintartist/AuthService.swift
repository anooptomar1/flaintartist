//
//  AuthService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Firebase
import SwiftyUserDefaults

typealias Completion = (_ success: Bool?, _ error: Error?) -> Void

class AuthService {
    private static let _instance = AuthService()
    static var instance: AuthService {
        return _instance
    }
    
    var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()

    
    func signIn(email: String, password: String, completion: @escaping Completion){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                completion(false, error)
                //self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
            
                
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                user?.link(with: credential) { (user, error) in
                    // ...
                }
                completion(true, nil)
                //Successfully logged in
                Analytics.setUserID(user?.uid)
                Defaults[.key_uid] = user?.uid
                Defaults[.email] = email
                DispatchQueue.main.async {
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logIn()
                }
            }
        })
    }
    
    
    func completeLogIn(_ credential: AuthCredential){
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            user?.link(with: credential) { (user, error) in
                print("USERRR: \(user?.email)")
            }
            guard let uid = user?.uid else {
                return
            }
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                Defaults[.key_uid] = uid
                DispatchQueue.main.async {
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logIn()
                }
            }
        })
    }
    
    
    // Sign Up
    func signUp (name: String, email: String, password: String, completion: @escaping Completion) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("ERROR:\(String(describing: error?.localizedDescription))")
                completion(false, error)
            } else {

               let userInfo = ["name": name, "email": email, "uid": user!.uid]
                self.completeSignIn(id: user!.uid, userData: userInfo)
                completion(true, nil)
            }
        })
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.instance.createFirebaseDBUser(id, userData: userData)
        Defaults[.key_uid] = id
        DispatchQueue.main.async {
            let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDel.logIn()
        }
    }
}

