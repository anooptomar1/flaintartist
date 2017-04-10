//
//  Other.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2/10/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import SceneKit

final class Other: SCNScene {
    
    var artImage = UIImage()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var geometry = SCNBox()
    var boxnode = SCNNode()
    var cameraOrbit = SCNNode()
    var cameraNode = SCNNode()
    let camera = SCNCamera()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    
    convenience init(create: Bool) {
        self.init()
        setup(artInfo: artImage, height: height, width: width)
    }
    
    func setup(artInfo: UIImage?, height: CGFloat? = nil, width: CGFloat? = nil)  {
        
        self.artImage = artInfo!
        self.height = height!
        self.width = width!
        geometry = SCNBox(width: width!, height: height!, length: 40 / 100, chamferRadius: 0.008)        
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        let yPos = -1.0
        
        
        boxnode.position = SCNVector3(0, 0.4, yPos)
        
        self.rootNode.addChildNode(boxnode)
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        camera.orthographicScale = 9
        camera.zNear = 1
        camera.zFar = 100
        cameraOrbit.position = SCNVector3(0, 0, 3.5)
        
        cameraOrbit.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
        
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIColor.flatWhite()
        self.geometry.materials = [material, borderMat]
    }
    
    func rotate(w: Float, cameraZ: Float, yPoz: Float)  {
        boxnode.rotation = SCNVector4(0,2,0,w)
        cameraOrbit.position = SCNVector3(0, 0, cameraZ)
        let yPos = yPoz
        boxnode.position = SCNVector3(0, 0.4, yPos)
    }
    
    func remove() {
        boxnode.removeFromParentNode()
        cameraNode.removeFromParentNode()
        cameraOrbit.removeFromParentNode()
    }
}
