//
//  SimilarScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/18/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import QuartzCore
import SceneKit
import ChameleonFramework

class SimilarScene: SCNScene {
    
    var artImage = UIImage()
    var geometry = SCNBox()
    var post: Art!
    let cameraOrbit = SCNNode()
    var boxnode = SCNNode()
    
    convenience init(create: Bool) {
        self.init()
        
        setup(artInfo: artImage)
    }
    
    
    func setup(artInfo: UIImage?)  {
        
        self.artImage = artInfo!
        self.geometry = SCNBox(width: 5, height: 5, length: 1, chamferRadius: 0.008)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        let yPos = -1.5
        
        boxnode.position = SCNVector3(0, 0.4, yPos)
        //boxnode.rotation = SCNVector4(0,60,0,-56)
        
        self.rootNode.addChildNode(boxnode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        cameraNode.rotation = SCNVector4(50,70,4,0)
        
        
        cameraOrbit.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
        
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIImage(named: "texture")
        let backMat = SCNMaterial()
        backMat.diffuse.contents = UIColor.gray
        self.geometry.materials = [material, borderMat, backMat, borderMat, borderMat]
    }
}

