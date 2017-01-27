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

class DataService {
    
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var LogError: Bool?
    
    var REF_BASE: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var REF_USERS: FIRDatabaseReference {
        return  REF_BASE.child("users")
    }
    
    var REF_ARTS: FIRDatabaseReference {
        return REF_BASE.child("arts")
    }
    
    
    var REF_STORAGE: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var REF_MAILGUN: Mailgun {
        return Mailgun.client(withDomain: "sandbox9e1ee9467d7b4efcbe9fc7f8a93c8873.mailgun.org", apiKey: "key-93800f7299c38f6fc13ca91a5db68f95")
    }

    
   func setUserInfo(name: String, user: FIRUser!, password: String, pictureData: NSData!, userType: String){
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        let imageRef = REF_STORAGE.child(imagePath)
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
}

