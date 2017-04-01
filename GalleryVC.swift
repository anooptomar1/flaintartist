//
//  GalleryVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage
import DZNEmptyDataSet
import ChameleonFramework

class GalleryVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var artworkCountLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
    
    var tapGesture = UITapGestureRecognizer()
    
    let editNotif = NSNotification.Name("Show")
    let cancelNotif = NSNotification.Name("Hide")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.flatBlack()
        refreshControl.addTarget(self, action: #selector(GalleryVC.refresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
        
        let moreBtn = UIBarButtonItem(image: UIImage(named:"More Filled-15"), style: .plain, target: self, action: #selector(GalleryVC.moreBtnTapped(_:)))
        navigationItem.rightBarButtonItem = moreBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryVC.showBars), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryVC.hideBars), name: cancelNotif, object: nil)
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        queue.async(qos: .userInitiated) {
            DataService.instance.REF_ARTISTARTS.child((self.user.userId)!).observe(.value) { [weak self] (snapshot: FIRDataSnapshot) in
                self?.arts = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let dict = snap.value as? NSDictionary, let isPrivate = dict["private"] as? Bool {
                            if isPrivate == false {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let art = Art(key: key, artData: postDict)
                            if art.isPrivate == false {
                                self?.arts.insert(art, at: 0)
                                }
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
        
        
        loadUserInfo()
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func loadUserInfo(){
        DispatchQueue.main.async {
            self.titleLbl.text = "\(self.user.name)'s gallery"
            self.nameLbl.text = self.user.name
            if let url = self.user.profilePicUrl {
            self.profileImageView.sd_setImage(with: URL(string: "\(url)") , placeholderImage: nil , options: .continueInBackground)
            }
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.instance.REF_USERS.child((self.user.userId)!).child("arts").removeAllObservers()
        self.arts.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    deinit {
        print("Gallery is being dealloc")
    }
    
    
    func moreBtnTapped(_ sender: Any) {
        self.showAlert()
    }
    
    func backBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func refresh() {
        tableView.reloadData()
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.artworkCountLbl.text = "\(arts.count)"
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let art = arts[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
            let artImage = cell.artImageView.image
            self.artAlert(artImage: artImage!, art: art)
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.url = URL
        present(vc, animated: true, completion: nil)
        return false
    }
    
    func artAlert(artImage: UIImage, art: Art) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let request = UIAlertAction(title: "Request", style: .default, handler: { (UIAlertAction) in
            DataService.instance.request(artUID: art.artID, imgUrl: art.imgUrl ,title: art.title, description: art.description, price: art.price, height: art.artHeight, width: art.artWidth, type: art.type, date: art.postDate, userUID: art.userUid)
        })
        
        let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "WallviewVC", sender: artImage)
        })
        
        let favorite = UIAlertAction(title: "Add to favorites", style: .default, handler: { (UIAlertAction) in
            DataService.instance.addToFavorite(artUID: art.artID, imgUrl: art.imgUrl ,title: art.title, description: art.description, price: art.price, height: art.artHeight, width: art.artWidth, type: art.type, date: art.postDate, userUID: art.userUid, vc: self)
        })
        
        
        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            self.share(image: artImage, title: art.title)
        })
        
        
        _ = UIAlertAction(title: "Report", style: .destructive, handler: { (UIAlertAction) in
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportNav") as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose the reason for reporting the piece."
            let artInfo = [art]
            reportVC.artInfo = artInfo
            self.present(navVC, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(request)
        alert.addAction(wallView)
        alert.addAction(favorite)
        alert.addAction(share)
        //alert.addAction(report)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func share(image: UIImage, title: String) {
        let share = Share()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default, handler: { (UIAlertAction) in
            share.facebookShare(self, image: image, text: title)
        })
        
        _ = UIAlertAction(title: "Mesenger", style: .default, handler: { (UIAlertAction) in
            //share.messengerShare(self, image: self.artInfo[0] as! UIImage)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(facebook)
        //alert.addAction(messenger)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func remove(artID: String, artTitle: String) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove \(artTitle). After removing it you can't get it back.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Remove", style: .destructive) { (UIAlertAction) in
            DataService.instance.REF_USERS.child(self.user.userId!).child("arts").child(artID).removeValue(completionBlock: { (error, ref) in
                DataService.instance.REF_ARTS.child(ref.key).removeValue()
                self.collectionView.reloadData()
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let website = UIAlertAction(title: "Visit website", style: .default) { (UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
            let url = URL(string: "\(self.user.website)")
            print("FIRSTURL: \(url)")
            vc.url = url
            self.present(vc, animated: true, completion: nil)
        }
        
        let report = UIAlertAction(title: "Report \(user.name)", style: .destructive) { (UIAlertAction) in
            
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportNav") as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose a reason for reporting \(self.user.name)"
            reportVC.reportsTitle =  ["I believe this account violate Flaint's community guideline.", "Inapropriate language.", "Others."]
            reportVC.user = self.user
            self.present(navVC, animated: true, completion: nil)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if user.website != nil {
            alert.addAction(website)
        }
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Seg_WallViewVC {
            let wallViewVC = segue.destination as! WallViewVC
            wallViewVC.hidesBottomBarWhenPushed = true
            if let artImage = sender as? UIImage {
                wallViewVC.artImage = artImage
            }
        }
        
        
        if segue.identifier == Seg_ArtroomVC {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == Seg_ReportVC {
            let navVC = segue.destination as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose a reason for reporting \(user.name)."
            reportVC.user = user
            reportVC.reportsTitle = sender as! [String]
        }
    }
    
    //MARK: EmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "\(user.name) haven't share any artwork yet."
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: str, attributes: attrs)
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
    
}
