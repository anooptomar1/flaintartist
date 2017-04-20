//
//  HistoryCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/8/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import SDWebImage

class HistoryCell: UICollectionViewCell {
    
    @IBOutlet var scnView: SCNView!
    @IBOutlet weak var artistImgView: RoundImage!

    var imageView = UIImageView()
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
    
    
    func configureCell(forArt: Art, indexPath: IndexPath) {
        self.art = forArt
        let myBlock: SDWebImageCompletionBlock! = { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in

            if image!.size.height >= 1000, image!.size.width >= 800 {
                self?.otherScene.setup(artInfo: image, height: image!.size.height / 500, width: image!.size.width / 500)
            } else if image!.size.height >= 1000, image!.size.width <= 800 {
                self?.otherScene.setup(artInfo: image, height: image!.size.height / 200, width: image!.size.width / 200)
            }else if image!.size.height <= 1000, image!.size.height >= 800 {
                self?.otherScene.setup(artInfo: image, height: image!.size.height / 200, width: image!.size.width / 200)
            } else if image!.size.height <= 900 {
                self?.otherScene.setup(artInfo: image, height: image!.size.height / 200, width: image!.size.width / 200)
            }
        }
        
        self.imageView.sd_setImage(with: URL(string: "\(self.art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
    }
    
    deinit {
        print("HistoryCell is being dealloc")
    }
}
