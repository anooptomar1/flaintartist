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
            DispatchQueue.main.async {
                if indexPath.item == 0 || indexPath.item == 3 ||  indexPath.item == 6 {
                    self?.otherScene.rotate(w: -56, cameraZ: 3.5, yPoz: -3.0)
                } else if indexPath.item == 2 || indexPath.item == 5 ||  indexPath.item == 8 {
                    self?.otherScene.rotate(w: 56, cameraZ: 3.5, yPoz: -3.0)
                } else {
                    self?.otherScene.rotate(w: 0, cameraZ: 3, yPoz: -3.0)
                }
            }
            self?.otherScene.setup(artInfo: image, height: image!.size.height / 540, width: image!.size.width / 540)
        }
        self.imageView.sd_setImage(with: URL(string: "\(self.art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
    }
    
    deinit {
        print("HistoryCell is being dealloc")
    }
}
