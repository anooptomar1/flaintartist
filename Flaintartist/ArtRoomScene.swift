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
    var boxnode = SCNNode()
    var cameraOrbit = SCNNode()
    var cameraNode = SCNNode()
    let camera = SCNCamera()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    
    convenience init(create: Bool) {
        self.init()
        print("ONE")
        setup(artInfo: artImage, height: height, width: width)
    }
    
    func setup(artInfo: UIImage?, height: CGFloat? = nil, width: CGFloat? = nil)  {
        print("ONE")
        self.artImage = artInfo!
        self.height = height!
        self.width = width!
        print("TWO")
        self.geometry = SCNBox(width: width!, height: height!, length: 57 / 1000, chamferRadius: 0.008)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        let yPos = -1.5
        print("3")

        boxnode.position = SCNVector3(0, 0.4, yPos)
        boxnode.rotation = SCNVector4(0,60,0,-56)
        print("4")

        self.rootNode.addChildNode(boxnode)
        print("5")

        cameraNode = SCNNode()
        cameraNode.camera = camera
        //camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 1
        camera.zFar = 100
        cameraOrbit.position = SCNVector3(0, 0, 4)
        print("6")

        cameraOrbit.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
        print("7")
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIImage(named: "texture")
        let backMat = SCNMaterial()
        backMat.diffuse.contents = UIColor.gray
        print("8")
        self.geometry.materials = [material, borderMat, backMat, borderMat, borderMat]
        print("9")
    }
}


