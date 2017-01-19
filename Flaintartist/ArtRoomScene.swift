//
//  ArtRoomScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import QuartzCore
import SceneKit
import ChameleonFramework

class ArtRoomScene: SCNScene {
    
    var artImage = UIImage()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var geometry = SCNBox()
    var post: Art!
    let cameraOrbit = SCNNode()
    var boxnode = SCNNode()
    
    convenience init(create: Bool) {
        self.init()
        
        setup(artInfo: artImage, height: height, width: width)
        
    }
    
    func setup(artInfo: UIImage?, height: CGFloat? = nil, width: CGFloat? = nil)  {
        
        self.artImage = artInfo!
        self.height = height!
        self.width = width!
        
//        let lenght: CGFloat = CGFloat(57)
//        let width: CGFloat = artImage.size.width
//        let height: CGFloat = artImage.size.height
        
        
        self.geometry = SCNBox(width: width!, height: height!, length: 57 / 1000, chamferRadius: 0.008)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        let yPos = -1.5
        
        boxnode.position = SCNVector3(0, 0.4, yPos)
        boxnode.rotation = SCNVector4(0,60,0,-56)
        
        self.rootNode.addChildNode(boxnode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)

        
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


