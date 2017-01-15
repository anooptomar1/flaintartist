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

class SearchControllerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating{

    @IBOutlet var collectionView: UICollectionView!
    
    var users = [Users]()
    var filteredUsers = [Users]()
    var searchController = UISearchController()
    var delegate: presentVCProtocol!
    var context = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
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
        
        view.addObserver(self, forKeyPath: "hidden", options: [ .new, .old ], context: &context)

    }
    
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
        
        collectionView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        filterContentForSearchText(searchText: searchBarText)
        self.searchController = searchController
        //collectionView.reloadData()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let user: Users!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            
        }
        
        cell.artistImageView.sd_setImage(with: URL(string: "\(user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
        cell.nameLbl.text = user.name
        return cell
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
        print("COL:\(user.name)")
        if((delegate?.responds(to: Selector(("performSegue:")))) != nil) {
            delegate?.performSeg(identifier, sender: user)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GalleryVC" {
//            let vc = segue.destination as! GalleryVC
//            if let user = sender as? Users {
//                vc.user = user
//            }
//        }
//    }
}



