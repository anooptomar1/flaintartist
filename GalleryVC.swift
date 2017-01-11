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
import ChameleonFramework

  class GalleryVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
            
      @IBOutlet var profileImageView: UIImageView!
      @IBOutlet weak var nameLbl: UILabel!
      @IBOutlet var websiteTextView: UITextView!
      @IBOutlet weak var gradientView: UIView!
      @IBOutlet weak var tapOnCameraStackView: UIStackView!
      @IBOutlet var collectionView: UICollectionView!
            
            
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
                
        loadUserInfo()
        websiteTextView.delegate = self
                
   DataService.ds.REF_USERS.child((art.userUid)).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
         self.arts = []
         if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
           for snap in snapshot {
               if let postDict = snap.value as? Dictionary<String, AnyObject> {
                let key = snap.key
                let post = Art(key: key, artData: postDict)
                self.arts.insert(post, at: 0)
                        
              }
           }
         }
           self.collectionView.reloadData()
       }
                
      self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 172) , andColors: [UIColor.white, UIColor.white])
      collectionView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height:  475) , andColors: [  UIColor.white, UIColor.flatWhite()])
                
       let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tapProfilePicture))
                profileImageView.addGestureRecognizer(tapProfileGesture)

        tableView.refreshControl?.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
        let backBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(GalleryVC.backBtnTapped))
        navigationItem.leftBarButtonItem = backBtn
    }
    
            
    @IBAction func moreBtnTapped(_ sender: Any) {
        self.showAlert()
    }
    
    func backBtnTapped() {
        _ = navigationController?.popViewController(animated: true)
    }

            
    func refresh() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
            
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }
            
            
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return arts.count
    }
            
            
            
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let art = arts[indexPath.row]
                
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
                    
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            }
                    
            cell.artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
                    
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
                if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
                    
                    if let artImage = cell.artImageView.image {
                        let art = arts[indexPath.row]
                        let artInfo = [artImage, art] as [Any]
                        performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
                    }
                }
            }
            
            
    func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
         let alert = Alerts()
            alert.changeProfilePicture(self)
    }
            
            
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
            
            
    func loadUserInfo(){
        DataService.ds.REF_USERS.child("\(art.userUid)").observe(.value, with: { (snapshot) in
                    
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.user = Users(key: key, artistData: postDict)
                        
                if let user = self.user {
                    self.nameLbl.text = user.name
                    self.websiteTextView.text = user.website
                            
                    DataService.ds.REF_STORAGE.reference(forURL: user.profilePicUrl).data(withMaxSize: 15 * 1024 * 1024, completion: { (data, error) in
                        if let error = error {
                            print(error)
                        } else {
                    self.profileImageView.sd_setImage(with: URL(string: "\(self.user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground)
                        }
                    })
                }
            }
        })
    }
            
            
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.url = URL
        present(vc, animated: true, completion: nil)
        return false
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "Report", style: .destructive) { (UIAlertAction) in
            
            let reportsTitle = ["I believe this account violate Flaint's community guideline.", "Inapropriate language.", "Others."]
            self.performSegue(withIdentifier: "ReportVC", sender: reportsTitle)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ArtRoomVC" {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == "SettingsVC" {
            let settingsVC = segue.destination as! SettingsVC
            let userInfo = sender as! [AnyObject]
            settingsVC.userInfo = userInfo
        }
        
        if segue.identifier == "ReportVC" {
            let navVC = segue.destination as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose a reason for reporting \(user.name)."
            reportVC.user = user
            reportVC.reportsTitle = sender as! [String]
        }
    }
    
}


