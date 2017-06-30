//
//  DataService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SwiftyUserDefaults

class DataService {
    
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    
    var REF_BASE: DatabaseReference {
        return Database.database().reference()
    }
    
    var REF_NEW:  DatabaseReference {
        return  REF_BASE.child("new")
    }

    
    
   
    
    var REF_USERS: DatabaseReference {
        return  REF_BASE.child("users")
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = Defaults[.key_uid]
        let user = REF_USERS.child(uid!)
        return user
    }

    
    var REF_ARTISTARTS: DatabaseReference {
        return REF_BASE.child("artistArts")
    }
    
    
    var REF_ARTS: DatabaseReference {
        return REF_BASE.child("arts")
    }
    
    
    var REF_REQUESTS: DatabaseReference {
        return REF_BASE.child("requests")
    }
    
    
    var REF_FAVORITES: DatabaseReference {
        return REF_BASE.child("favorites")
    }
    
    
    var REF_STORAGE: StorageReference {
        return Storage.storage().reference()
    }
    
    
    var REF_HISTORY: DatabaseReference {
        return REF_BASE.child("history")
    }

    
    func currentUserInfo(callback: @escaping (Users?) -> ())  {
        DataService.instance.REF_USER_CURRENT.observe(.value) { (snapshot: DataSnapshot) in
            if  let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = Users(key: key,artistData: postDict)
                callback(user)
            }
        }
    }

    var fileUrl: String?
    
    func saveCurrentUserInfo(name: String, website: String, email: String, phoneNumber: String,  gender: String, data: Data) {
        let user = Auth.auth().currentUser!
        let filePath = "\(String(describing: user.uid))/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        REF_STORAGE.child(filePath).putData(data, metadata: metaData) { (metadata, error) in
            if let err = error {
                print("ERROR SAVE PROFILE IMAGE: \(err.localizedDescription)")
            }
                        
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            let changeRequestProfile = user.createProfileChangeRequest()
            changeRequestProfile.photoURL = URL(string: self.fileUrl!)
            changeRequestProfile.displayName = name
            changeRequestProfile.commitChanges(completion: { (error) in
                if let error = error {
                    print("Error to commit photo change: \(error.localizedDescription)")
                } else {
                    
                }
            })
            
            user.updateEmail(to: email, completion: { (error) in
                if let error = error {
                        print("ERROR SAVING EMAIL: \(error.localizedDescription)")
                }
            })
        
            let userInfo = ["email": email, "name": name, "website": website, "phoneNumber": phoneNumber, "gender": gender, "profileImg": self.fileUrl!] as [String : Any]
            let userRef = DataService.instance.REF_USER_CURRENT
            userRef.updateChildValues(userInfo, withCompletionBlock: { (error, reference) in
                if error != nil {
                    print("ERROR:\(String(describing: error?.localizedDescription))")
                } else {
                    
                }
            }
        )}
    }
 
    
    func setUserInfo(name: String, user: User!, password: String, pictureData: NSData!, userType: String){
        self.saveUserInfo(name: name, user:user, password: password, userType: userType )
    }
    
    
    func saveUserInfo(name: String, user: User!, password: String? = nil, userType: String){
        let userInfo = ["name": name, "email": user.email!, "uid": user.uid, "userType": userType]
        DataService.instance.REF_USERS.child(user.uid).setValue(userInfo) { (error, ref) in
            DataService.instance.REF_USERS.removeAllObservers()
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
        let userArt = DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!).childByAutoId()
        let key = userArt.key
        let NewArt = DataService.instance.REF_ARTS.child(key)
        NewArt.updateChildValues(art)
        userArt.updateChildValues(art)
    }
    
    func createNew(_ new: Dictionary<String, AnyObject>) {
        let newRef = DataService.instance.REF_NEW.childByAutoId()
        let key = newRef.key
        let userArt = DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!).child(key)
        newRef.updateChildValues(new)
        userArt.updateChildValues(new)
    }
}

