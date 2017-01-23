//
//  DetailsScene.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import Foundation
import SceneKit

class DetailsScene: SCNScene {
    
    var artImage = UIImage()
    var geometry = SCNBox()
    var boxnode = SCNNode()
    var heightPlane = SCNPlane()
    var newText = SCNText()
    var textNode = SCNNode()
    var post: Art!
    var height:Float = 0.0
    
    convenience init(create: Bool) {
        self.init()
        setup(artImage: artImage)
    }
    
    
    func setup(artImage: UIImage?)  {
        
        self.artImage = artImage!
        
        let lenght: CGFloat = 70
        let width: CGFloat = artImage!.size.width
        let height: CGFloat = artImage!.size.height
        
        self.geometry = SCNBox(width: width / 400 , height: height / 400, length: lenght / 400, chamferRadius: 0.008)
        self.geometry.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry.firstMaterial?.specular.contents = UIColor.white
        self.geometry.firstMaterial?.emission.contents = UIColor.blue
        boxnode = SCNNode(geometry: self.geometry)
        boxnode.position = SCNVector3(0, 0.4, 0)
        
        self.rootNode.addChildNode(boxnode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 6)
        self.rootNode.addChildNode(cameraNode)
        
        
        let material = SCNMaterial()
        material.diffuse.contents = artImage
        let borderMat = SCNMaterial()
        borderMat.diffuse.contents = UIImage(named: "texture")
        let backMat = SCNMaterial()
        backMat.diffuse.contents = UIColor.gray
        self.geometry.materials = [material, borderMat, backMat, borderMat, borderMat]
        
        //newText = SCNText(string: "test", extrusionDepth: 0)
        newText.firstMaterial!.diffuse.contents = UIColor.flatBlack()
        newText.font = UIFont.systemFont(ofSize: 0.2)
        //newText.firstMaterial!.specular.contents = UIColor.white
        
        textNode = SCNNode(geometry: newText)        
        
    }

}

