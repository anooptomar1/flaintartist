//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import Firebase
import SDWebImage
import AVFoundation
import SwiftMessages
import DZNEmptyDataSet
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource,  UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var preview: UIView!
    
    var user: Users?
    var arts = [Art]()
    var filteredArts = [Art]()
    var art: Art?
    var artImg = UIImage()
    let refreshCtrl = UIRefreshControl()
    var tapGesture = UITapGestureRecognizer()
    var segmentedCtrl = UISegmentedControl()
    var searchController = UISearchController()

    let kPrefetchRowCount = 10
    
    let editNotif = NSNotification.Name("Show")
    let cancelNotif = NSNotification.Name("Hide")
    let tapNotif = NSNotification.Name("Tap")
    let tapHideNotif =  NSNotification.Name("TapHide")
    
    var viewOrigin: CGFloat = 0.0
    
    weak var detailsView: EditArtDetails!
    
    var v: UIImageView?
    var pageControl: FlexiblePageControl!
    
    let session = AVCaptureSession()
    
    var timer: Timer?
    var time: Float = 0.0
    
    var cell: ProfileArtCell?
    var bottomViewIsTapped: Bool = true
    var cameraBtnIsTapped: Bool = true



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        setupViews()
        loadArts()
        addGestures()
        //verifyConnection()
        
        if #available(iOS 10.0, *) {
            self.setupAVCapture(view: self.preview, session: session)
        } else {
            // Fallback on earlier versions
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector:#selector(setProgress), userInfo: nil, repeats: false)
    }
    
    

    func bottomViewTapped() {
        if bottomViewIsTapped {
            bottomViewIsTapped = !bottomViewIsTapped
                NotificationCenter.default.post(name: tapNotif, object: nil)
                swipeLabel.isHidden = true
        } else {
            bottomViewIsTapped = !bottomViewIsTapped
            NotificationCenter.default.post(name: tapHideNotif, object: nil)
        }

        print("Bottom View Tapped")
    }
    

    
    func setProgress() {
        time += 0.1
        progressView.setProgress(time / 4, animated: true)
        if time >= 4 {
            timer!.invalidate()
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    @IBAction func cameraBtnTapped(sender: UIButton) {
        if (cameraBtnIsTapped) {
            cameraBtnIsTapped = !cameraBtnIsTapped
            UIView.animate(withDuration: 0.2) {
                if #available(iOS 10.0, *) {
                    self.preview.isHidden = false
                    self.session.startRunning()
                    self.navigationController?.setNavigationBarHidden(self.navigationController?.isNavigationBarHidden == false, animated: true)
                    //self.navigationController?.setNavigationBarHidden(true, animated: true)
                    sender.setImage(UIImage(named: "Dismiss Filled-20"), for: .normal)
                    self.bottomView.backgroundColor = UIColor.clear
                    self.pageControl.pageIndicatorTintColor = UIColor(white: 0.5, alpha: 0.5)
                    self.pageControl.currentPageIndicatorTintColor = UIColor.flatWhite()
                    self.pageControl.updateViewSize()
                    self.swipeLabel.textColor = UIColor.flatWhite()
                } else {
                    // Fallback on earlier versions
                }
            }
        } else {
            cameraBtnIsTapped = !cameraBtnIsTapped
            UIView.animate(withDuration: 0.2) {
                if #available(iOS 10.0, *) {
                    self.session.stopRunning()
                    self.preview.isHidden = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    sender.setImage( UIImage(named: "Preview Pane-20"), for: .normal)
                    self.bottomView.backgroundColor = UIColor.flatWhite()
                    self.pageControl.pageIndicatorTintColor = UIColor.flatGray()
                    self.pageControl.currentPageIndicatorTintColor = UIColor.flatSkyBlueColorDark()
                    self.swipeLabel.textColor = UIColor.flatGrayColorDark()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    
    func swipe(gesture: UIGestureRecognizer) {
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
        session.stopRunning()
    }
    
    
    func doSome() {
        print("DO SOME")
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
                        self?.bottomLine.alpha = 1.0
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
        let addArtVC = storyboard?.instantiateViewController(withIdentifier: "AddArtNav") as!UINavigationController
        present(addArtVC, animated: true, completion: nil)
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
        if arts.count < 2 {
            bottomView.alpha = 0
        } else if arts.count > 1 {
            bottomView.alpha = 1
        }
        
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

            let indicator = UIActivityIndicatorView(frame: cell.bounds)
            indicator.activityIndicatorViewStyle = .gray
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            cell.contentView.addSubview(indicator)
            cell.profileVC = self
            self.cell = cell

            if searchController.isActive && searchController.searchBar.text != "" {
                art = filteredArts[indexPath.row]
            } else {
                art = arts[indexPath.row]
            }
                cell.artRoomScene.boxnode.removeFromParentNode()
                cell.configureCell(forArt: art)
            indicator.removeFromSuperview()
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
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: "You have no artwork yet. Click on the ＋ button to add.", attributes: attrs)
    }
    
    var frame = CGRect()
    var image: UIImage!

}


//MARK: Extension Edit Art
extension ProfileVC {
    
    
    func showRequestAlert(artImage: UIImage?, art: Art?, artRoomScene: ArtRoomScene) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            if !self.session.isRunning {
                let view = self.view.captureView()
                self.shareChoice(view: view)
            } else {
                
                if #available(iOS 10.0, *) {
                    if (stillImageOutput?.connection(withMediaType: AVMediaTypeVideo)) != nil {
                        //stillImageOutput?.captureS
                    }
                } else {
                    // Fallback on earlier versions
                }
                self.shareChoice(view: self.image)
            }
        })
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            self.removeRequest(art: art)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
                
                DataService.instance.REF_HISTORY.child((self.user?.userId!)!).child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
                
                DataService.instance.REF_FAVORITES.child((self.user?.userId!)!).child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
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
    
    
    
    func hideBars() {
        UIView.animate(withDuration: 1.3) {
            self.navigationController?.navigationBar.alpha = 1
        }
    }
    
    func showBars() {
        UIView.animate(withDuration: 2.5) {
            self.navigationController?.navigationBar.alpha = 0
        }
    }
    
    // Views
    func setupViews() {
        
        v = UIImageView(frame: CGRect(x: CGFloat(2), y: CGFloat(2), width: CGFloat(25), height: CGFloat(25)))
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
        ringProgressView.ringWidth = 1.4
        ringProgressView.progress = 0.1
        ringProgressView.addSubview(v!)
        
        DataService.instance.currentUserInfo { (user) in
            if let url = user?.profilePicUrl {
                self.v?.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .continueInBackground, completed: { (image, error, cache, url) in
                    if url == nil {
                        ringProgressView.alpha = 0.0
                        
                    }
                    ringProgressView.progress = 1.0
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
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.dimsBackgroundDuringPresentation = false
        
        pageControl = FlexiblePageControl(frame: bottomView.bounds)
        pageControl.isUserInteractionEnabled = true
        pageControl.dotSize = 6
        pageControl.dotSpace = 5
        pageControl.hidesForSinglePage = true
        pageControl.displayCount = 5
        
        pageControl.pageIndicatorTintColor = UIColor.flatGray()
        pageControl.currentPageIndicatorTintColor = UIColor.flatSkyBlueColorDark()
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomViewTapped))
        self.bottomView.addGestureRecognizer(tapGesture)
    }
    
    // Add observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showBars), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBars), name: cancelNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBars), name: tapNotif, object: nil)
    }
    
    func verifyConnection() {
        if currentReachabilityStatus == .notReachable {
            let alert = Alerts()
            alert.showNotif(text: "No internet connection.", vc: self, backgroundColor: UIColor.flatRed(), textColor: UIColor.flatWhite(), autoHide: false)
        }
        print(currentReachabilityStatus != .notReachable) //true connected
    }
}

