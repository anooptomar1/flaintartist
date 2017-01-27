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
        
        
    @IBOutlet var cameraView: IPDFCameraViewController!
    @IBOutlet var scnView: SCNView!
        
    var sceneView: SCNView!
    var artImage = UIImage()
        
    var artScene = WallViewScene(create: true)
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        navigationController?.toolbar.isHidden = false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.cameraView.setupCameraView()
        self.cameraView.isBorderDetectionEnabled = false
        self.cameraView.cameraViewType = .normal
            
        let scnView = self.scnView!
        let scene = artScene
        scnView.scene = scene
        artScene.setup(artImage: artImage)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.clear
        scnView.isJitteringEnabled = true
            
        }
        
    override func viewDidAppear(_ animated: Bool) {
        self.cameraView.start()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        self.cameraView.stop()
        }
    }

