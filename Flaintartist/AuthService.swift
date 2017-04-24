//
//  AuthService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/26/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

//import FBSDKCoreKit
//import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyUserDefaults

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    static var instance: AuthService {
        return _instance
    }
    
    
    func logIn(email: String, password: String, onComplete: Completion?){
        print("LOGIN")
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                //Successfully logged in
                onComplete?(nil, user)
                self.userType(id: (user?.uid)!, email: email)
            }
        })
    }
    
    
//    func logIn_Fb(vc: UIViewController) {
//        let facebookLogin = FBSDKLoginManager()
//        facebookLogin.logIn(withReadPermissions: ["email"], from: vc) { (result, error) in
//            if error != nil {
//                print("KURBS: Unable to authenticate with Facebook - \(error)")
//            } else if result?.isCancelled == true {
//                print("KURBS: User cancelled Facebook authentication")
//            } else {
//                print("KURBS: Successfully authenticated with Facebook")
//                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                self.firebaseAuth(credential,  onComplete: nil)
//            }
//        }
//    }
    
    
//    
//    func firebaseAuth(_ credential: FIRAuthCredential, onComplete: Completion?) {
//        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
//            if error == nil {
//                print("Kurbs: Successfully authenticated with Firebase")
//                onComplete?(nil, user)
//                if let user = user {
//                    let ref = DataService.instance.REF_USERS.child(user.uid)
//                    
//                    let grapshRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture"])
//                    grapshRequest.start(completionHandler: { (connection, result, error) in
//                        if error != nil {
//                            // Process error
//                            print("Error: \(error)")
//                        } else {
//                            print("fetched user: \(result)")
//                            let values: [String:AnyObject] = result as! [String : AnyObject]
//                            
//                            ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
//                                if err != nil {
//                                    return
//                                }
//                                print("Save the user successfully into Firebase database")
//                            })
//                        }
//                        
//                    })
//                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDel.logIn()
//                }
//                
//                print("Kurbs: Unable to authenticate with Firebase - \(error)")
//            } else {
//                
//                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
//                
//            }
//        })
//    }
    
    
    func userType(id: String, email: String) {
        print("USER TYPE")
        print("USER ID :\(id)")
        let usersRef = FIRDatabase.database().reference().child("users").child(id)
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let type = (snapshot.value as! NSDictionary)["userType"] as! String
            let name = (snapshot.value as! NSDictionary)["name"] as! String
            if type == "artist" {
                queue.async(qos: .background) {
                    Defaults[.key_uid] = id
                    Defaults[.email] = email
                    Defaults[.name] = name
                    if let profileImg = (snapshot.value as! NSDictionary)["profileImg"] as? String {
                        print("TYPE: \(type)")
                    Defaults[.profileImg] = profileImg
                }
            }
        
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logIn()
                } else {
                    print("NOT ARTIST")
                    let instagramHooks = "flaint://user?username=jkurbs"
                    let instagramUrl = URL(string: instagramHooks)
                    if UIApplication.shared.canOpenURL(instagramUrl! as URL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(instagramUrl!)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                    } else {
                        //redirect to safari because the user doesn't have Instagram
                        print("App not installed")
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(URL(string: "https://itunes.apple.com/ca/app/flaint-artist/id1191196593?mt=8")!)
                        } else {
                            
                        }
                    }
                }
            usersRef.removeAllObservers()
            return
        })
    }
    
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
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
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
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
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid password.", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use.", nil)
                break
            case .errorCodeNetworkError:
                onComplete?("The internet connection appears to be offline.", nil)
                break
            case .errorCodeUserNotFound:
                onComplete?("User not found.", nil)
                break
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
