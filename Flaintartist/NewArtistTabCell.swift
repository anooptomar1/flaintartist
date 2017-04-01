//
//  NewArtistTabCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/27/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseStorage
import FirebaseDatabase


class NewArtistTabCell: UITableViewCell {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var users = [Users]()
    
    var user: Users!
    
    weak var delegate: presentVCProtocol?
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        FIRDatabase.database().reference().child("users").queryOrdered(byChild: "userType").queryEqual(toValue : "artist").observe(.value) { (snapshot: FIRDataSnapshot) in
            self.users = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let User = Users(key: key, artistData: postDict)
                        self.users.insert(User, at: 0)
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}


extension NewArtistTabCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = users[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArtistColCell", for: indexPath) as? NewArtistCell {
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                
            }
            cell.artistImageView.sd_setImage(with: URL(string: "\(user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            cell.artistNameLbl.text = user.name
            return cell
        } else {
            return NewArtistCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let user = users[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        let identifier = Seg_GalleryVC
        if((delegate?.responds(to: Selector(("performSegue:")))) != nil) {
            delegate?.performSeg(identifier, sender: user)
        }
    }
}

