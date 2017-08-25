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
    
      var viewModels: [ArtViewModel?] = []
      var arts = [Art]()
    
    
    func retrieveVideos(_ completionBlock: @escaping (_ success: Bool, _ error: Error?, _ arts: [Art], _ user: Users?) -> ()) {
        let ref =  DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!)
        ref.observe(.value, with: { [weak self] (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    guard let strongSelf = self else {return}
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let art = Art(key: key, artData: postDict)
                        strongSelf.arts.insert(art, at: 0)
                        DataService.instance.REF_USER_CURRENT.observe(.value) { (snapshot: DataSnapshot) in
                            if  let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                let key = snapshot.key
                                let user = Users(key: key,artistData: postDict)
                                completionBlock(true, nil, strongSelf.arts, user)
                            }
                        }
                    }
                }
            }
        })
    }

    var viewModelsCount: Int {
        return arts.count
    }
    
    
    func viewModel(at index: Int) -> Art? {
        guard index <= 0 && index < viewModelsCount else { return nil }
        return arts[index]
    }
}




private extension ArtViewModelController {
    
    static func initViewModels(_ arts: [Art?]) -> [ArtViewModel?] {
        return arts.map { art in
            if let art = art {
                return ArtViewModel(art: art)
            } else {
                return nil
            }
        }
    }
}
