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

protocol RemoveCellDelegate: class {
    func removeCellDidTapButton(_ cell: ArtCell)
}

final class ArtCell: UICollectionViewCell, Reusable {
    
    lazy var artRoomScene = ArtRoomScene(create: true)
    lazy var share = Share()
    var imageView = UIImageView()
    
    private var lastWidthRatio: Float = 0
    private var lastHeightRatio: Float = 0.2
    private var fingersNeededToPan = 1
    private var maxWidthRatioRight: Float = 0.2
    private var maxWidthRatioLeft: Float = -0.2
    private var maxHeightRatioXDown: Float = 0.02
    private var maxHeightRatioXUp: Float = 0.4
    
    private var pinchAttenuation = 80.0
    private var lastFingersNumber = 0
    private var panGesture = UIPanGestureRecognizer()
    
    fileprivate let sceneView: SCNView = {
        let view = SCNView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
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
        let scene = artRoomScene
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.isJitteringEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognize:)))
        sceneView.addGestureRecognizer(panGesture)
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
                self?.artRoomScene.setup(artInfo: img, height:  height / ((UIScreen.main.bounds.height) - 186) , width: width / ((UIScreen.main.bounds.width) + 186), position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                self?.activityView.stopAnimating()
            }
        }
        self.imageView.sd_setImage(with: url , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
    }
    
    @objc func handlePan(gestureRecognize: UIPanGestureRecognizer) {
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
            
            self.artRoomScene.boxnode.eulerAngles.y = Float(2 * Double.pi) * widthRatio
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
        }
        
        if gestureRecognize.state == .began ||  gestureRecognize.state == .changed {
        } else if gestureRecognize.state == .cancelled || gestureRecognize.state == .ended {
        }
    }
    
    
    @objc func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let zoom = gestureRecognize.scale
        let zoomLimits: [Float] = [5.0]
        var z = artRoomScene.cameraOrbit.position.z  * Float(1.0 / zoom)
        z = fminf(zoomLimits.max()!, z)
        DispatchQueue.main.async {
            self.artRoomScene.cameraOrbit.position.z = z
        }
        if gestureRecognize.state == .began ||  gestureRecognize.state == .changed {
        } else if gestureRecognize.state == .cancelled || gestureRecognize.state == .ended {
        }
    }
}
