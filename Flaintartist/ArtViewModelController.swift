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
      fileprivate var viewModel: ArtViewModel!
    
    
    func retrieveVideos(_ completionBlock: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        let userMessagesRef = DataService.instance.REF_ARTISTARTS.child(Auth.auth().currentUser!.uid)
        
        userMessagesRef.observe(.value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        if let art = ArtViewModelController.parse(key, dictionary: postDict) {
                            strongSelf.viewModel = ArtViewModel(key: key, artData: postDict)
                            strongSelf.viewModels.append(art)
                            print("VIEWW MODELS: \(strongSelf.viewModels.count)")
                        }
                    }
                }
            }
            
            
            
//                guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                    completionBlock(false, nil)
//                    return
//                }
//                let key = snapshot.key
//
//                if let art = ArtViewModelController.parse(key, dictionary: dictionary) {
//                    strongSelf.viewModels.append(art)
//                }
              // strongSelf.viewModels = ArtViewModelController.initViewModels(arts)
                completionBlock(true, nil)
        }) { (error: Error) in
            completionBlock(false, error)
        }
    }
    
    
    
    var viewModelsCount: Int {
        return viewModels.count
    }
    
    
    func viewModel(at index: Int) -> ArtViewModel? {
        guard index <= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }
}




private extension ArtViewModelController {
    
    static func parse(_ key: String, dictionary: [String: AnyObject]) -> ArtViewModel? {
        print("DICTIO: \(dictionary)")
//        let artID = dictionary["artID"] as? String ?? ""
//        let imgUrl = dictionary["imageUrl"] as? String ?? ""
//        let title = dictionary["title"] as? String ?? ""
//        let description = dictionary["description"] as? String ?? ""
//        let price = dictionary["price"] as? NSNumber ?? 0
//        let type = dictionary["type"] as? String ?? ""
//        let height = dictionary["height"] as? NSNumber ?? 0
//        let width = dictionary["width"] as? NSNumber ?? 0
//        let postDate = dictionary["postDate"] as? NSNumber ?? 0
        return ArtViewModel(key: key, artData: dictionary)
    }
    
    
    static func initViewModels(_ arts: [Art?]) -> [ArtViewModel?] {
        print("SECOND VIDEO COUNT: \(arts.count)")
        return arts.map { art in
            if let art = art {
                return ArtViewModel(art: art)
            } else {
                return nil
            }
        }
    }
}
