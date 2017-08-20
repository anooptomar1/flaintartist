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
    
    fileprivate var viewModels: [ArtViewModel?] = []
    
    
    func retrieveVideos(_ completionBlock: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        let userMessagesRef = DataService.instance.REF_ARTISTARTS.child(Auth.auth().currentUser!.uid)
        
        userMessagesRef.observe(.childAdded, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            var arts = [Art?]()
            
            
            for child in snapshot.children {
                print("CHILD: \(child)")
                
            }
            
            
//            for item in snapshot.children {
//                let newItem = item as! DataSnapshot
//                guard let dictionary = newItem.value as? [String: AnyObject] else {
//                    completionBlock(false, nil)
//                    return
//                }
//
//                print("DIC: \(newItem)")
//
//                if let art = ArtViewModelController.parse(dictionary) {
//                    arts.append(art)
//                    print(arts.count)
//                }
//                strongSelf.viewModels = ArtViewModelController.initViewModels(arts)
//                completionBlock(true, nil)
//            }
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
    
    static func parse(_ dictionary: [String: Any]) -> Art? {
        let artID = dictionary["artID"] as? String ?? ""
        let imgUrl = dictionary["imageUrl"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let price = dictionary["price"] as? NSNumber ?? 0
        let type = dictionary["type"] as? String ?? ""
        let height = dictionary["height"] as? NSNumber ?? 0
        let width = dictionary["width"] as? NSNumber ?? 0
        let postDate = dictionary["postDate"] as? NSNumber ?? 0
        return Art(artID: artID, imgUrl: imgUrl, price: price, title: title, description: description, type: type, height: height, width: width, postDate: postDate)
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
