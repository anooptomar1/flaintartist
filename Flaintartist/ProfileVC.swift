//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//
import UIKit
import Hero
import Firebase
import SceneKit
import SDWebImage
import SwiftMessages
import DZNEmptyDataSet
import SwiftyUserDefaults


class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UISearchBarDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var user: Users?
    var arts = [Art]()
    var artImg = UIImage()
    var tapGesture = UITapGestureRecognizer()
    var searchController = UISearchController()
    
    var v: UIImageView?
    var pageControl: FlexiblePageControl!

    var cell: ProfileArtCell?
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
        self.isHeroEnabled = true
        loadGallery()
        setDelegate()
        setupViews()
        addGestures()
    }
    
    
    func loadGallery() {
        artViewModelController.retrieveVideos { [weak self] (success, error, arts, user) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                    if let error = error {
                        print(error)
                    } else {
                        
                    }
                }
            } else {
                self?.arts = arts
                DispatchQueue.main.async {
                    strongSelf.collectionView.reloadData()
                }
                guard let url = user?.profilePicUrl else { return }
                    strongSelf.v?.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .continueInBackground, completed: { (image, error, cache, url) in
                })
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
            self.navigationController?.present(vc, animated: false, completion: nil)
    }
    
    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        
        let settingsNav = storyboard?.instantiateViewController(withIdentifier: "SettingsNav") as! UINavigationController
        let settingsVC = settingsNav.topViewController as! SettingsVC
            settingsVC.user = user
        settingsNav.heroModalAnimationType = HeroDefaultAnimationType.selectBy(presenting:.zoom, dismissing:.slide(direction: .up))
        navigationController?.hero_replaceViewController(with: settingsNav)
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
    
    
    //MARK: SearchResultDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.pageControl.isHidden = false
            return artViewModelController.viewModelsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       var art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
            self.galleryIndexPath = indexPath
            cell.profileVC = self
            art = arts[indexPath.row]
            cell.artRoomScene.boxnode.removeFromParentNode()
            cell.configureCell(art)
            return cell
        } else {
            return ProfileArtCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let art: Art?
        art = arts[indexPath.row]
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



