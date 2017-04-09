//
//  WallviewVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import SceneKit
import FirebaseAuth
    
    
class WallViewVC: UIViewController{
    
    
    @IBOutlet weak var cameraView: IPDFCameraViewController!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var mainTitleLbl: UILabel!
    @IBOutlet weak var artistView: UIView!
    @IBOutlet weak var artistImg: RoundImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var similarLbl: UILabel!
    
    
    var sceneView: SCNView!
    var artInfo: [Any]!
    var artImage = UIImage()
    var user: Users!
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var maxWidthRatioRight: Float = 0.2
    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = 0.02
    var maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 80.0
    var lastFingersNumber = 0
    
    var panGesture = UIPanGestureRecognizer()
    
    let editNotif = NSNotification.Name("Show")
    let cancelNotif = NSNotification.Name("Hide")
    
    var artScene = WallViewScene(create: true)
    var position = SCNVector3()
    var rotation = SCNVector4()
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    
    
    var showInfo = false
    var showSimilar: Bool = false

    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    override func viewDidLoad() {
        self.cameraView.setupCameraView()
        self.cameraView.isBorderDetectionEnabled = false
        self.cameraView.cameraViewType = .normal
        super.viewDidLoad()
        
        weak var weakSelf = self
        let strongSelf = weakSelf!
        let scnView = self.scnView!
        let scene = artScene
        scnView.scene = scene

        if let info = self.artInfo[1] as? Art {
            DataService.instance.seen(artUID: info.artID, imgUrl: info.imgUrl, title: info.title, description: info.description, price: info.price, height: info.artHeight, width: info.artWidth, type: info.type, date: info.postDate, userUID: info.userUid)
            //self.userID = info.userUid
            let image = strongSelf.artInfo[0] as? UIImage
              strongSelf.artScene.setup(artInfo: image, height: height, width: width, position: position, rotation: rotation)
            strongSelf.mainTitleLbl.text = info.title
            let date = info.postDate / 1000
            let foo: TimeInterval = TimeInterval(date)
            let theDate = NSDate(timeIntervalSince1970: foo)
            let time = timeAgoSinceDate(date: theDate as Date, numericDates: true)
            strongSelf.timeLbl.text = "\(time)"
            strongSelf.textView.text = "\(info.artHeight)'H x \(info.artWidth)'W - \(info.price)$ / month - \(info.type) \n \(info.description)."
            if let url = user.profilePicUrl {
                artistImg.sd_setImage(with: URL(string: "\(url)") , placeholderImage: UIImage(named:"Placeholder"))
            }
            nameLbl.text = user.name
        }

        //scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.clear
        scnView.isJitteringEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(WallViewVC.handlePan(gestureRecognize:)))
        scnView.addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(WallViewVC.handlePinch(gestureRecognize:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WallViewVC.showAlert))
        scnView.addGestureRecognizer(tapGesture)
        let tapUserGesture = UITapGestureRecognizer(target: self, action: #selector(WallViewVC.artistBtnTapped))
        artistView.addGestureRecognizer(tapUserGesture)
        let similarGesture = UITapGestureRecognizer(target: self, action: #selector(WallViewVC.similarLblTapped))
        similarLbl.addGestureRecognizer(similarGesture)
        
        let attributedString = NSMutableAttributedString(string: "Similar ")
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "Expand Arrow Filled-10")
        attributedString.append(NSAttributedString(attachment: attachment))
        self.similarLbl.attributedText = attributedString

        
    }
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
       _ = navigationController?.popViewController(animated: false)
    }
    
    
    
    @IBAction func infoBtnTapped(_ sender: UIBarButtonItem) {
        if showInfo {
            showInfo = false
            navigationItem.rightBarButtonItem?.image = UIImage(named: "info-20")
            sender.tintColor = UIColor.flatWhiteColorDark()
            self.mainTitleLbl.isHidden = true
            self.textView.isHidden = true
        } else {
            showInfo = true
            navigationItem.rightBarButtonItem?.image = UIImage(named: "Info-white-20")
            self.mainTitleLbl.isHidden = false
            self.textView.isHidden = false
        }
    }
    
    func artistBtnTapped() {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            if id != "" {
                if user.userId == id {
                    tabBarController?.selectedIndex = 2
                } else {
                    let galleryVC = storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
                    galleryVC.user = user
                    galleryVC.hidesBottomBarWhenPushed = true
                    DispatchQueue.main.async {
                        _ = self.navigationController?.pushViewController(galleryVC, animated: true)
                    }
                }
            }
        }
    }
    
    
    func similarLblTapped() {
        if showSimilar {
            showSimilar = false
            let attributedString = NSMutableAttributedString(string: "Similar ")
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "Expand Arrow Filled-10")
            attributedString.append(NSAttributedString(attachment: attachment))
            self.similarLbl.attributedText = attributedString
            //collectionView.isHidden = true
        } else {
            showSimilar = true
            let attributedString = NSMutableAttributedString(string: "Similar ")
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "Collapse Arrow white Filled-10")
            attributedString.append(NSAttributedString(attachment: attachment))
            self.similarLbl.attributedText = attributedString
            //collectionView.isHidden = false
        }
    }
    

    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        navigationController?.toolbar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.cameraView.stop()
    }
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        let numberOfTouches = gestureRecognize.numberOfTouches
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        var widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) - lastWidthRatio
        var heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) - lastHeightRatio
        
        if (numberOfTouches == fingersNeededToPan) {
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            artScene.boxnode.eulerAngles.y = Float(2 * M_PI) * widthRatio
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let zoom = gestureRecognize.scale
        let zoomLimits: [Float] = [5.0]
        var z = artScene.cameraOrbit.position.z  * Float(1.0 / zoom)
        z = fminf(zoomLimits.max()!, z)
        DispatchQueue.main.async {
            self.artScene.cameraOrbit.position.z = z
        }
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        
        let shareView = UIAlertAction(title: "Share view", style: .default) { (action) in
            // Share view
            self.similarLbl.isHidden = true
            let view = self.view.captureView()
            self.similarLbl.isHidden = false
            self.shareChoice(view: view)
        }
        
        let report = UIAlertAction(title: "Report", style: .destructive) { (action) in
            
            self.performSegue(withIdentifier: "ReportVC", sender: self.artInfo[1])
            // Report
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(shareView)
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func shareChoice(view: UIImage) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default) { (action) in
            let share = Share()
            share.facebookShare(self, image: view, text: "What do you think?")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(facebook)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReportVC" {
            let navVC = segue.destination as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose the reason for reporting the Piece."
            reportVC.artInfo = artInfo
        }
    }

}


