//
//  SimilarCol.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/23/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftMessages

class SimilarView: MessageView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var art = [Art]()
    var type = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SimilarCell")
        collectionView.backgroundColor = UIColor.white
        
        DataService.instance.REF_ARTS.queryOrdered(byChild: "type").queryEqual(toValue: type).queryLimited(toLast: 4).observe(.value) { [weak self] (snapshot: DataSnapshot) in
            self?.art = []
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                        if isPrivate == false {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let art = Art(key: key, artData: postDict)
                                self?.art.append(art)
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        self.addSubview(collectionView)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return art.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarCell", for: indexPath) as! SimilarCell
        cell.backgroundColor = UIColor.orange
        var forArt: Art!
        forArt = art[indexPath.row]
        cell.configureCell(forArt: forArt)
        return cell
    }
   
}
