//
//  AllVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase

class AllVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var posts = [Art]()
    var post: Art!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var type: String?
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.title = type
        collectionView.delegate = self
        collectionView.dataSource = self
        
        screenSize = view.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        DataService.ds.REF_ARTS.queryOrdered(byChild: "type").queryEqual(toValue : "\(type!)").observe(.value) { (snapshot: FIRDataSnapshot) in
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
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AllVC.refresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    func refresh(_ sender: AnyObject) {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllCell", for: indexPath) as? AllCell {
            
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                
            }
            
            cell.artImgView.sd_setImage(with: URL(string: "\(post.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            return cell
        } else {
            return AllCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? AllCell {
            if let artImage = cell.artImgView.image {
                let post = posts[indexPath.row]
                let artInfo = [artImage, post] as [Any]
                performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtRoomVC" {
            let vc = segue.destination as! ArtRoomVC
            vc.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                vc.artInfo = artInfo
                
            }
        }
    }
}
