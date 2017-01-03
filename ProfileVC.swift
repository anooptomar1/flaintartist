//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UIViewController, iCarouselDelegate, iCarouselDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var profileImg: BorderImg!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var artworkLbl: UILabel!
    @IBOutlet weak var artCountLbl: UILabel!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var tapOnCameraStackView: UIStackView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    var artView = UIView()
    var artImgView = FXImageView()
    var artImg = UIImage()
    var titleLbl: UILabel!
    var profileColor = UIColor()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var profilePicColor: UIColor?
    var posts = [ArtModel]()
    var post: ArtModel!
    var artists = [Users]()
    var artist: Users!
    var info: [AnyObject] = []
    var editInfo: [AnyObject] = []
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retrieveUserInfo()
        
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.type = .linear
        carouselView.clipsToBounds = true
    
            DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
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

        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tapProfilePicture))
        profileImg.addGestureRecognizer(tapProfileGesture)
        profileImg.configure(UIColor.flatWhite(), width: 0.5)
        self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 172) , andColors: [UIColor.flatWhite(), UIColor.white])
        carouselView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.carouselView.frame.width, height:  437) , andColors: [  UIColor.white, UIColor.flatWhite()])
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.flatBlack()
        refreshControl.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)
        scrollView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        if editInfo.isEmpty == false {
            if let img = editInfo[0] as? UIImage, let backImg = editInfo[1] as? UIImage, let name = editInfo[2] as? String {
                profileImg.image = img
                nameLbl.text = name
            }
        }
    }
    
    func refresh(_ sender:AnyObject) {
        retrieveUserInfo()
        carouselView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        if profileImg.image != nil {
            let images: [AnyObject] = [profileImg.image!, nameLbl.text! as AnyObject, profilePicColor!]
            performSegue(withIdentifier: "SettingsVC", sender: images)
        } else {
            let images: [AnyObject] = [nameLbl.text! as AnyObject, profilePicColor!]
            performSegue(withIdentifier: "SettingsVC", sender: images)
        }
    }
    
    
    //MARK: iCarousel delegate Functions
    func numberOfItems(in carousel: iCarousel) -> Int {
        if posts.count == 0 {
            tapOnCameraStackView.isHidden = false
        } else {
            tapOnCameraStackView.isHidden = true
        }
        return posts.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        if (view == nil) {
            let post = posts[index]
            artView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            artImgView = FXImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            artImgView.image = UIImage(named:"White")
            artImgView.contentMode = .scaleAspectFit
            artImgView.isAsynchronous = true
            artImgView.reflectionScale = 0.5
            artImgView.reflectionAlpha = 0.15
            artImgView.reflectionGap = 10.0
            artImgView.shadowOffset = CGSize(width: 0.0, height: 2.0)
            artImgView.shadowBlur = 1.0
            
            artView.addSubview(artImgView)
            
            if let img = ProfileVC.imageCache.object(forKey: post.imgUrl as NSString) {
                configureView(post, img: img)
            } else {
                configureView(post, imageView: artImgView)
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
    
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let index = carouselView.currentItemIndex
        let post = posts[index]
        let artImage = ProfileVC.imageCache.object(forKey: post.imgUrl as NSString)
        let artInfo = [artImage!, post] as [Any]
        performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
        
    }
    
    
    func removeArt() {
        let index = carouselView.currentItemIndex
        let artId = posts[index].artID
        let url = posts[index].imgUrl
        let userArtsRef = DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child(artId)
        let artsRef = DataService.ds.REF_ARTS.child(artId)
        userArtsRef.removeValue()
        artsRef.removeValue()
        self.posts.remove(at: index)
        ProfileVC.imageCache.removeObject(forKey: url as NSString)
        self.carouselView.removeItem(at: index, animated: true)
        carouselView.reloadData()
    }
    
    // MARK: Change photos gesture recognizer
    func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
        let alert = Alerts()
        alert.changeProfilePicture(self)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
            DataService.ds.storeProfileImg((FIRAuth.auth()!.currentUser!.uid), img: profileImg.image!, vc: self)
            let profilePicColor: UIColor = UIColor(averageColorFrom: image, withAlpha: 0.9)
            let color = profilePicColor.hexValue()
            self.artworkLbl.textColor = UIColor(contrastingBlackOrWhiteColorOn: profilePicColor, isFlat: true)
            self.artCountLbl.textColor =  UIColor(contrastingBlackOrWhiteColorOn: profilePicColor, isFlat: true)
            DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("color").setValue(color)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: Button Functions
    func artImgViewDoubleTapped(_ gesture: UITapGestureRecognizer) {
        let index = carouselView.currentItemIndex
        let post = posts[index]
        let img = ProfileVC.imageCache.object(forKey: post.imgUrl as NSString)
        self.moreBtnTapped(img!)
    }
    
    
    func moreBtnTapped(_ img: UIImage) {
        let alert = Alerts()
        let moreSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let share = UIAlertAction(title: "Share ", style: .default) { (UIAlertAction) in
            self.share(img)
        }
        
        let deleteAction = UIAlertAction(title: "Remove Art", style: .destructive) { (UIAlertAction) in
            alert.deteteArt(self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        moreSheet.addAction(share)
        moreSheet.addAction(deleteAction)
        moreSheet.addAction(cancelAction)
        present(moreSheet, animated: true, completion: nil)
    }
    
    
    // MARK: Network
    func share(_ img: UIImage) {
        let share = Share()
        
        let shareSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let facebookShare = UIAlertAction(title: "Share to Facebook", style: .default) { (UIAlertAction) in
            share.facebookShare(self, image: img)
        }
        let messengerShare = UIAlertAction(title: "Share to Messenger", style: .default) { (UIAlertAction) in
           // share.messengerShare(self, image: img)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shareSheet.addAction(facebookShare)
        shareSheet.addAction(messengerShare)
        shareSheet.addAction(cancelAction)
        present(shareSheet, animated: true, completion: nil)
        
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
    }
    
    
    
    func retrieveUserInfo(_ img: UIImage? = nil) {
        
        DispatchQueue.main.async {
            DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value) { (snapshot: FIRDataSnapshot) in
                DispatchQueue.main.async {
                    if let name = (snapshot.value as? NSDictionary)?["name"] as! String?  {
                        self.nameLbl.text = "\(name)"
                        print("USER: \(name)")
                    }
                    if let color = (snapshot.value as? NSDictionary)?["color"] as! String?  {
                        let profileColor = UIColor(hexString: color, withAlpha: 0.9) as UIColor
                        self.profilePicColor = profileColor
                        self.nameLbl.textColor = profileColor
                    }
                    self.artCountLbl.text = "\(self.posts.count)"
                }
            }
            self.retriveProfilePicture()
        }
    }
    
    func retriveProfilePicture(_ img: UIImage? = nil) {
        if img != nil {
            self.profileImg.image = img
        }else {
            let url = "gs://medici-b6f69.appspot.com/users/\(FIRAuth.auth()!.currentUser!.uid)/profileImg"
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
    
    func configureView(_ post: ArtModel, img: UIImage? = nil, imageView: FXImageView? = nil) {
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
