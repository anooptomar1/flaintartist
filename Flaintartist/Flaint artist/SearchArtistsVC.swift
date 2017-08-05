//
//  SearchArtistsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import CoreLocation
import Firebase
import SDWebImage
import SwiftyUserDefaults



private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}


class SearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allUsers = [Users]()
    var otherUsers = [Users]()
    var localUsers = [Users]()
    var filteredUsers = [Users]()
    var nearbyUsers = [String]()
    
    var typeOfArtist = ["Local Artists", "Other Artists"]
    
    var searchController = UISearchController()
    
    var geoFire: GeoFire!
    
    var context = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        findNearbyUsers()
        view.addObserver(self, forKeyPath: "hidden", options: [ .new, .old ], context: &context)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        allUsers.removeAll()
        otherUsers.removeAll()
        localUsers.removeAll()
        nearbyUsers.removeAll()
    }
    
    
    //MARK: Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &self.context {
            if change?[NSKeyValueChangeKey.newKey] as? Bool == true {
                view.isHidden = false
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    func findNearbyUsers(){
        weak var weakSelf = self
        let strongSelf = weakSelf!
        let location = CLLocation(latitude: Defaults[.latitude], longitude: Defaults[.longitude])
        let geoFireRef = DataService.instance.REF_BASE.child("users_location")
        strongSelf.geoFire = GeoFire(firebaseRef: geoFireRef)
        let circleQuery = geoFire!.query(at: location, withRadius: 1000)
        strongSelf.nearbyUsers = []
        queue.async(qos: .background) {
            _ = circleQuery!.observe(.keyEntered, with: { [weak self] (key, location) in
                if !(self?.nearbyUsers.contains(key!))! && key! != Auth.auth().currentUser!.uid {
                    self?.nearbyUsers.insert(key!, at: 0)
                    print("NEARBY USER: \(String(describing: self?.nearbyUsers))")
                }
            })
        }
        //Execute this code once GeoFire completes the query!
        circleQuery?.observeReady({
            queue.async(qos: .background) {
                DataService.instance.REF_USERS.queryOrdered(byChild: "userType").queryEqual(toValue: "artist").queryLimited(toFirst: 7).observe(.value, with: { [weak self] snapshot in
                    self?.allUsers = []
                    self?.localUsers = []
                    self?.otherUsers = []
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let User = Users(key: snap.key, artistData: postDict)
                                self?.allUsers.insert(User, at: 0)
                                if let nearbyUsers = strongSelf.nearbyUsers as? [String] {
                                    if nearbyUsers.count == 0 {
                                    }
                                    if nearbyUsers.contains(User.userId!) {
                                        self?.localUsers.insert(User, at: 0)
                                    } else {
                                        self?.otherUsers.insert(User, at: 0)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                })
            }
        })
    }
    
    
    //MARK: Filter
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = allUsers.filter { user in
            return (user.name?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
    
    //MARK: SearchResultDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        filterContentForSearchText(searchText: searchBarText)
        self.searchController = searchController
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: CollectionView
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ArtistHeaderView", for: indexPath) as! HeaderCollectionReusableView
        headerView.headerLbl.text = typeOfArtist[indexPath.section]
        return headerView
    }*/
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return typeOfArtist.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if  localUsers.count != 0 || !localUsers.isEmpty {
                if searchController.isActive &&  searchController.searchBar.text != "" {
                    return filteredUsers.count
                } else {
                    return localUsers.count
                }
            } else {
                return allUsers.count
            }
        } else if section == 1 {
            if searchController.isActive &&  searchController.searchBar.text != "" {
                typeOfArtist[1] = ""
                return 0
            }
            typeOfArtist[1] = "Other Artists"
            return otherUsers.count
        } else {
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as? SearchCell {
            var user: Users!
            if indexPath.section == 0 && !localUsers.isEmpty {
                if searchController.isActive &&  searchController.searchBar.text != "" {
                    typeOfArtist[0] = "All Artists"
                    user = filteredUsers[indexPath.row]
                } else {
                    typeOfArtist[0] = "Local Artists"
                    user = localUsers[indexPath.row]
                }
            }
            
            if indexPath.section == 1 {
                if searchController.isActive && searchController.searchBar.text != "" {
                    typeOfArtist[1] = ""
                    user = nil
                } else {
                    typeOfArtist[1] = "Other Artists"
                    user = otherUsers[indexPath.row]
                }
            }
            cell.configureCell(forUser: user)
            return cell
        }
        return SearchCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var user: Users!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
            
        } else {
            user = localUsers[indexPath.row]
            if indexPath.section == 1 {
                user = otherUsers[indexPath.row]
            }
        }
        
        let galleryVC = storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
        galleryVC.user = user
        galleryVC.hidesBottomBarWhenPushed = true
        _ = navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
    
    
    //MARK: Hide Keyboard
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
    // MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GalleryVC" {
            guard let destination = segue.destination as? UINavigationController
                else { fatalError("unexpected view controller for segue") }
            let galleryVC = destination.topViewController as! GalleryVC
            galleryVC.user = sender as! Users
        }
    }
}

