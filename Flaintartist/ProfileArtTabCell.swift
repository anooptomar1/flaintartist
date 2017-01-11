//
//  ProfileArtTabCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/11/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase

class ProfileArtTabCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arts = [Art]()
    
    var art: Art!
    
    weak var delegate: presentVCProtocol?
    
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        FIRDatabase.database().reference().child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
            self.arts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Art(key: key, artData: postDict)
                        self.arts.insert(post, at: 0)
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}

extension ProfileArtTabCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModernColCell", for: indexPath) as? ProfileArtCell {
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                
            }
            cell.artImageView.sd_setImage(with: URL(string: "\(post.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            return cell
        } else {
            return ProfileArtCell()
        }
    }

}
