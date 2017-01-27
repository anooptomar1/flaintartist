//
//  DataService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ChameleonFramework
import SwiftyUserDefaults



let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage()
let STORAGE = FIRStorage.storage().reference()


class DataService {
    
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var alert = Alerts()
    
    private var _REF_BASE = DB_BASE
    private var _REF_AUTH = FIRAuth.auth()
    private var _REF_STORAGE = STORAGE_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_ARTS = DB_BASE.child("arts")
 
    
    // MAILGUN
    private var _REF_MAILGUN = Mailgun.client(withDomain: "sandbox9e1ee9467d7b4efcbe9fc7f8a93c8873.mailgun.org", apiKey: "key-93800f7299c38f6fc13ca91a5db68f95")
    
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var LogError: Bool?
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_AUTH : FIRAuth! {
        return _REF_AUTH
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_ARTS: FIRDatabaseReference {
        return _REF_ARTS
    }
    
    
    var REF_STORAGE: FIRStorage {
        return _REF_STORAGE
    }
    
    var REF_MAILGUN: Mailgun {
        return _REF_MAILGUN!
    }
    
    
    
//    // Log In
//    
//    func logIn(email: String, password: String, vc: UIViewController? = nil){
//        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
//            if error == nil {
//               self.userType(id: (user?.uid)!)
//                Defaults[.key_uid] = user?.uid
//                Defaults[.email] = email
//            }
//            else {
//                self.alert.showAlert("Error", message: "\(error!.localizedDescription)", target: vc!)
//                print(error!.localizedDescription)
//                
//            }
//        })
//    }
//    
//    
//    func userType(id: String) {
//        let usersRef = FIRDatabase.database().reference().child("users").child(id)
//        usersRef.observe(.value, with: { snapshot in
//            if let type =  ((snapshot.value as? NSDictionary)?["userType"] as! String?) {
//                if type == "artist" {
//                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDel.logIn()
//                }
//            }
//            return
//        })
//    }
//    

    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(error)")
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
    func signUp (name: String, email: String, password: String, pictureData: NSData!, userType: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.setUserInfo(name: name, user: user, password: password, pictureData: pictureData, userType: userType)
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    private func setUserInfo(name: String, user: FIRUser!, password: String, pictureData: NSData!, userType: String){
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        let imageRef = STORAGE.child(imagePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            
            if error == nil {
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = name
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        self.saveUserInfo(name: name, user:user, password: password, userType: userType )
                    }else{
                        print(error!.localizedDescription)
                        
                    }
                })
            }
            else {
                print(error!.localizedDescription)
            }
            
        }
    }
    
    
    func saveUserInfo(name: String, user: FIRUser!, password: String? = nil, userType: String){
        let userInfo = ["name": name, "email": user.email!, "uid": user.uid, "profileImg": String(describing: user.photoURL!), "userType": userType]
        DataService.instance.REF_USERS.child(user.uid).setValue(userInfo) { (error, ref) in
            if error == nil {
                print("user info saved successfully")
                AuthService.instance.logIn(email: user.email!, password: password!, onComplete: nil)
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    func createFirebaseDBUser(_ uid: String, userData: Dictionary<String, String>) {
        let newUser = DataService.instance.REF_USERS.child(uid)
        newUser.updateChildValues(userData)
    }
    
    
    func createNewArt(_ art: Dictionary<String, AnyObject>) {
        let userArt = DataService.instance.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").childByAutoId()
        let key = userArt.key
        let NewArt = DataService.instance.REF_ARTS.child(key)
        NewArt.updateChildValues(art)
        userArt.updateChildValues(art)
    }
    
    
    func storeProfileImg(_ uid: String, img: UIImage, vc: UIViewController) {
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let uid = uid
            metadata.contentType = "image/jpg"
            DataService.instance.REF_STORAGE.reference().child("users").child(uid).child("profileImg").put(imgData, metadata: metadata){(metaData,error) in
                if let error = error {
                    print(" Error saving img\(error.localizedDescription)")
                    return
                } else {
                    let downloadURL = metaData?.downloadURL()!.absoluteString
                    if downloadURL != nil {
                        let vc = CreateArtistSecondVC()
                        vc.profileUrl = downloadURL!
                    }
                    
                }
            }
        }
    }
}







