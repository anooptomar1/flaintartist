//
//  SearchArtsCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/7/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SceneKit
import SDWebImage

class SearchArtsCell: UICollectionViewCell {
    
    @IBOutlet weak var scnView: SCNView!
    var artImgView = UIImageView()
    var otherScene = Other(create: true)
    var art: Art!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        weak var weakSelf = self
        let strongSelf = weakSelf!
        scnView = strongSelf.scnView!
        let scene = otherScene
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
    }
    
    func configureCell(forArt: Art) {
        self.art = forArt
        let myBlock: SDWebImageCompletionBlock! = { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            if let img = image {
                DispatchQueue.main.async {
                    self?.otherScene.setup(artInfo: img, height: img.size.height / 800, width: img.size.width / 800)
                }
            }
        }
        queue.async(qos: .background) {
            self.artImgView.sd_setImage(with: URL(string: self.art!.imgUrl) , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
        }
    }
}

