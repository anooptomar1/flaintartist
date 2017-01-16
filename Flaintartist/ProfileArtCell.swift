//
//  ProfileArtCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/11/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import SDWebImage
import FirebaseStorage

class ProfileArtCell: UICollectionViewCell {
    
    var artImageView = UIImageView()
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var sizeLbl: UILabel!
    @IBOutlet var descLbl: UILabel!
    @IBOutlet var scnView: SCNView!
    
    
    var artRoomScene = ArtRoomScene(create: true)
    var post: Art!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scnView = self.scnView!
        let scene = artRoomScene
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
        

    }
}
