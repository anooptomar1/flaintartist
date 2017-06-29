//
//  ArtRoomScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-06-28.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import QuartzCore
import SceneKit
import ChameleonFramework

class ArtRoomScene: SCNScene {
    
    var artImage = UIImage()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var position = SCNVector3()
    var rotation = SCNVector4()
    var geometry = SCNBox()
    var post: Art!
    var boxnode = SCNNode()
    var cameraOrbit = SCNNode()
    var cameraNode = SCNNode()
    let camera = SCNCamera()
    var materials = [SCNMaterial]()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    
    convenience init(create: Bool) {
        self.init()
        setup(artInfo: artImage, height: height, width: width, position: position, rotation: rotation)
    }
    
    func setup(artInfo: UIImage?, height: CGFloat? = nil, width: CGFloat? = nil, position: SCNVector3, rotation: SCNVector4)  {
        self.artImage = artInfo!
        self.height = height!
        self.width = width!
        self.geometry = SCNBox(width: width!, height: height!, length: 57 / 700, chamferRadius: 0.008)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        boxnode.position = position
        boxnode.rotation = rotation
        
        self.rootNode.addChildNode(boxnode)
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        camera.orthographicScale = 9
        camera.zNear = 1
        camera.zFar = 90
        cameraOrbit.position = SCNVector3(0, 0, 3)
        
        cameraOrbit.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIImage(named: "texture")
        let backMat = SCNMaterial()
        backMat.diffuse.contents = UIColor.gray
        self.materials = [material, borderMat, backMat, borderMat, borderMat]
        self.geometry.materials = self.materials
        
    }
    
    
    func add() {
        self.rootNode.addChildNode(boxnode)
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
        geometry.materials = materials
    }
    
    
    func remove() {
        boxnode.removeFromParentNode()
        cameraNode.removeFromParentNode()
        cameraOrbit.removeFromParentNode()
        geometry.removeMaterial(at: 0)
    }
}

