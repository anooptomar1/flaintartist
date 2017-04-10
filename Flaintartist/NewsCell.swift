//
//  NewsCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import SceneKit
import SDWebImage
import FirebaseDatabase


class NewCell: UICollectionViewCell {

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var artistImgView: RoundImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    var artImgView = UIImageView()
    var otherScene = Other(create: true)
    var art: Art!
    var user: Users!
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 0.2
    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = 0.02
    var maxHeightRatioXUp: Float = 0.4
    var lastFingersNumber = 0

    var panGesture = UIPanGestureRecognizer()

    
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
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(NewCell.handlePan(gestureRecognize:)))
        scnView.addGestureRecognizer(panGesture)
    }
    
    deinit {
        print("NewCell is Dealloc")
        scnView.removeGestureRecognizer(panGesture)
        scnView.removeFromSuperview()
        otherScene.remove()
        
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
        self.artImgView.sd_setImage(with: URL(string: "\(self.art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
       
        nameLbl.text = self.art.userName
        if let url = self.art.profileImgUrl {
        self.artistImgView.sd_setImage(with: URL(string: "\(url)") , placeholderImage: nil)
        }
        let date = convertDate(postDate: self.art.postDate)
        dateLbl.text = "\(date)"
    }
    
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        let numberOfTouches = gestureRecognize.numberOfTouches
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        var widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) - lastWidthRatio
        var heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) - lastHeightRatio
        
        if (numberOfTouches == fingersNeededToPan) {
            //  HEIGHT constraints
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            //  WIDTH constraints
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            self.otherScene.boxnode.eulerAngles.y = Float(2 * M_PI) * widthRatio
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
        }
    }
}
