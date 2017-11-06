//
//  ArtCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-24.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SpriteKit
import SceneKit
import Reusable
import SDWebImage
import NXDrawKit

var canvassView: Canvas?

final class ArtCell: UICollectionViewCell, Reusable, UIGestureRecognizerDelegate, CanvasDelegate, PaletteDelegate {
    
    lazy var artRoomScene = ArtRoomScene(create: true)
    lazy var alert = Alerts()
    var toolCell = ToolCell()
    var infoCell: UserInfoCell?
    var imageView = UIImageView()
    var artID: String?
    
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
    private var  lpgr = UILongPressGestureRecognizer()
    private var rotateActived: Bool = false
    
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
        
//        let spriteScene = OverlayScene(size: contentView.bounds.size)
//        sceneView.overlaySKScene = spriteScene
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognize:)))

        lpgr  = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        sceneView.addGestureRecognizer(lpgr)
        
        NotificationCenter.default.addObserver(self, selector: #selector(markerActivated), name: markerIsActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markerDesactivated), name: markerIsDesactivated, object: nil)
        initialize()
    }
    
    @objc func markerActivated() {
        self.sceneView.removeGestureRecognizer(panGesture)
        self.sceneView.removeGestureRecognizer(lpgr)
        canvassView?.isHidden = false
    }
    
    @objc func markerDesactivated() {
        canvassView?.isHidden = true
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
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    fileprivate func initialize() {
        self.setupCanvas()
    }


    fileprivate func setupCanvas() {
        let canvasView = Canvas()
        canvasView.frame = self.bounds
        canvasView.delegate = self
        canvasView.clipsToBounds = true
        
        self.addSubview(canvasView)
        canvasView.isHidden = true
        canvassView = canvasView
    }
    
    
    func updateToolBarButtonStatus(_ canvas: Canvas) {
        tooolBar?.undoButton?.isEnabled = canvas.canUndo()
        tooolBar?.redoButton?.isEnabled = canvas.canRedo()
        tooolBar?.saveButton?.isEnabled = canvas.canSave()
        tooolBar?.clearButton?.isEnabled = canvas.canClear()
    }


        func brush() -> Brush? {
            return palettteView?.currentBrush()
        }
        
        func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
            self.updateToolBarButtonStatus(canvas)
        }
        
        func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
                print("DID SAVE")
                // you can save merged image
                //        if let pngImage = image?.asPNGImage() {
                //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                //        }
                
                // you can save strokeImage
                //        if let pngImage = drawing.stroke?.asPNGImage() {
                //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                //        }
                
                //        self.updateToolBarButtonStatus(canvas)
                
                // you can share your image with UIActivityViewController
                if let pngImage = image?.asPNGImage() {
                    let data = UIImageJPEGRepresentation(pngImage, 0.0)
                    //DataService.instance.saveArtDrawing(artID!, data: data!)

    }

       
    }
        // tag can be 1 ... 12
        func colorWithTag(_ tag: NSInteger) -> UIColor? {
            if tag == 4 {
                // if you return clearColor, it will be eraser
                return UIColor.clear
            }
        return nil
    }
}

extension ArtCell {
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizerState.ended){
            if !rotateActived {
                rotateActived = true
                sceneView.addGestureRecognizer(panGesture)
                alert.showNotif(text: "Rotation enabled", vc: self.viewController!, backgroundColor: UIColor.clear, textColor: self.tintColor, autoHide: true, position: .bottom)
            } else {
                rotateActived = false
                sceneView.removeGestureRecognizer(panGesture)
                alert.showNotif(text: "Rotation disabled", vc: self.viewController!, backgroundColor: UIColor.clear, textColor: .lightGray, autoHide: true, position: .bottom)
            }
        }
    }
    
    func configure(url: URL) {
        artRoomScene.boxnode.removeFromParentNode()
        activityView.startAnimating()
        let myBlock: SDWebImageCompletionBlock! = { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            if let img = image {
                self?.artRoomScene.setup(artInfo: img, height: img.size.height/((self?.frame.height)!/2) , width: img.size.width/((self?.frame.width)!/2), position: SCNVector3(0, 0.4, -1.5), rotation: SCNVector4(0,60,0,-56))
                self?.artRoomScene.boxnode.scale = SCNVector3(x: 0.6, y: 0.6, z: 0.5)
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
    
    func scaleUIImageToSize(_ image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
