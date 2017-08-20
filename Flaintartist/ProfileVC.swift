//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//
import UIKit
import Firebase
import SceneKit
import SDWebImage
import SwiftMessages
import DZNEmptyDataSet
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // Info Outlet
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    
    var user: Users?
    var arts = [Art]()
    var filteredArts = [Art]()
    var art: Art?
    var artImg = UIImage()
    let refreshCtrl = UIRefreshControl()
    var tapGesture = UITapGestureRecognizer()
    var segmentedCtrl = UISegmentedControl()
    var searchController = UISearchController()
    
    weak var detailsView: EditArtDetails!
    
    var v: UIImageView?
    var pageControl: FlexiblePageControl!

    var cell: ProfileArtCell?
    var bottomViewIsTapped: Bool = true
    var cameraBtnIsTapped: Bool = true
    
    var galleryIndexPath: IndexPath?
    
    enum MyBool {
        case True
        case False
    }
    
    var b = MyBool.False
    
    fileprivate let artViewModelController = ArtViewModelController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setupViews()
        addGestures()
        
        artViewModelController.retrieveVideos { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                    let title = "Error"
                    if let error = error {
                        //strongSelf.showError(title, message: error.localizedDescription)
                    } else {
                        //strongSelf.showError(title, message: NSLocalizedString("Can't retrieve videos.", comment: "The message displayed when contacts can’t be retrieved."))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: UIAction
    
    @IBAction func cameraBtnTapped(sender: UIButton) {
        for cell in collectionView.visibleCells   {
            UIView.animate(withDuration: 0.25, animations: {
                self.rotateButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: { (true) in
                let indexPath = self.collectionView.indexPath(for: cell as! ProfileArtCell)
                let cell = self.collectionView.cellForItem(at: indexPath!) as! ProfileArtCell
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TestVC") as! TestVC
                vc.artImage = cell.artImageView.image
                self.navigationController?.pushViewController(vc, animated: false)
                self.navigationController?.isNavigationBarHidden = true
            })
        }
   }
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 3)
//        }, completion: { (true) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
            self.navigationController?.present(vc, animated: false, completion: nil)
        //})
    }
    
    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        let settingsNav = storyboard?.instantiateViewController(withIdentifier: "SettingsNav") as! UINavigationController
        let settingsVC = settingsNav.topViewController as! SettingsVC
        settingsVC.user = user
        present(settingsNav, animated: true, completion: nil)
    }
    
    @objc func swipe(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                 let visibleItems = self.collectionView.indexPathsForVisibleItems as NSArray
                 let currentItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
                 let previousItem = IndexPath(row: currentItem.row - 1, section: 0)
                 if indexPathIsValid(indexPath: previousItem) {
                    self.collectionView.scrollToItem(at: previousItem , at: .right, animated: true)
                    self.swipeLabel.text = "Now tap to view more."
                 }
                 swipeLabel.isHidden = true
            case UISwipeGestureRecognizerDirection.left:
                let visibleItems = self.collectionView.indexPathsForVisibleItems as NSArray
                let currentItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
                let nextItem = IndexPath(row: currentItem.row + 1, section: 0)
                
                if indexPathIsValid(indexPath: nextItem) {
                    self.collectionView.scrollToItem(at: nextItem, at: .right, animated: true)
                }
            default:
                break
            }
        }
    }
    
    func indexPathIsValid(indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        
        let lastSectionIndex = numberOfSections(in: collectionView) - 1
        
        //Make sure the specified section exists
        if section > lastSectionIndex {
            return false
        }
        let rowCount = self.collectionView(
            collectionView, numberOfItemsInSection: indexPath.section) - 1
        
        return row <= rowCount
    }
    
    
    //MARK: Filter
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredArts = arts.filter { art in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return (art.title.lowercased().contains(searchText.lowercased()))
        }
    }
    
    //MARK: SearchResultDelegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        filterContentForSearchText(searchText: searchBarText)
        self.searchController = searchController
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.endEditing(true)
    }
    
//    func loadArts() {
//        let ref =  DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!)
//        ref.observe(.value, with: {[weak self] (snapshot) in
//            self?.arts = []
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = snap.key
//                        let art = Art(key: key, artData: postDict)
//                        self?.art = Art(key: key, artData: postDict)
//                        self?.arts.insert(art, at: 0)
//                    }
//                }
//            }
//
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 1.0, animations: {
//                }, completion: {(true) in
//                    UIView.animate(withDuration: 3.0, animations: {
//                    })
//                })
//
//                //self?.messageBtn.setBadge(text: "1")
//                self?.collectionView.reloadData()
//                self?.pageControl.numberOfPages = (self?.arts.count)!
//            }
//        }, withCancel: nil)
//
//
//        DataService.instance.REF_NEW.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = snap.key
//                        let art = Art(key: key, artData: postDict)
//                        self.art = Art(key: key, artData: postDict)
//                        self.arts.insert(art, at: 0)
//                    }
//                }
//            }
//        })
//
//        ref.observe(.childRemoved, with: { (snapshot) in
//             DataService.instance.REF_NEW.observe(.childRemoved, with: { (snapshot) in
//             })
//            DispatchQueue.main.async {
//                //self.collectionView.reloadData()
//            }
//        }, withCancel: nil)
//    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !searchController.isActive && searchController.searchBar.text == "" {
           pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
        }
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            self.pageControl.isHidden = true
            return filteredArts.count
        } else {
            self.pageControl.isHidden = false
            print("COUNT: \(arts.count)")
            return artViewModelController.viewModels.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // var art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
            self.galleryIndexPath = indexPath
            cell.profileVC = self
//            if searchController.isActive && searchController.searchBar.text != "" {
//                art = filteredArts[indexPath.row]
//            } else {
//                art = arts[indexPath.row]
//            }
            cell.artRoomScene.boxnode.removeFromParentNode()
            if let viewModel = artViewModelController.viewModel(at: (indexPath as NSIndexPath).row) {
                cell.configureCell(viewModel)
            }
            //cell.configureCell(forArt: art)
            return cell
        } else {
            return ProfileArtCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let art: Art?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            art = filteredArts[indexPath.row]
        } else {
            art = arts[indexPath.row]
        }
        
        self.art = art

        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
            let artImage = cell.artImageView.image
            let artRoomScene = cell.artRoomScene
            self.showRequestAlert(artImage: artImage, art: art, artRoomScene: artRoomScene)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsVC" {
            let settingsVC = segue.destination as! SettingsVC
            if let user = sender as? Users {
                settingsVC.user = user
            }
        }
    }

    
    //MARK: DZNEmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: "You have no artwork yet. Click on the ＋ button to add.", attributes: attrs)
    }

}



