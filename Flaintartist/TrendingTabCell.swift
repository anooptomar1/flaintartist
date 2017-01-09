//
//  TrendingTabCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase

class TrendingTabCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Art]()
    
    var post: Art!
    
    weak var delegate: presentVCProtocol?
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        FIRDatabase.database().reference().child("arts").queryOrdered(byChild: "type").queryEqual(toValue : "Abstract").queryLimited(toFirst: 10).observe(.value) { (snapshot: FIRDataSnapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Art(key: key, artData: postDict)
                        self.posts.insert(post, at: 0)
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}

extension TrendingTabCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingColCell", for: indexPath) as? TrendingColCell {
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                
            }
            cell.artImgView.sd_setImage(with: URL(string: "\(post.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            return cell
        } else {
            return TrendingColCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TrendingColCell {
            
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
