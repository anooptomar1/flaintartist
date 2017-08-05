//
//  EditTC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-04.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit

class EditTC: UITableViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    
    var artRoomScene = ArtRoomScene(create: true)
    
    var artImage: UIImage?
    var artTitle = ""
    var height = 0
    var width = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInfo()
    }
    
    func setupInfo() {
        //print("TITLE: \(artTitle), HEIGHT\( height), WIDTH: \(width)")
        sceneView.backgroundColor = UIColor.clear
        weak var weakSelf = self
        let strongSelf = weakSelf!
        sceneView = strongSelf.sceneView!
        let scene = artRoomScene
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.isJitteringEnabled = true
        
        artRoomScene.setup(artInfo: artImage, height: (artImage?.size.height)! / 200, width: (artImage?.size.width)!  / 200, position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
        
        titleTextField.text = artTitle
//        heightTextField.text = "\(String(describing: height))"
//        widthTextField.text = "\(String(describing: width))"
    }
    

    
}
