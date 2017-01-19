//
//  SimilarCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/18/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SceneKit

class SimilarCell: UICollectionViewCell {
    
    
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet var scnView: SCNView!
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    
    
    var similarScene = SimilarScene(create: true)
    var post: Art!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        scnView = self.scnView!
//        let scene = similarScene
//        scnView.scene = scene
//        scnView.allowsCameraControl = false
//        scnView.autoenablesDefaultLighting = true
//        scnView.isJitteringEnabled = true
//        scnView.backgroundColor = UIColor(white: 1, alpha: 1)
    }
}
