//
//  GalleryVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


    import UIKit
    import FirebaseAuth
    import FirebaseDatabase
    import FirebaseStorage
    import ChameleonFramework
    
    class GalleryVC: UIViewController, iCarouselDelegate, iCarouselDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        @IBOutlet weak var profileImg: BorderImg!
        @IBOutlet weak var backgroundImg: UIImageView!
        @IBOutlet weak var nameLbl: UILabel!
        @IBOutlet weak var carouselView: iCarousel!
        @IBOutlet weak var gradientView: UIView!
        @IBOutlet weak var artworkLbl: UILabel!
        @IBOutlet weak var artCountLbl: UILabel!
        @IBOutlet var scrollView: UIScrollView!
        
        var imagePickerd = 0
        var artView = UIView()
        var artImgView = FXImageView()
        var artImg = UIImage()
        var titleLbl: UILabel!
        
        static var imageCache: NSCache<NSString, UIImage> = NSCache()
        var backgroundPicColor: UIColor?
        var posts = [ArtModel]()
        var post: ArtModel!
        var info: [AnyObject] = []
        var editInfo: [AnyObject] = []
        
        var screenSize: CGRect!
        var screenWidth: CGFloat!
        var screenHeight: CGFloat!
        
        var refreshControl: UIRefreshControl!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            carouselView.delegate = self
            carouselView.dataSource = self
            carouselView.type = .linear
            carouselView.clipsToBounds = true
            retrieveUserInfo()
            
            DataService.ds.REF_BASE.child("users").child(post.userUid).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
                self.posts = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let post = ArtModel(key: key, artData: postDict)
                            self.posts.insert(post, at: 0)
                        }
                    }
                }
                self.carouselView.reloadData()
            }
            
            if post.userUid == FIRAuth.auth()?.currentUser?.uid {
                let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tapProfilePicture))
                profileImg.addGestureRecognizer(tapProfileGesture)
                
            }
            
            profileImg.configure(UIColor.flatWhite(), width: 0.5)
            carouselView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.carouselView.frame.width, height:  342) , andColors: [UIColor.white, UIColor.flatWhite()])
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(GalleryVC.refresh(sender:)) , for: UIControlEvents.valueChanged)
            scrollView.addSubview(refreshControl)
            
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            self.navigationController?.navigationBar.tintColor = UIColor.flatSkyBlue()
            self.navigationController?.setToolbarHidden(true, animated: false)
            
        }
        
        func refresh(sender:AnyObject) {
            retrieveUserInfo()
            carouselView.reloadData()
            refreshControl.endRefreshing()
        }
        
        
        //MARK: iCarousel delegate Functions
        func numberOfItems(in carousel: iCarousel) -> Int {
            return posts.count
        }
        
        func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
            if (view == nil) {
                let post = posts[index]
                artView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                artImgView = FXImageView(frame: CGRect(x: 0, y: 20, width: 250, height: 250))
                artImgView.image = UIImage(named:"White")
                artImgView.contentMode = .scaleAspectFit
                artImgView.isUserInteractionEnabled = true
                artImgView.isAsynchronous = true
                artImgView.reflectionScale = 0.5
                artImgView.reflectionAlpha = 0.15
                artImgView.reflectionGap = 10.0
                artImgView.shadowOffset = CGSize(width: 0.0, height: 2.0)
                artImgView.shadowBlur = 1.0
                
                let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(ProfileVC.artImgViewDoubleTapped))
                tapGesture.numberOfTapsRequired = 2
                artImgView.addGestureRecognizer(tapGesture)
                artView.addSubview(artImgView)
                
                if let img = ProfileVC.imageCache.object(forKey: post.imgUrl as NSString) {
                    configureView(post: post, img: img)
                } else {
                    configureView(post: post, imageView: artImgView)
                }
            }
            return artView
        }
        
        func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
            if option == iCarouselOption.spacing {
                return 1.1
            }
            return value
        }
        
        
        //        func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        //            let post = posts[index]
        //            performSegue(withIdentifier: "ArtDetailsVC", sender: post)
        //        }
        //
        
        func removeArt() {
            let index = carouselView.currentItemIndex
            let artId = posts[index].artID
            let url = posts[index].imgUrl
            let userArtsRef = DataService.ds.REF_USERS.child(post.userUid).child("arts").child(artId)
            let artsRef = DataService.ds.REF_ARTS.child(artId)
            userArtsRef.removeValue()
            artsRef.removeValue()
            self.posts.remove(at: index)
            ProfileVC.imageCache.removeObject(forKey: url as NSString)
            self.carouselView.removeItem(at: index, animated: true)
            carouselView.reloadData()
        }
        
        // MARK: Change photos gesture recognizer
        func tapProfilePicture(gesture: UITapGestureRecognizer) {
            imagePickerd = 1
            let alert = Alerts()
            alert.changeProfilePicture(self)
        }
        
        func tapBackgroundPicture(gesture: UITapGestureRecognizer) {
            imagePickerd = 2
            let alert = Alerts()
            alert.changeBackgroundPicture(self)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                profileImg.image = image
            }
            DataService.ds.storeProfileImg((FIRAuth.auth()!.currentUser!.uid), img: profileImg.image!, vc: self)
            
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                backgroundImg.image = image
                let backgroundColor: UIColor = UIColor(averageColorFrom: image, withAlpha: 0.9)
                let color = backgroundColor.hexValue()
                DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("color").setValue(color)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        
        //MARK: Button Functions
        //        func artImgViewDoubleTapped(gesture: UITapGestureRecognizer) {
        //            let index = carouselView.currentItemIndex
        //            let post = posts[index]
        //            let img = ProfileVC.imageCache.object(forKey: post.imgUrl as NSString)
        //            self.moreBtnTapped(img: img!)
        //        }
        
        
        func settingsBtnTapped() {
            if profileImg.image != nil, backgroundImg.image != nil {
                let images: [AnyObject] = [profileImg.image!, backgroundImg.image!, nameLbl.text! as AnyObject, backgroundPicColor!]
                performSegue(withIdentifier: "SettingsVC", sender: images)
                
            } else {
                let images: [AnyObject] = [nameLbl.text! as AnyObject, backgroundPicColor!]
                performSegue(withIdentifier: "SettingsVC", sender: images)
            }
        }
        
        
        func moreBtnTapped(img: UIImage) {
            let moreSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let share = UIAlertAction(title: "Share ", style: .default) { (UIAlertAction) in
                self.share(img: img)
            }
            
            let deleteAction = UIAlertAction(title: "Remove Art", style: .destructive) { (UIAlertAction) in
                // Delete art from server
                //            alert.deteteArt(target: self, color: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            //        moreSheet.addAction(previewAction)
            moreSheet.addAction(share)
            moreSheet.addAction(deleteAction)
            moreSheet.addAction(cancelAction)
            present(moreSheet, animated: true, completion: nil)
        }
        
        
        // MARK: Network
        func share(img: UIImage) {
            let share = Share()
            
            let shareSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let facebookShare = UIAlertAction(title: "Share to Facebook", style: .default) { (UIAlertAction) in
                share.facebookShare(self, image: img)
            }
            let messengerShare = UIAlertAction(title: "Share to Messenger", style: .default) { (UIAlertAction) in
                //share.messengerShare(self, image: img)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            shareSheet.addAction(facebookShare)
            shareSheet.addAction(messengerShare)
            shareSheet.addAction(cancelAction)
            present(shareSheet, animated: true, completion: nil)
            
        }
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "SettingsVC" {
                let settingsVC = segue.destination as! SettingsVC
                let userInfo = sender as! [AnyObject]
                settingsVC.userInfo = userInfo
            }
        }
        
        func retrieveUserInfo(img: UIImage? = nil) {
            DispatchQueue.main.async {
                DataService.ds.REF_USERS.child(self.post.userUid).observe(.value) { (snapshot: FIRDataSnapshot) in
                    DispatchQueue.main.async {
                        if let name = (snapshot.value as? NSDictionary)?["name"] as! String?  {
                            let firstName = name.components(separatedBy: " ").first!
                            self.navigationItem.title = "\(firstName)'s Gallery"
                            self.nameLbl.text = "\(name)"
                        }
                        
                        if let color = (snapshot.value as? NSDictionary)?["color"] as! String?  {
                            let backColor = UIColor(hexString: color, withAlpha: 0.9) as UIColor
                            self.backgroundPicColor = backColor
                            self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 206) , andColors: [ backColor, UIColor.white])
                            self.nameLbl.textColor = backColor
                        }
                    }
                }
                self.retriveProfilePicture()
            }
        }
        
        func retriveProfilePicture(img: UIImage? = nil) {
            if img != nil {
                self.profileImg.image = img
            }else {
                let url = "gs://medici-b6f69.appspot.com/users/\(post.userUid)/profileImg"
                DataService.ds.REF_STORAGE.reference(forURL: url).data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) -> Void in
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.profileImg.image = img
                                ProfileVC.imageCache.setObject(img, forKey: url as NSString)
                            }
                        }
                    }
                })
            }
        }
        
        
        func configureView(post: ArtModel, img: UIImage? = nil, imageView: FXImageView? = nil) {
            self.post = post
            if img != nil {
                self.artImgView.image = img
            } else {
                let ref = FIRStorage.storage().reference(forURL: post.imgUrl)
                ref.data(withMaxSize:  2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("JESS: Unable to download image from Firebase storage")
                        print("Unable to download image: \(error?.localizedDescription)")
                    } else {
                        print("JESS: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                imageView?.image = img
                                ProfileVC.imageCache.setObject(img, forKey: post.imgUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
    }
