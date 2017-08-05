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
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
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
    
    var timer: Timer?
    var time: Float = 0.0
    
    var cell: ProfileArtCell?
    var bottomViewIsTapped: Bool = true
    var cameraBtnIsTapped: Bool = true
    
    var galleryIndexPath: IndexPath?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setupViews()
        loadArts()
        addGestures()
    }
    
    
    @objc func rotate() {
        print("ROTAAATE")
    }
    
    
    @objc func setProgress() {
        time += 0.1
        progressView.setProgress(time / 4, animated: true)
        if time >= 4 {
            timer!.invalidate()
        }
    }
    
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
        if section > lastSectionIndex
        {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadArts() {
        let ref =  DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!)
        ref.observe(.value, with: {[weak self] (snapshot) in
            self?.arts = []
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let art = Art(key: key, artData: postDict)
                        self?.art = Art(key: key, artData: postDict)
                        self?.arts.insert(art, at: 0)
                    }
                }
            }

            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    self?.progressView.setProgress(1.0, animated: true)
                }, completion: {(true) in
                    UIView.animate(withDuration: 3.0, animations: { 
                        self?.progressView.alpha = 0.0
                        //self?.bottomLine.alpha = 1.0
                    })
                })
           
                //self?.messageBtn.setBadge(text: "1")
                self?.collectionView.reloadData()
                self?.pageControl.numberOfPages = (self?.arts.count)!
            }
        }, withCancel: nil)
        

        DataService.instance.REF_NEW.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let art = Art(key: key, artData: postDict)
                        self.art = Art(key: key, artData: postDict)
                        self.arts.insert(art, at: 0)
                    }
                }
            }
        })
        
        ref.observe(.childRemoved, with: { (snapshot) in
             DataService.instance.REF_NEW.observe(.childRemoved, with: { (snapshot) in
             })
            DispatchQueue.main.async {
                //self.collectionView.reloadData()
            }
        }, withCancel: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !searchController.isActive && searchController.searchBar.text == "" {
           pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
        }
    }
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 3)
        }, completion: { (true) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddArtNav") as! UINavigationController
            self.navigationController?.present(vc, animated: false, completion: nil)
        })
    }
    
    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        let settingsNav = storyboard?.instantiateViewController(withIdentifier: "SettingsNav") as! UINavigationController
        let settingsVC = settingsNav.topViewController as! SettingsVC
        settingsVC.user = user
        present(settingsNav, animated: true, completion: nil)
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
            return arts.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
            self.galleryIndexPath = indexPath
            cell.profileVC = self
            if searchController.isActive && searchController.searchBar.text != "" {
                art = filteredArts[indexPath.row]
            } else {
                art = arts[indexPath.row]
            }
            cell.artRoomScene.boxnode.removeFromParentNode()
            cell.configureCell(forArt: art)
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
    var frame = CGRect()
    var image: UIImage!

}


