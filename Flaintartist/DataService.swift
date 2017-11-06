//
//  DataService.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Firebase
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
    
    var REF_USERS: DatabaseReference {
        return REF_BASE.child("users")
    }
    
//    var REF_USER_CURRENT: DatabaseReference {
//        if let uid = Defaults[.key_uid] {
//
//        }
//        return REF_USERS.child(uid!)
//    }
    
    var REF_ARTS: DatabaseReference {
        return REF_BASE.child("arts")
    }
    
    var REF_USERARTS: DatabaseReference {
        return REF_BASE.child("userArts")
    }
    
    
    var REF_STORAGE: StorageReference {
        return Storage.storage().reference()
    }
    
    var fileUrl: String?
    
    func saveCurrentUserInfo(name: String, website: String, email: String, phoneNumber: String, data: Data) {
        let user = Auth.auth().currentUser!
        let filePath = "\(String(describing: user.uid))/\(Int(NSDate.timeIntervalSinceReferenceDate))"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        REF_STORAGE.child(filePath).putData(data, metadata: metaData) { (metadata, error) in
            if let err = error {
                print("ERROR SAVE PROFILE IMAGE: \(err.localizedDescription)")
            }
            
            if !metadata!.downloadURLs![0].absoluteString.isEmpty {
                self.fileUrl = metadata!.downloadURLs![0].absoluteString
            }

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
            
            let userInfo : [String: Any] = ["email": email, "name": name, "website": website, "phoneNumber": phoneNumber, "profileImg": self.fileUrl!]
            let userRef = DataService.instance.REF_USERS.child((Auth.auth().currentUser?.uid)!)
            userRef.updateChildValues(userInfo)
        }
    }

    
    func createFirebaseDBUser(_ uid: String, userData: Dictionary<String, String>) {
       REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(userData)
    }
    
    func createNewArt(title: String, description: String, data: Data, completion: @escaping (_ success: Bool, _ error: Error?) -> ())  {
        let imgUID = NSUUID().uuidString
        let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
        let userUID = (Auth.auth().currentUser?.uid)!
        REF_STORAGE.child("Arts").child(userUID).child(imgUID).putData(data, metadata: metadata) { (metaData, error) in
            if let error = error {
                completion(false, error)
                return
            } else {
                let downloadURL = metaData?.downloadURL()!.absoluteString
                if let url = downloadURL {
                    let newArt: [String: Any] = [
                        "userUID": userUID as AnyObject, "title": title as AnyObject, "description": description as AnyObject, "imageUrl":  url as AnyObject
                    ]
                    self.REF_USERARTS.childByAutoId().updateChildValues(newArt)
                    completion(true, nil)
                }
            }
        }
    }
        
//        func saveArtDrawing(_ artID: String, data: Data){
//            let imgUID = NSUUID().uuidString
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            let userUID = (Auth.auth().currentUser?.uid)!
//            REF_STORAGE.child("ArtDrawings").child(userUID).child(imgUID).putData(data, metadata: metadata) { (metaData, error) in
//                if let error = error {
//                    print("ERROR: \(error)")
//                    //completion(false, error)
//                    return
//                } else {
//                    let downloadURL = metaData?.downloadURL()!.absoluteString
//                    if let url = downloadURL {
//                        print("URL: \(url)")
//                        let userArt = self.REF_ARTISTARTS.child(userUID).child(artID)
//                        userArt.updateChildValues(["drawingUrl": url])
//
//                }
//            }
//        }
//    }
}


