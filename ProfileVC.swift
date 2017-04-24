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


class ProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
    let refreshCtrl = UIRefreshControl()
    var tapGesture = UITapGestureRecognizer()
    var segmentedCtrl = UISegmentedControl()
    
    let kPrefetchRowCount = 10
    
    let editNotif = NSNotification.Name("Show")
    let cancelNotif = NSNotification.Name("Hide")
    
    var dmzMessage = ""
    var viewOrigin: CGFloat = 0.0

    
    weak var detailsView: EditArtDetails!
    
    let ref =  DataService.instance.REF_ARTISTARTS.child((FIRAuth.auth()?.currentUser?.uid)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        loadArts(ref: ref)
        dmzMessage = "You have no artwork yet. Click on the capture button to start sharing."
        refreshCtrl.tintColor = UIColor.flatBlack()
        refreshCtrl.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshCtrl)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    deinit {
        print("ProfileVC is being dealloc")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
        self.collectionView.reloadData()
        loadUserInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.showBars), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.hideBars), name: cancelNotif, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        ref.removeAllObservers()
        DataService.instance.REF_USERS.child("\(FIRAuth.auth()!.currentUser!.uid)").removeAllObservers()
        user = nil
    }
    
    
    func loadArts(ref: FIRDatabaseReference) {
        queue.async(qos: .userInitiated) {
            ref.observe(.value, with: { [weak self] (snapshot) in
                self?.arts = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
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
                }
            })
        }
    }
    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "SettingsVC", sender: user)
    }
    
    
    func refresh() {
        tableView.reloadData()
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            refreshCtrl.endRefreshing()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
            cell.artRoomScene.boxnode.removeFromParentNode()
            cell.configureCell(forArt: art)
            return cell
        } else {
            return ProfileArtCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let art = arts[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
            let artImage = cell.artImageView.image
            let artRoomScene = cell.artRoomScene
            self.showRequestAlert(artImage: artImage!, art: art, artRoomScene: artRoomScene)
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
    
    
    func loadUserInfo(){
        queue.async(qos: .utility) {
            DataService.instance.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value, with: { (snapshot) in
                if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                    let key = snapshot.key
                    self.user = Users(key: key, artistData: postDict)
                    if (self.user) != nil {
                        DispatchQueue.main.async {
                            self.titleLbl.text = self.user.name
                        }
                    }
                }
            })
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
        return NSAttributedString(string: dmzMessage, attributes: attrs)
    }
}


//MARK: Extension Edit Art
extension ProfileVC {
    
    func showRequestAlert(artImage: UIImage, art: Art, artRoomScene: ArtRoomScene) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.edit(forArt: art)
        }
        
        let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
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
        })
        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            let view = self.view.captureView()
            self.shareChoice(view: view)
            //self.share(image: artImage, title: art.title)
        })
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            self.removeRequest(artUrl: art.imgUrl ,artID: art.artID, artTitle: art.title)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        

        alert.addAction(edit)
        alert.addAction(wallView)
        alert.addAction(share)
        alert.addAction(remove)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
        self.titleLbl.text = "\(user.name)"
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
                
                DataService.instance.REF_HISTORY.child(self.user.userId!).child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
                
                DataService.instance.REF_FAVORITES.child(self.user.userId!).child("\(self.detailsView.art.artID)").updateChildValues(["price": price!, "title": title, "description" : desc, "private": isPrivate])
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

    
    
    func removeRequest(artUrl: String, artID: String, artTitle: String) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove \(artTitle). After removing it, you can't get it back.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Remove from gallery", style: .destructive) { (UIAlertAction) in
            queue.async(qos: .background) {
                self.ref.child(artID).removeValue()
                DataService.instance.REF_ARTS.child(artID).removeValue()
                DataService.instance.REF_HISTORY.child(artID).removeValue()
                SDImageCache.shared().removeImage(forKey: artUrl, fromDisk: true)
                let email = Defaults[.email]
                let name = Defaults[.name]
                DataService.instance.REF_MAILGUN.sendMessage(to: "kerby.jean@hotmail.fr", from: email , subject: "REQUEST CANCELLED", body: "\(name) is cancelling \(artTitle), artID\(artID)", success: { (success) in
                    print(success!)
                    DispatchQueue.main.async {
                       self.collectionView.reloadData()
                    }
                }, failure: { (error) in
                    print(error!)
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
    func keyboardWillShow(_ notification: NSNotification) {
        self.viewOrigin = self.detailsView.frame.origin.y
        print("ORIGINE:\(self.viewOrigin)")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.detailsView.frame.origin.y == self.viewOrigin {
                self.detailsView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    
    func keyboardWillHide(_ notification: NSNotification) {
        self.viewOrigin = 0.0
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.detailsView.frame.origin.y != 0 {
                print("HIDE")
                self.detailsView.frame.origin.y += keyboardSize.height
            }
        }
    }
}

