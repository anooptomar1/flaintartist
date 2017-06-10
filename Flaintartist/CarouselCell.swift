//
//  CarouselCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/9/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SceneKit

class CarouselCell: UICollectionViewCell{
   
    @IBOutlet weak var scnView: SCNView!
    
    var artImageView = UIImageView()
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    
    var artRoomScene = ArtRoomScene(create: true)

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scnView.backgroundColor = UIColor.clear
        weak var weakSelf = self
        let strongSelf = weakSelf!
        scnView = strongSelf.scnView!
        let scene = artRoomScene
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
    }

    
    
    func configureCell() {
        print("configureCell")
        let img = #imageLiteral(resourceName: "female")
        self.artRoomScene.setup(artInfo: img, height: img.size.height / 650, width: img.size.width / 650, position: SCNVector3(0, 0.2, -1.5), rotation: SCNVector4(0,60,0,-56))
    }
}
