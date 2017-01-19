//
//  SearchControllerVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase

class SearchControllerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {

    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var swipeView: SwipeView!
    
    var users = [Users]()
    var filteredUsers = [Users]()
    var arts = [Art]()
    var filteredArts = [Art]()
    var searchController = UISearchController()
    var delegate: presentVCProtocol!
    var context = 0

    var layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        swipeView.delegate = self
        swipeView.dataSource = self
        swipeView.alignment = .edge
        swipeView.isPagingEnabled = true
        swipeView.itemsPerPage = 1
        swipeView.bounces = false
        swipeView.isScrollEnabled = false

        //segmentedCtrl.selectedSegmentIndex = 0
        loadInfo()

        view.addObserver(self, forKeyPath: "hidden", options: [ .new, .old ], context: &context)
    }
    

    
//    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
//        
//        if sender.selectedSegmentIndex == 0 {
//            swipeView.scrollToItem(at: 0, duration: 0.5)
//            searchController.searchBar.placeholder = "Explore Price"
//        } else if  segmentedCtrl.selectedSegmentIndex == 1 {
//            searchController.searchBar.placeholder = "Explore Artist"
//            swipeView.scrollToItem(at: 1, duration: 0.5)
//        }
//
//    }
//    
    //deinit { view.removeObserver(self, forKeyPath: "hidden") }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &self.context {
            if change?[NSKeyValueChangeKey.newKey] as? Bool == true {
                view.isHidden = false
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = users.filter { user in
            return user.name.lowercased().contains(searchText.lowercased())
        }
//        
//        filteredArts = arts.filter { art in
//            let price = "\(art.price)"
//            return price.lowercased().contains(searchText.lowercased())
//        }
//        
//        if segmentedCtrl.selectedSegmentIndex == 0 {
//          collectionView.reloadData()
//        }
        
//        else if segmentedCtrl.selectedSegmentIndex == 1 {
//          collectionView.reloadData()
//
//        } else if segmentedCtrl.selectedSegmentIndex == 2 {
//          collectionView.reloadData()
//        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        filterContentForSearchText(searchText: searchBarText)
        self.searchController = searchController
        collectionView.reloadData()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////            if searchController.isActive && searchController.searchBar.text != "" &&  segmentedCtrl.selectedSegmentIndex == 0 {
////                return filteredArts.count
////            } else {
//                return arts.count
////            }
        
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredUsers.count
            } else {
            return users.count
            }
      }




    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistViewCell", for: indexPath) as! ArtistViewCell
        let user: Users!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            
        }
        
        cell.artistImageView.sd_setImage(with: URL(string: "\(user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            
        return cell
    
//        else if segmentedCtrl.selectedSegmentIndex == 1 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistViewCell", for: indexPath) as! ArtistViewCell
//            let user: Users!
//            if searchController.isActive && searchController.searchBar.text != "" {
//                user = filteredUsers[indexPath.row]
//            } else {
//                user = users[indexPath.row]
//            }
//            
//            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
//                
//            }
//            
//            cell.artistImageView.sd_setImage(with: URL(string: "\(user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
//            cell.artistNameLbl.text = user.name
//            return cell
//
//        
//        }
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user: Users!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }

        collectionView.deselectItem(at: indexPath, animated: true)
        
        //performSegue(withIdentifier: "GalleryVC", sender: user)
        let navVC = storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
        let searchVC = storyboard!.instantiateViewController(withIdentifier: "SearchControllerNav") as! SearchNav
        //let vc = navVC.topViewController as! GalleryVC
        navVC.user = user
        //present(navVC, animated: true, completion: nil)
        searchVC.pushViewController(navVC, animated: true)
        
        let identifier = "GalleryVC"
        if((delegate?.responds(to: Selector(("performSegue:")))) != nil) {
            delegate?.performSeg(identifier, sender: user)
        }
    }
    

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
    
    func loadInfo() {
//        if segmentedCtrl.selectedSegmentIndex == 0 {
//            FIRDatabase.database().reference().child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
//                self.arts = []
//                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                    for snap in snapshot {
//                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                            let key = snap.key
//                            let art = Art(key: key, artData: postDict)
//                            self.arts.insert(art, at: 0)
//                        }
//                    }
//                }
//                self.collectionView.reloadData()
//            }
//        } else if segmentedCtrl.selectedSegmentIndex == 1 {
//            
//        }
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



extension SearchControllerVC: SwipeViewDelegate, SwipeViewDataSource {
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return 3
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        if index == 1 {
            self.collectionView = Bundle.main.loadNibNamed("ArtView", owner: self, options: nil)?[0] as! UICollectionView
                self.collectionView.register(UINib(nibName: "ArtViewCell", bundle: nil), forCellWithReuseIdentifier: "ArtViewCell")
                
                layout.scrollDirection = UICollectionViewScrollDirection.vertical
                //collectionView.setCollectionViewLayout(layout, animated: true)
                
                collectionView.delegate = self
                collectionView.dataSource = self

                return collectionView
        } else if index == 0 {
            
            self.collectionView = Bundle.main.loadNibNamed("ArtistView", owner: self, options: nil)?[0] as! UICollectionView
            self.collectionView.register(UINib(nibName: "ArtistViewCell", bundle: nil), forCellWithReuseIdentifier: "ArtistViewCell")
            
            layout.scrollDirection = UICollectionViewScrollDirection.vertical
            //collectionView.setCollectionViewLayout(layout, animated: true)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            return collectionView

            
        }
        
        return UIView()
    }

}

