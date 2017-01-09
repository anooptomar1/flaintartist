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


class DataService {
    
    static var ds = DataService()
    
    var alert = Alerts()
    
    private var _REF_BASE = DB_BASE
    private var _REF_AUTH = FIRAuth.auth()
    private var _REF_STORAGE = STORAGE_BASE
    private var _REF_POSTS = DB_BASE.child("arts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_ARTS = DB_BASE.child("arts")
    private var _REF_RESTO = DB_BASE.child("restaurant")
    private var _REF_CURRENT_RESTO = DB_BASE.child("restaurant").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    // MAILGUN
//    private var _REF_MAILGUN = Mailgun.client(withDomain: "sandbox9e1ee9467d7b4efcbe9fc7f8a93c8873.mailgun.org", apiKey: "key-93800f7299c38f6fc13ca91a5db68f95")
    
    
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
    
//    var REF_MAILGUN: Mailgun {
//        return _REF_MAILGUN!
//    }
    
    
    
    // Log In
    
    func logIn(email: String, password: String, vc: UIViewController){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
               self.userType(id: (user?.uid)!)
            }
            else {
                self.alert.showAlert("Error", message: "\(error!.localizedDescription)", target: vc)
                print(error!.localizedDescription)
                
            }
        })
    }
    
    
    func userType(id: String) {
        let usersRef = FIRDatabase.database().reference().child("users").child(id)
        usersRef.observe(.value, with: { snapshot in
            if let type =  ((snapshot.value as? NSDictionary)?["userType"] as! String?) {
                if type == "artist" {
                    Defaults[.key_uid] = id
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logIn()
                }
            }
            return
        })
    }
    

    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Kurbs: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    DataService.ds.createFirebaseDBUser(user.uid, userData: userData)
                }
            }
        })
    }
    
    
    // Register
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    func createFirebaseDBUser(_ uid: String, userData: Dictionary<String, String>) {
        let newUser = DataService.ds.REF_USERS.child(uid)
        newUser.updateChildValues(userData)
    }
    
    
    func createNewArt(_ art: Dictionary<String, AnyObject>) {
        let userArt = DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").childByAutoId()
        let key = userArt.key
        let NewArt = DataService.ds.REF_ARTS.child(key)
        NewArt.updateChildValues(art)
        userArt.updateChildValues(art)
    }
    
    
    func storeProfileImg(_ uid: String, img: UIImage, vc: UIViewController) {
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let uid = uid
            metadata.contentType = "image/jpg"
            DataService.ds.REF_STORAGE.reference().child("users").child(uid).child("profileImg").put(imgData, metadata: metadata){(metaData,error) in
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







