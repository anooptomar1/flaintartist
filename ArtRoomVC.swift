//
//  ArtRoomVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import Firebase
import SDWebImage
import GSMessages
import ChameleonFramework
import SwiftyUserDefaults

class ArtRoomVC: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var artInfoView: UIView!
    @IBOutlet weak var mainTitleLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var artistImg: RoundImage!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var artistView: UIView!
    
    var artRoomScene = ArtRoomScene(create: true)
    var artImage = UIImage()
    var artInfo: [Any] = []
    var posts = [Art]()
    var post: Art!
    var user: Users!
    var showInfo: Bool = false
    var showSimilar: Bool = false
    let alert = Alerts()
    
    
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 0.2
    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = 0.02
    var maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 100.0
    var lastFingersNumber = 0
    var userID = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self
        let strongSelf = weakSelf!
        
        scnView = strongSelf.scnView!
        let scene = artRoomScene
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
        scnView.backgroundColor = UIColor.white
        
        if let info = self.artInfo[1] as? Art {
            DataService.instance.seen(artUID: info.artID, imgUrl: info.imgUrl, title: info.title, description: info.description, price: info.price, height: info.artHeight, width: info.artWidth, type: info.type, date: info.postDate, userUID: info.userUid)
            self.userID = info.userUid
            let image = strongSelf.artInfo[0] as? UIImage
            let height = (image?.size.height)! / 700
            let width = (image?.size.width)! / 700
            strongSelf.artRoomScene.setup(artInfo: image, height: height, width: width)
            strongSelf.mainTitleLbl.text = info.title
            let date = info.postDate / 1000
            let foo: TimeInterval = TimeInterval(date)
            let theDate = NSDate(timeIntervalSince1970: foo)
            let time = timeAgoSinceDate(date: theDate as Date, numericDates: true)
            strongSelf.timeLbl.text = "\(time)"
            strongSelf.textView.text = "\(info.artHeight)'H x \(info.artWidth)'W - \(info.price)$ / month - \(info.type) \n \(info.description)."
        }
        
        self.navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        self.navigationController?.toolbar.setBackgroundImage(UIImage(),  forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        self.navigationController?.toolbar.isTranslucent = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ArtRoomVC.showAlert))
        scnView.addGestureRecognizer(tapGesture)
        let tapUserGesture = UITapGestureRecognizer(target: self, action: #selector(ArtRoomVC.artistBtnTapped))
        artistView.addGestureRecognizer(tapUserGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ArtRoomVC.handlePan(gestureRecognize:)))
        scnView.addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ArtRoomVC.handlePinch(gestureRecognize:)))
        scnView.addGestureRecognizer(pinchGesture)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.instance.REF_USERS.child("\(self.userID)").observe(.value, with: { [weak self] (snapshot) in
                if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                    let key = snapshot.key
                    self?.user = Users(key: key, artistData: postDict)
                    if let user = self?.user {
                        DispatchQueue.main.async {
                            self?.artistNameLbl.text = user.name
                            self?.artistImg.sd_setImage(with: URL(string: "\(user.profilePicUrl!)") , placeholderImage: UIImage(named:"Placeholder") , options: .continueInBackground)
                        }
                    }
                }
            })
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.artRoomScene.remove()
        //self.scnView.removeFromSuperview()
        //self.stackView.removeFromSuperview()
        DataService.instance.REF_USERS.child("\(self.userID)").removeAllObservers()
        posts = []
    }
    
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        let numberOfTouches = gestureRecognize.numberOfTouches
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        var widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) - lastWidthRatio
        var heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) - lastHeightRatio
        
        if (numberOfTouches == fingersNeededToPan) {
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            artRoomScene.boxnode.eulerAngles.y = Float(2 * M_PI) * widthRatio
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
        
        if gestureRecognize.state == .began ||  gestureRecognize.state == .changed {
            UIView.animate(withDuration: 2.5) {
                self.artInfoView.alpha = 0
                self.navigationController?.navigationBar.alpha = 0
            }
        } else if gestureRecognize.state == .cancelled || gestureRecognize.state == .ended {
            UIView.animate(withDuration: 1.3) {
                self.artInfoView.alpha = 1
                self.navigationController?.navigationBar.alpha = 1
            }
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let zoom = gestureRecognize.scale
        let zoomLimits: [Float] = [5.0]
        var z = (artRoomScene.cameraOrbit.position.z)  * Float(1.0 / zoom)
        z = fminf(zoomLimits.max()!, z)
        DispatchQueue.main.async {
            self.artRoomScene.cameraOrbit.position.z = z
        }
    }
    
    
    func artistBtnTapped() {
        if user.userId == FIRAuth.auth()?.currentUser?.uid {
            tabBarController?.selectedIndex = 2
        } else {
            let galleryVC = storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
            galleryVC.user = user
            galleryVC.hidesBottomBarWhenPushed = true
            DispatchQueue.main.async {
                _ = self.navigationController?.pushViewController(galleryVC, animated: true)
            }
        }
    }
    
    
    
    func showAlert() {
        if let info = artInfo[1] as? Art {
            let request = UIAlertAction(title: "Request", style: .default, handler: { (UIAlertAction) in
                DataService.instance.request(artUID: info.artID, imgUrl: info.imgUrl ,title: info.title, description: info.description, price: info.price, height: info.artHeight, width: info.artWidth, type: info.type, date: info.postDate, userUID: info.userUid)
            })
            
            let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "WallviewVC", sender:self.artInfo[0] as! UIImage)
            })
            
//            let favorite = UIAlertAction(title: "Add to favorites", style: .default, handler: { (UIAlertAction) in
//                
//                DataService.instance.addToFavorite(artUID: info.artID, imgUrl: info.imgUrl ,title: info.title, description: info.description, price: info.price, height: info.artHeight, width: info.artWidth, type: info.type, date: info.postDate, userUID: info.userUid, vc: self)
//            })
            
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
                self.share()
            })
            
            let report = UIAlertAction(title: "Report", style: .destructive, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "ReportVC", sender: self.artInfo[1])
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(request)
            alert.addAction(wallView)
            //alert.addAction(favorite)
            alert.addAction(share)
            alert.addAction(report)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func share() {
        let share = Share()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default, handler: { (UIAlertAction) in
            share.facebookShare(self, image: self.artInfo[0] as! UIImage, text: self.mainTitleLbl.text!)
        })
        
        _ = UIAlertAction(title: "Mesenger", style: .default, handler: { (UIAlertAction) in
            //share.messengerShare(self, image: self.artInfo[0] as! UIImage)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(facebook)
        //alert.addAction(messenger)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if segue.identifier == "GalleryVC" {
        //            let navVC = segue.destination as! UINavigationController
        //            let galleryVC =  navVC.topViewController as! GalleryVC
        //            galleryVC.hidesBottomBarWhenPushed = true
        //            if let user = sender as? Users {
        //                galleryVC.user = user
        //                print("USER: \(user)")
        //            }
        //        }
        
        if segue.identifier == "WallviewVC" {
            let vc = segue.destination as! WallViewVC
            if let artImage = sender as? UIImage {
                vc.artImage = artImage
            }
        }
        
        if segue.identifier == "ReportVC" {
            let navVC = segue.destination as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose the reason for reporting the Piece."
            reportVC.artInfo = artInfo
            
        }
    }
}