//MARK: Extension Edit Art
extension ProfileVC {
    func showRequestAlert(artImage: UIImage?, art: Art?, artRoomScene: ArtRoomScene) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in
            let editTC = self.storyboard?.instantiateViewController(withIdentifier: "EditTC") as! EditTC
            editTC.artImage = artImage!
            //print("HEIGHT: \(art!.artHeight)")
            editTC.artTitle = (art?.title)!
//            editTC.width = (art?.artWidth)!
//            editTC.height = (art?.artHeight)!
            self.navigationController?.pushViewController(editTC, animated: true)
            
        })

        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            
            for cell in self.collectionView.visibleCells {
                let indexPath = self.self.collectionView.indexPath(for: cell as! ProfileArtCell)
                let cell = self.collectionView.cellForItem(at: indexPath!) as! ProfileArtCell
                let image = cell.scnView.snapshot()
                self.shareChoice(view: image)
            }     
        })
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            self.removeRequest(art: art)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(edit)
        alert.addAction(share)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func edit(forArt: Art) {
        cell?.textView.isEditable = true
        cell?.textView.becomeFirstResponder()
    }

    
    
    func done() {
        let price:Int? = Int(self.detailsView.priceField.text!)
        let title = self.detailsView.titleField.text!
        let desc = self.detailsView.descField.text!
        let isPrivate = self.detailsView.art.isPrivate
        queue.async(qos: .background) {        
        DataService.instance.REF_ARTS.child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate]) { (error, ref) in
            if error != nil {
                print("ERROR ")
            } else {
                DataService.instance.REF_ARTS.child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
                DataService.instance.REF_ARTISTARTS.child(self.detailsView.art.userUid).child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
                }
                DispatchQueue.main.async {
                    //self.setTabBarVisible(visible: true, animated: true)
                    let alert = Alerts()
                    SwiftMessages.hide()
                    alert.showNotif(text: "Edit has been successfull", vc: self, backgroundColor: UIColor.flatWhite(), textColor: UIColor.red , autoHide: true)
                }
            }
        }
    }


    func shareChoice(view: UIImage) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default) { (action) in
            let share = Share()
            share.facebookShare(self, image: view, text: "What do you think?")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(facebook)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func removeRequest(art: Art?) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove \(String(describing: art!.title)). After removing it, you can't get it back.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Remove from gallery", style: .destructive) { (UIAlertAction) in

            if let artId = art?.artID {
                DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!).child(artId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        print("Failed to delete art:", error!)
                        return
                    }
                    SDImageCache.shared().removeImage(forKey: art?.imgUrl, fromDisk: true)

                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func hideBars() {
        UIView.animate(withDuration: 1.3) {
            self.navigationController?.navigationBar.alpha = 1
        }
    }
    
    @objc func showBars() {
        UIView.animate(withDuration: 2.5) {
            self.navigationController?.navigationBar.alpha = 0
        }
    }
    
    
    // MARK: - Set Delegate
    func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    // MARK: - Views
    func setupViews() {
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector:#selector(setProgress), userInfo: nil, repeats: false)
        
        v = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(30), height: CGFloat(30)))
        let width: CGFloat = v!.frame.size.width
        let height: CGFloat = v!.frame.size.height
        
        v?.contentMode = .scaleAspectFill
        v?.layer.masksToBounds = true
        v?.layer.cornerRadius = (v?.frame.width)! / 2
        v?.isUserInteractionEnabled = true
        
        v?.layer.borderWidth = 1.3
        v?.layer.borderColor = UIColor.white.cgColor
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width + 4), height: CGFloat(height + 4))
        
        
        let ringProgressView = MKRingProgressView(frame: frame)
        ringProgressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        ringProgressView.startColor = UIColor.flatSkyBlue()
        ringProgressView.endColor = UIColor.flatSkyBlueColorDark()
        ringProgressView.ringWidth = 0.0
        ringProgressView.progress = 0.0
        ringProgressView.addSubview(v!)
        
        DataService.instance.currentUserInfo { (user) in
            if let url = user?.profilePicUrl {
                self.v?.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .continueInBackground, completed: { (image, error, cache, url) in
              
                })
            }
        }
        
        let profileBtn = UIBarButtonItem(customView: ringProgressView)
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsBtnTapped(_:))))
        self.navigationItem.leftBarButtonItem = profileBtn
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.showsCancelButton = false
        self.searchController.searchBar.placeholder = "Search"
        self.searchController.searchBar.returnKeyType = .done
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchBar.becomeFirstResponder()
        //self.navigationItem.titleView = searchController.searchBar
        self.searchController.dimsBackgroundDuringPresentation = false
        
        pageControl = FlexiblePageControl(frame: bottomView.bounds)
        pageControl.isUserInteractionEnabled = true
        pageControl.dotSize = 6
        pageControl.dotSpace = 5
        pageControl.hidesForSinglePage = true
        pageControl.displayCount = 5
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.flatGrayColorDark()
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bottomView.addSubview(pageControl)
        pageControl.updateViewSize()
    }
    
    // Add Gestures 
    
    func addGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeRight.direction = .right
        self.bottomView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeDown.direction = .left
        self.bottomView.addGestureRecognizer(swipeDown)
    }
    
    func verifyConnection() {
        if currentReachabilityStatus == .notReachable {
            let alert = Alerts()
            alert.showNotif(text: "No internet connection.", vc: self, backgroundColor: UIColor.flatRed(), textColor: UIColor.flatWhite(), autoHide: false)
        }
        print(currentReachabilityStatus != .notReachable) //true connected
    }
}

