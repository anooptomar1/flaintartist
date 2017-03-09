//
//  NewsCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import SceneKit
import SDWebImage


class NewCell: UICollectionViewCell {

    @IBOutlet weak var scnView: SCNView!
    
    var artImgView = UIImageView()
    //var motionManager: CMMotionManager!
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
        scnView.backgroundColor = UIColor.clear
        
        
        //        motionManager = CMMotionManager()
        //        motionManager.deviceMotionUpdateInterval = 1.0
        //        motionManager.startDeviceMotionUpdates(
        //            to: OperationQueue.current!, withHandler: {
        //                (deviceMotion, error) -> Void in
        //                if(error == nil) {
        //                    let y = CGFloat((self.motionManager.deviceMotion?.rotationRate.y)!)
        //                    let rotateForHeight = SCNAction.rotateTo(x: 0, y: y, z: 0, duration: 0.2)
        //                    rotateForHeight.speed = 1
        //                    rotateForHeight.timingMode = SCNActionTimingMode.linear;
        //                    let stopAnimation = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5)
        //                    let heightFlow = SCNAction.sequence([rotateForHeight, stopAnimation])
        //                    DispatchQueue.main.async {
        //                        //self.otherScene.boxnode.runAction(rotateForHeight)
        //                    }
        //
        //                } else {
        //                    print("ERROR: \(error?.localizedDescription)")
        //                    //handle the error
        //                }
        //       })
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
            self?.otherScene.setup(artInfo: image, height: image!.size.height / 500, width: image!.size.width / 500)
        }
        self.artImgView.sd_setImage(with: URL(string: "\(self.art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
    }
}
