//
//  ProfileArtCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/11/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import SDWebImage
import FirebaseStorage
import FirebaseDatabase

class ProfileArtCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var isPrivateImgView: UIImageView!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var viewLbl: UILabel!
    
    var artImageView = UIImageView()
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    
    var artRoomScene = ArtRoomScene(create: true)
    var art: Art?
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 0.2
    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = 0.02
    var maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 80.0
    var lastFingersNumber = 0
    
    var panGesture = UIPanGestureRecognizer()
    
    let editNotif = NSNotification.Name("Show")
    let cancelNotif = NSNotification.Name("Hide")
    let wallViewNotif = NSNotification.Name("WallView")
    let tapNotif = NSNotification.Name("Tap")
    let tapHideNotif =  NSNotification.Name("TapHide")
    
    
    var profileVC: ProfileVC?
    var likesRef: DatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scnView.backgroundColor = UIColor.clear
        weak var weakSelf = self
        let strongSelf = weakSelf!
        scnView = strongSelf.scnView!
        let scene = artRoomScene
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ProfileArtCell.handlePan(gestureRecognize:)))
        panGesture.delegate = self
        scnView.addGestureRecognizer(panGesture)
        
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ProfileArtCell.handlePinch(gestureRecognize:)))
        pinchGesture.delegate = self
        //scnView.addGestureRecognizer(pinchGesture)
        //NotificationCenter.default.addObserver(self, selector: #selector(test), name: editNotif, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(test), name: cancelNotif, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(bottomViewTapped), name: tapNotif, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(bottomViewReTapped), name: tapHideNotif, object: nil)
    }
    
    
    
    func bottomViewReTapped() {
        infoView.alpha = 0
    }
    
    
    func bottomViewTapped() {
        infoView.alpha = 1
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func test() {
        
    }
    
    
    func configureCell(forArt: Art) {
        self.art = forArt
        let myBlock: SDWebImageCompletionBlock! = { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            if let img = image {
                DispatchQueue.main.async {
                    self?.artRoomScene.setup(artInfo: img, height: img.size.height / 650, width: img.size.width / 650, position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                }
            }
        }
            self.artImageView.sd_setImage(with: URL(string: self.art!.imgUrl) , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
        
        textView.text = "\(forArt.title) \n"
    }
    
    
    
    @objc func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        let numberOfTouches = gestureRecognize.numberOfTouches
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        var widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) - lastWidthRatio
        var heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) - lastHeightRatio
        
        if (numberOfTouches == fingersNeededToPan) {
            //  HEIGHT constraints
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            //  WIDTH constraints
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            self.artRoomScene.boxnode.eulerAngles.y = Float(2 * Double.pi) * widthRatio
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
        }
        
        if gestureRecognize.state == .began ||  gestureRecognize.state == .changed {
            NotificationCenter.default.post(name: editNotif, object: self)
        } else if gestureRecognize.state == .cancelled || gestureRecognize.state == .ended {
            NotificationCenter.default.post(name: cancelNotif, object: self)
        }
    }
    
    
    @objc func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let zoom = gestureRecognize.scale
        let zoomLimits: [Float] = [5.0]
        var z = artRoomScene.cameraOrbit.position.z  * Float(1.0 / zoom)
        //z = fmaxf(zoomLimits.min()!, z)
        z = fminf(zoomLimits.max()!, z)
        DispatchQueue.main.async {
            self.artRoomScene.cameraOrbit.position.z = z
        }
        if gestureRecognize.state == .began ||  gestureRecognize.state == .changed {
            NotificationCenter.default.post(name: editNotif, object: self)
        } else if gestureRecognize.state == .cancelled || gestureRecognize.state == .ended {
            NotificationCenter.default.post(name: cancelNotif, object: self)
        }
    }
}

