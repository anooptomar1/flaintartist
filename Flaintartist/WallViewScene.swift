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
    
    var artImage = UIImage()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var geometry = SCNBox()
    var boxnode = SCNNode()
    var cameraOrbit = SCNNode()
    var cameraNode = SCNNode()
    var camera = SCNCamera()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    
    convenience init(create: Bool) {
        self.init()
        setup(artInfo: artImage, height: height, width: width)
    }
    
    func setup(artInfo: UIImage?, height: CGFloat? = nil, width: CGFloat? = nil)  {
        weak var weakSelf = self
        let strongSelf = weakSelf!
        
        strongSelf.artImage = artInfo!
        strongSelf.height = height!
        strongSelf.width = width!
        
        strongSelf.geometry = SCNBox(width: width!, height: height!, length: 57 / 1000, chamferRadius: 0.008)
        strongSelf.geometry.firstMaterial?.diffuse.contents = UIColor.red
        strongSelf.geometry.firstMaterial?.specular.contents = UIColor.white
        strongSelf.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: strongSelf.geometry)
        let yPos = -1.5
        
        boxnode.position = SCNVector3(0, 0.4, yPos)
        boxnode.rotation = SCNVector4(0,60,0,-56)
        
        strongSelf.rootNode.addChildNode(boxnode)
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        //camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 1
        camera.zFar = 90
        cameraOrbit.position = SCNVector3(0, 0, 3)
        
        cameraOrbit.addChildNode(cameraNode)
        strongSelf.rootNode.addChildNode(cameraOrbit)
        
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIColor.flatWhite()
        self.geometry.materials = [material, borderMat]
    }
    
    func remove() {
        boxnode.removeFromParentNode()
        cameraNode.removeFromParentNode()
        cameraOrbit.removeFromParentNode()
    }
}
