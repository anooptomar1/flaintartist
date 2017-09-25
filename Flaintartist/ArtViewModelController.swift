//
//  ArtViewModelController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-19.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class ArtViewModelController {
    
  var arts = [Art]()
    
    func retrieveArts(_ completionBlock: @escaping (_ success: Bool, _ error: Error?, _ arts: [Art]) -> ()) {
        DataService.instance.REF_ARTISTARTS.child(Auth.auth().currentUser!.uid).observe(.value, with: { [weak self] (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    guard let strongSelf = self else {return}
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let storie = Art(key: key, data: postDict)
                        strongSelf.arts.insert(storie, at: 0)
                        completionBlock(true, nil, strongSelf.arts)
                    }
                }
            }
        })
    }
}

