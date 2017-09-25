//
//  ArtCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import Reusable
import SceneKit
import IGListKit
import SDWebImage

class ArtCell: UICollectionViewCell, Reusable {
    
    lazy var artRoomScene = ArtRoomScene(create: true)
    var imageView = UIImageView()
    
    fileprivate let sceneView: SCNView = {
        let view = SCNView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()
    
    fileprivate let activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.startAnimating()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(sceneView)
        contentView.addSubview(activityView)
        weak var weakSelf = self
        let strongSelf = weakSelf!
        let scene = artRoomScene
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.isJitteringEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        activityView.center = CGPoint(x: bounds.width/2.0, y: bounds.height/2.0)
        sceneView.frame = bounds
    }
    
    func configure(url: URL) {
        activityView.startAnimating()
        let myBlock: SDWebImageCompletionBlock! = { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            if let img = image {
                let height = img.size.height
                let width = img.size.width

                if height < 600 || width < 600 {
                    self?.artRoomScene.setup(artInfo: img, height: img.size.height / 200, width: img.size.width / 200, position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                } else if height == 600 || width == 600  {
                    self?.artRoomScene.setup(artInfo: img, height: img.size.height / 200, width: img.size.width / 200, position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                } else if height > 600 || width > 600  {
                    self?.artRoomScene.setup(artInfo: img, height: img.size.height / 500, width: img.size.width / 500, position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                }
                self?.activityView.stopAnimating()
            }
        }
        self.imageView.sd_setImage(with: url , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
    }
}
