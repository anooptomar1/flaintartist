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
    
    let editNotif = NSNotification.Name("edit")
    let cancelNotif = NSNotification.Name("cancel")
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var sizeLbl: UILabel!
    @IBOutlet var descLbl: UILabel!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var swipeView: SwipeView!
    @IBOutlet var infoView: UIView!
    
    var artImageView = UIImageView()
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    

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
    
        swipeView.isHidden = true
        swipeView.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileArtCell.swipe), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileArtCell.hide), name: cancelNotif, object: nil)

    }
    
    func swipe() {
        infoView.isHidden = true
        self.swipeView.isHidden = false
    }
    
    func hide() {
        infoView.isHidden = false
        self.swipeView.isHidden = true
    }
}
