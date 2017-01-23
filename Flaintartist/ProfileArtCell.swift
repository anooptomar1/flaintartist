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

class ProfileArtCell: UICollectionViewCell {
    
    let editNotif = NSNotification.Name("edit")
    let cancelNotif = NSNotification.Name("cancel")
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var sizeLbl: UILabel!
    @IBOutlet var descLbl: UILabel!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var swipeView: SwipeView!
    @IBOutlet var infoView: UIView!
    
    var artImageView = UIImageView()
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    

    var artRoomScene = ArtRoomScene(create: true)
    var post: Art!
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 0.2
    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = 0.02
    var maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 20.0  //1.0: very fast ---- 100.0 very slow
    var lastFingersNumber = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scnView = self.scnView!
        let scene = artRoomScene
        scnView.scene = scene
        //scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
    
        if swipeView != nil {
        swipeView.isHidden = true
        swipeView.isScrollEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileArtCell.swipe), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileArtCell.hide), name: cancelNotif, object: nil)
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ProfileArtCell.handlePan(gestureRecognize:)))
        scnView.addGestureRecognizer(panGesture)
        
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ProfileArtCell.handlePinch(gestureRecognize:)))
        scnView.addGestureRecognizer(pinchGesture)

    }
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        
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
            
            self.artRoomScene.boxnode.eulerAngles.y = Float(2 * M_PI) * widthRatio
            //self.artRoomScene.boxnode.eulerAngles.x = Float(M_PI) * heightRatio
            
            print("Height: \(round(heightRatio*100))")
            print("Width: \(round(widthRatio*100))")
            
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let pinchVelocity = Double.init(gestureRecognize.velocity)
        //print("PinchVelocity \(pinchVelocity)")
        
        artRoomScene.camera.orthographicScale -= (pinchVelocity/pinchAttenuation)
        
        if artRoomScene.camera.orthographicScale <= 0.0 {
            artRoomScene.camera.orthographicScale = 0.5
        }
        
        if artRoomScene.camera.orthographicScale >= 10.0 {
            artRoomScene.camera.orthographicScale = 10.0
        }
        
    }
    

    
    func swipe() {
        infoView.isHidden = true
        self.swipeView.isHidden = false
    }
    
    func hide() {
        infoView.isHidden = false
        self.swipeView.isHidden = true
    }
}
