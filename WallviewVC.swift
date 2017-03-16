//
//  WallviewVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SceneKit
    
    
class WallViewVC: UIViewController{
    
    
    @IBOutlet weak var cameraView: IPDFCameraViewController!
    @IBOutlet weak var scnView: SCNView!
    
    var sceneView: SCNView!
    var artImage = UIImage()
    
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
    
    var artScene = WallViewScene(create: true)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        navigationController?.toolbar.isHidden = false
    }
    
    override func viewDidLoad() {
        self.cameraView.setupCameraView()
        self.cameraView.isBorderDetectionEnabled = false
        self.cameraView.cameraViewType = .normal
        super.viewDidLoad()
        
        weak var weakSelf = self
        let strongSelf = weakSelf!
        let scnView = self.scnView!
        let scene = artScene
        scnView.scene = scene
        let height = (artImage.size.height) / 900
        let width = (artImage.size.width) / 900
        strongSelf.artScene.setup(artInfo: artImage, height: height, width: width)
        //scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.clear
        scnView.isJitteringEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(WallViewVC.handlePan(gestureRecognize:)))
        scnView.addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(WallViewVC.handlePinch(gestureRecognize:)))
        scnView.addGestureRecognizer(pinchGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.cameraView.stop()
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
            
            artScene.boxnode.eulerAngles.y = Float(2 * M_PI) * widthRatio
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
        let zoom = gestureRecognize.scale
        let zoomLimits: [Float] = [5.0]
        var z = (artScene.cameraOrbit.position.z)  * Float(1.0 / zoom)
        z = fminf(zoomLimits.max()!, z)
        DispatchQueue.main.async {
            self.artScene.cameraOrbit.position.z = z
        }
    }
}

