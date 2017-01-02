//
//  ModernTabCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase


class ModernTabCell: UITableViewCell {
    
    @IBOutlet weak var modernCollectionView: UICollectionView!
    
    var posts = [ArtModel]()
    
    var post: ArtModel!
    
    weak var delegate: presentVCProtocol?
    
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        FIRDatabase.database().reference().child("arts").queryOrdered(byChild: "type").queryEqual(toValue : "Modern").queryLimited(toFirst: 10).observe(.value) { (snapshot: FIRDataSnapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = ArtModel(key: key, artData: postDict)
                        self.posts.insert(post, at: 0)
                    }
                }
            }
            self.modernCollectionView.reloadData()
        }
    }
    
}

extension ModernTabCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModernColCell", for: indexPath) as? ModernColCell {
            if let img = AbstractTabCell.imageCache.object(forKey: post.imgUrl as NSString) {
                cell.configureCell(post, img: img)
            } else {
                cell.configureCell(post)
            }
            return cell
        } else {
            return ModernColCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ModernColCell {
            
            if let artImage = cell.artImgView.image {
                
                let post = posts[indexPath.row]
                
                let artInfo = [artImage, post] as [Any]
                
                collectionView.deselectItem(at: indexPath, animated: true)
                let identifier = "ArtRoomVC"
                if((delegate?.responds(to: Selector(("performSegue:")))) != nil) {
                    delegate?.performSeg(identifier, sender: artInfo)
                    
                }
            }
        }
    }
}
