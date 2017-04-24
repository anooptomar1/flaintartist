//
//  SearchArtsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase


private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


class SearchArtsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController = UISearchController()
    var cell = SearchArtsCell()
    var arts = [Art]()
    var filteredArts = [Art]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false

        queue.async(qos: .userInitiated) {
            DataService.instance.REF_ARTS.queryLimited(toFirst: 10).observe(.value) { [weak self] (snapshot: FIRDataSnapshot) in
                self?.arts =  []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                            if isPrivate == false {
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let art = Art(key: key, artData: postDict)
                                    self?.arts.append(art)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.instance.REF_ARTS.removeAllObservers()
    }
    
    
    //MARK: Filter
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredArts = arts.filter { art in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return (art.type.lowercased().contains(searchText.lowercased()))
        }
    }
    
    //MARK: SearchResultDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        filterContentForSearchText(searchText: searchBarText)
        self.searchController = searchController
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive &&  searchController.searchBar.text != "" {
            return filteredArts.count
        } else {
            return arts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var art: Art!
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchArtsCell", for: indexPath) as? SearchArtsCell {
            self.cell = cell
            if searchController.isActive &&  searchController.searchBar.text != "" {
                art = filteredArts[indexPath.row]
            } else {
                art = arts[indexPath.row]
            }
            cell.otherScene.boxnode.removeFromParentNode()
            queue.async(qos: .background) {
                cell.configureCell(forArt: art, indexPath: indexPath)
            }
            return cell
        } else {
            return  SearchArtsCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var art: Art!
        if searchController.isActive && searchController.searchBar.text != "" {
            art = filteredArts[indexPath.row]
            
        } else {
            art = arts[indexPath.row]
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SearchArtsCell {
            if let artImage = cell.artImgView.image {
                let artInfo = [artImage, art] as [Any]
                let otherScene = cell.otherScene
                let artRoomVC = storyboard?.instantiateViewController(withIdentifier: "ArtRoomVC") as! ArtRoomVC
                artRoomVC.hidesBottomBarWhenPushed = true
                artRoomVC.artInfo = artInfo
                artRoomVC.position = otherScene.boxnode.position
                artRoomVC.rotation = otherScene.boxnode.rotation
                _ = navigationController?.pushViewController(artRoomVC, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 2
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
}

