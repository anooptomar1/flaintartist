//
//  HistoryVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/8/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SDWebImage
import FirebaseAuth
import DZNEmptyDataSet
import FirebaseDatabase


class HistoryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arts = [Art]()
    var art: Art!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        queue.async(qos: .userInitiated) {
            let ref =  DataService.instance.REF_HISTORY.child((FIRAuth.auth()?.currentUser?.uid)!)
            ref.queryLimited(toFirst: 10).observe(.value, with: { [weak self] (snapshot) in
                self?.arts = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let art = Art(key: key, artData: postDict)
                            self?.art = Art(key: key, artData: postDict)
                            self?.arts.append(art)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.arts = []
        DataService.instance.REF_HISTORY.child((FIRAuth.auth()?.currentUser?.uid)!).removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as? HistoryCell {
            cell.otherScene.boxnode.removeFromParentNode()
            cell.configureCell(forArt: art, indexPath: indexPath)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! HistoryCell
        if let artImage = cell.imageView.image {
            let artInfo = [artImage, art] as [Any]
            let artRoomVC = storyboard?.instantiateViewController(withIdentifier: "ArtRoomVC") as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            artRoomVC.artInfo = artInfo
            _ = navigationController?.pushViewController(artRoomVC, animated: true)
        }
    }
    
    //MARK: DZNEmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no history yet. Go explore Captain!"
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}
