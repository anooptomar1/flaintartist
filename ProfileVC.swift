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
import SwiftMessages
import DZNEmptyDataSet
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource,  UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeLabel: UILabel!
    
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
    
    var viewOrigin: CGFloat = 0.0
    
    weak var detailsView: EditArtDetails!
    
    let ref =  DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!)
    
    var v: UIImageView?
    var pageControl: FlexiblePageControl!

    var titles: [String] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        v = UIImageView(frame: CGRect(x: CGFloat(2), y: CGFloat(2), width: CGFloat(20), height: CGFloat(20)))
        let width: CGFloat = v!.frame.size.width
        let height: CGFloat = v!.frame.size.height
        
        v?.contentMode = .scaleAspectFill
        v?.layer.masksToBounds = true
        v?.layer.cornerRadius = (v?.frame.width)! / 2
        v?.isUserInteractionEnabled = true

        v?.layer.borderWidth = 1.3
        v?.layer.borderColor = UIColor.white.cgColor
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width + 4), height: CGFloat(height + 4))
        let progressIndicatorView = CircularLoaderView(frame: frame)
        progressIndicatorView.addSubview(v!)
        progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressIndicatorView.progress = CGFloat(1)/CGFloat(1)
    
        let profileBtn = UIBarButtonItem(customView: progressIndicatorView)
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsBtnTapped(_:))))
        self.navigationItem.rightBarButtonItem = profileBtn

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        

        
        DataService.instance.currentUserInfo { (user) in
            self.v?.setImageWith(URL(string: (user?.profilePicUrl)! ), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
        }
        
        loadArts(ref: ref)
        
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
        pageControl.displayCount = 8
        
        pageControl.pageIndicatorTintColor = UIColor.flatGray()
        pageControl.currentPageIndicatorTintColor = UIColor.flatSkyBlueColorDark()
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bottomView.addSubview(pageControl)
        pageControl.updateViewSize()


        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        view.addGestureRecognizer(swipeLeftGesture)
        swipeLeftGesture.direction = .left
        
        
        //refreshCtrl.tintColor = UIColor.flatBlack()
        //refreshCtrl.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func swipe() {
         let visibleItems = self.collectionView.indexPathsForVisibleItems as NSArray
        
        let currentItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath 
        guard let nextItem = IndexPath(row: currentItem.row + 1, section: 0) as? IndexPath else {
            return
        }
        self.collectionView.scrollToItem(at: nextItem , at: .left, animated: true)
        swipeLabel.isHidden = true
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
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.showBars), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.hideBars), name: cancelNotif, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func loadArts(ref: DatabaseReference) {
        
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
                self?.collectionView.reloadData()
                self?.pageControl.numberOfPages = (self?.arts.count)!
            }
        }, withCancel: nil)
        
        
        ref.observe(.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                //self.collectionView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
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
            bottomLine.alpha = 0
            bottomView.alpha = 0
        } else if arts.count > 2 {
            bottomLine.alpha = 1
            bottomView.alpha = 1
        }
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredArts.count
        } else {
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

            if searchController.isActive && searchController.searchBar.text != "" {
                art = filteredArts[indexPath.row]
            } else {
                art = arts[indexPath.row]
            }
                cell.artRoomScene.boxnode.removeFromParentNode()
                cell.configureCell(forArt: art)
            indicator.isHidden = true
//            cell.wallViewAction = {self.wallView(artImage: cell.artImageView.image!, art: art, artRoomScene: cell.artRoomScene)}
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
    
    
    func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
        let alert = Alerts()
        alert.changeProfilePicture(self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Seg_ArtroomVC {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == Seg_WallViewVC {
            let wallviewVC = segue.destination as! WallViewVC
            wallviewVC.hidesBottomBarWhenPushed = true
            if let artImage = sender as? UIImage {
                wallviewVC.artImage = artImage
            }
        }
        
        if segue.identifier == "SettingsVC" {
            let settingsVC = segue.destination as! SettingsVC
            if let user = sender as? Users {
                settingsVC.user = user
            }
        }
    }
    
    
    
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.url = URL
        present(vc, animated: true, completion: nil)
        return false
    }
    
    
    //MARK: DZNEmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: "You have no artwork yet. Click on the ＋ button to add.", attributes: attrs)
    }
}





//MARK: Extension Edit Art
extension ProfileVC {
    
    func wallView(artImage: UIImage, art: Art, artRoomScene: ArtRoomScene) {
        DispatchQueue.main.async {
            let wallViewVC = self.storyboard?.instantiateViewController(withIdentifier: "WallviewVC") as! WallViewVC
            wallViewVC.hidesBottomBarWhenPushed = true
            let artInfo = [artImage, art] as [Any]
            wallViewVC.artInfo = artInfo
            wallViewVC.user = self.user
            wallViewVC.position = artRoomScene.boxnode.position
            wallViewVC.rotation = artRoomScene.boxnode.rotation
            wallViewVC.width = artRoomScene.geometry.width
            wallViewVC.height = artRoomScene.geometry.height
            self.navigationController?.pushViewController(wallViewVC, animated: false)
        }
    }
    
    func showRequestAlert(artImage: UIImage?, art: Art?, artRoomScene: ArtRoomScene) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.edit(forArt: art!)
        }
        
        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            let view = self.view.captureView()
            self.shareChoice(view: view)
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
        let view: EditArtDetails = try! SwiftMessages.viewFromNib()
        view.saveAction = {self.done()}
        self.detailsView = view
        view.configureView(forArt: forArt)
        //view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .automatic
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        self.setTabBarVisible(visible: false, animated: true)
        SwiftMessages.show(config: config, view: view)
    }


    
    func cancel() {
        self.titleLbl.text = user?.name
        self.titleLbl.textColor = UIColor.flatBlack()
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
                    self.setTabBarVisible(visible: true, animated: true)
                    let alert = Alerts()
                    SwiftMessages.hide()
                    alert.showNotif(text: "Edit has been successfull", vc: self, backgroundColor: UIColor.flatWhite())
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
                self.ref.child(artId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        print("Failed to delete art:", error!)
                        return
                    }
                    
                    //DataService.instance.REF_ARTS.child((art?.artID)!).removeValue()
                    //DataService.instance.REF_HISTORY.child((art?.artID)!).removeValue()
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
            self.setTabBarVisible(visible: true, animated: true)
        }
    }
    
    func showBars() {
        UIView.animate(withDuration: 2.5) {
            self.navigationController?.navigationBar.alpha = 0
            self.setTabBarVisible(visible: false, animated: true)
        }
    }
    
    
    // SetTabBar Visible
    func setTabBarVisible(visible:Bool, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        if tabBarController != nil {
            return (self.tabBarController?.tabBar.frame.origin.y)! < self.view.frame.maxY
        }
        return true
    }
    
    
    // MARK: Keyboard
//    func keyboardWillShow(_ notification: NSNotification) {
//        self.viewOrigin = self.detailsView.frame.origin.y
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.detailsView.frame.origin.y == self.viewOrigin {
//                self.detailsView.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
    
    
//    func keyboardWillHide(_ notification: NSNotification) {
//        self.viewOrigin = 0.0
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.detailsView.frame.origin.y != 0 {
//                self.detailsView.frame.origin.y += keyboardSize.height
//            }
//        }
//    }
}

