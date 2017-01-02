//
//  WallViewScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import SceneKit
import CoreMotion

class WallViewScene: SCNScene, SCNSceneRendererDelegate {
    
    var image = UIImage()
    var geometry = SCNBox()
    
    convenience init(create: Bool) {
        self.init()
        
        setup(artImage: image)
    }
    
    func setup(artImage: UIImage?)  {
        self.image = artImage!
        let lenght: CGFloat = 50
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height
        
        self.geometry = SCNBox(width: width / 1000 , height: height / 1000, length: lenght / 1000, chamferRadius: 0.005)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        let boxnode = SCNNode(geometry: self.geometry)
        boxnode.rotation = SCNVector4(0,60,0,-55.8)
        self.rootNode.addChildNode(boxnode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        self.rootNode.addChildNode(cameraNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIImage(named: "texture")
        let backMat = SCNMaterial()
        backMat.diffuse.contents = UIColor.gray
        self.geometry.materials = [material, borderMat, backMat, borderMat, borderMat]
    }
}