//        override func viewDidLoad() {
//            super.viewDidLoad()
//
//            retrieveUserInfo()
//            
//            DataService.ds.REF_BASE.child("users").child(post.userUid).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
//                self.posts = []
//                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                    for snap in snapshot {
//                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                            let key = snap.key
//                            let post = Art(key: key, artData: postDict)
//                            self.posts.insert(post, at: 0)
//                        }
//                    }
//                }
//                self.collectionView.reloadData()
//            }
//            
//            profileImg.configure(UIColor.flatWhite(), width: 0.5)
//            self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 236) , andColors: [UIColor.white, UIColor.white])
//            collectionView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height:  427) , andColors: [  UIColor.white, UIColor.flatWhite()])
////            
////            refreshControl = UIRefreshControl()
////            refreshControl.addTarget(self, action: #selector(GalleryVC.refresh(sender:)) , for: UIControlEvents.valueChanged)
////            scrollView.addSubview(refreshControl)
//        }
//        
//        
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            self.navigationController?.setToolbarHidden(true, animated: false)
//        }
//        
//        
//        
//        @IBAction func moreBtnTapped(_ sender: Any) {
//            self.showAlert()
//        }
//    
//        
//        
////        
////        func refresh(sender:AnyObject) {
////            retrieveUserInfo()
////            refreshControl.endRefreshing()
////        }
//        
//        
////        func removeArt() {
////            let index = carouselView.currentItemIndex
////            let artId = posts[index].artID
////            let url = posts[index].imgUrl
////            let userArtsRef = DataService.ds.REF_USERS.child(post.userUid).child("arts").child(artId)
////            let artsRef = DataService.ds.REF_ARTS.child(artId)
////            userArtsRef.removeValue()
////            artsRef.removeValue()
////            self.posts.remove(at: index)
////           // ProfileVC.imageCache.removeObject(forKey: url as NSString)
////            self.carouselView.removeItem(at: index, animated: true)
////            carouselView.reloadData()
////        }
//        
//        // MARK: Change photos gesture recognizer
//        func tapProfilePicture(gesture: UITapGestureRecognizer) {
//            imagePickerd = 1
//            let alert = Alerts()
//            alert.changeProfilePicture(self)
//        }
//        
//        func tapBackgroundPicture(gesture: UITapGestureRecognizer) {
//            imagePickerd = 2
//            let alert = Alerts()
//            alert.changeBackgroundPicture(self)
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//                profileImg.image = image
//            }
//            DataService.ds.storeProfileImg((FIRAuth.auth()!.currentUser!.uid), img: profileImg.image!, vc: self)
//            
//            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//                backgroundImg.image = image
//                let backgroundColor: UIColor = UIColor(averageColorFrom: image, withAlpha: 0.9)
//                let color = backgroundColor.hexValue()
//                DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("color").setValue(color)
//            }
//            picker.dismiss(animated: true, completion: nil)
//        }
//        
//        
//        func settingsBtnTapped() {
//            if profileImg.image != nil, backgroundImg.image != nil {
//                let images: [AnyObject] = [profileImg.image!, backgroundImg.image!, nameLbl.text! as AnyObject, backgroundPicColor!]
//                performSegue(withIdentifier: "SettingsVC", sender: images)
//                
//            } else {
//                let images: [AnyObject] = [nameLbl.text! as AnyObject, backgroundPicColor!]
//                performSegue(withIdentifier: "SettingsVC", sender: images)
//            }
//        }
//        
//        
//        func moreBtnTapped(img: UIImage) {
//            let moreSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            
//            let share = UIAlertAction(title: "Share ", style: .default) { (UIAlertAction) in
//                self.share(img: img)
//            }
//            
//            let deleteAction = UIAlertAction(title: "Remove Art", style: .destructive) { (UIAlertAction) in
//                // Delete art from server
//                //            alert.deteteArt(target: self, color: nil)
//            }
//            
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            //        moreSheet.addAction(previewAction)
//            moreSheet.addAction(share)
//            moreSheet.addAction(deleteAction)
//            moreSheet.addAction(cancelAction)
//            present(moreSheet, animated: true, completion: nil)
//        }
//        
//        
//        // MARK: Network
//        func share(img: UIImage) {
//            let share = Share()
//            
//            let shareSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            
//            let facebookShare = UIAlertAction(title: "Share to Facebook", style: .default) { (UIAlertAction) in
//                share.facebookShare(self, image: img, text: "")
//            }
//            let messengerShare = UIAlertAction(title: "Share to Messenger", style: .default) { (UIAlertAction) in
//                //share.messengerShare(self, image: img)
//            }
//            
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            
//            shareSheet.addAction(facebookShare)
//            shareSheet.addAction(messengerShare)
//            shareSheet.addAction(cancelAction)
//            present(shareSheet, animated: true, completion: nil)
//            
//        }
//        
//        func retrieveUserInfo(_ img: UIImage? = nil) {
//            DataService.ds.REF_USERS.child(self.post.userUid).observe(.value) { (snapshot: FIRDataSnapshot) in
//                if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
//                    let key = snapshot.key
//                    self.user = Users(key: key, artistData: postDict)
//                }
//                if let user = self.user {
//                    self.navigationItem.title = "\(user.name)'s Gallery"
//                    self.nameLbl.text = user.name
//                    self.artCountLbl.text = "\(self.posts.count)"
//                    self.websiteTextView.text = user.website
//                }
//            }
//            self.retriveProfilePicture()
//            
//        }
//
//        
//        func retriveProfilePicture(img: UIImage? = nil) {
//            if img != nil {
//                self.profileImg.image = img
//            }else {
//                let url = "gs://medici-b6f69.appspot.com/users/\(post.userUid)/profileImg"
//                DataService.ds.REF_STORAGE.reference(forURL: url).data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) -> Void in
//                    if error != nil {
//                        print(error.debugDescription)
//                    } else {
//                        if let imgData = data {
//                            if let img = UIImage(data: imgData) {
//                                self.profileImg.image = img
//                                //ProfileVC.imageCache.setObject(img, forKey: url as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//        }
//        
//        
//        func configureView(post: Art, img: UIImage? = nil, imageView: FXImageView? = nil) {
//            self.post = post
//            if img != nil {
//                self.artImgView.image = img
//            } else {
//                let ref = FIRStorage.storage().reference(forURL: post.imgUrl)
//                ref.data(withMaxSize:  2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        print("JESS: Unable to download image from Firebase storage")
//                        print("Unable to download image: \(error?.localizedDescription)")
//                    } else {
//                        print("JESS: Image downloaded from Firebase storage")
//                        if let imgData = data {
//                            if let img = UIImage(data: imgData) {
//                                imageView?.image = img
//                                //ProfileVC.imageCache.setObject(img, forKey: post.imgUrl as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//        }
//        

        
//
//    }

