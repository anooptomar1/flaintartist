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
    
    
    func facebookSignIn(viewController: UIViewController, onComplete: Completion?) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email", "public_profile"], from: viewController) { (result, error) in
            if error != nil {
                print("Kurbs: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("Kurbs: User cancelled Facebook authentication")
            } else {
                print("Kurbs: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                print("CREDENTIALS: \(credential.provider)")
                self.firebaseAuth(credential)
            }
        }
    }


    func firebaseAuth(_ credential: AuthCredential) {
        print("credential: AuthCredential)")
        var pictureUrl = ""
        
        Auth.auth().signIn(with: credential) { (user, error) in
            guard let uid = user?.uid else {
                return
            }
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("Kurbs: Successfully authenticated with Firebase")
                if let user = user {
                    print("PROVIDER")
                    let userData = ["provider": credential.provider]
                    
                    let profilePicRef = DataService.instance.REF_STORAGE.child(user.uid+"/profile_pic.jpg")
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.width(300).height(300)"])
                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                        if ((error) != nil) {
                            print("Error: \(String(describing: error))")
                        } else {
                            print("GRAPH REQUEST")

                            let values: [String:AnyObject] = result as! [String : AnyObject]
                            if let photURL = values["picture"] as? [String : AnyObject] {
                                let photoData = photURL["data"] as? [String : AnyObject]
                                let picUrl = photoData?["url"] as? String
                                pictureUrl = picUrl!
                            }
                            
                            Defaults[.name] = (values["name"] as? String)!
                            let name = values["name"] as? String
                            let email = values["email"] as? String
                            print("EMAIL: \(email)")
                            let userValues = ["id": uid,"name": name, "email": email, "pictureUrl": pictureUrl] as? [String : String]
                            if let imageData = NSData(contentsOf: URL(string: pictureUrl)! ) {
                                _ = profilePicRef.putData(imageData as Data, metadata: nil, completion: { (metadata, error) in
                                    if error == nil {
                                        
                                    } else {
                                    print("Error saving facebook image: \(String(describing: error?.localizedDescription))")
                                    }
                                })
                    
                            }
                            
                            DataService.instance.REF_USERS.child(uid).updateChildValues(userValues!, withCompletionBlock: { (error, ref) in
                                print(" DataService.instance.REF_USERS")

                                if error != nil {
                                    print("ERROR: \(String(describing: error?.localizedDescription))")
                                } else {
                                    self.completeSignIn(id: user.uid, userData: userData)
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        print("completeSignIn")
        DataService.instance.createFirebaseDBUser(id, userData: userData)
        Defaults[.key_uid] = id
        let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.logIn()
    }


    
    
//    func firebaseAuth(_ credential: AuthCredential) {
//        Auth.auth().signIn(with: credential, completion: { (user, error) in
//            if error != nil {
//                print("Kurbs: Unable to authenticate with Firebase - \(String(describing: error))")
//            } else {
//                print("Kurbs: Successfully authenticated with Firebase")
//                if let user = user {
//                    let userData = ["provider": credential.provider]
//                    DataService.instance.createFirebaseDBUser(user.uid, userData: userData)
//                }
//            }
//        })
//    }
    
    
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
            case .invalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .wrongPassword:
                onComplete?("Invalid password.", nil)
                break
            case .emailAlreadyInUse, .accountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use.", nil)
                break
            case .networkError:
                onComplete?("The internet connection appears to be offline.", nil)
                break
            case .userNotFound:
                onComplete?("User not found.", nil)
                break
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
