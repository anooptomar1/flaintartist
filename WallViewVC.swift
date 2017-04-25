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
import FirebaseDatabase
    
    
class WallViewVC: UIViewController {
    
    
    @IBOutlet weak var cameraView: IPDFCameraViewController!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var mainTitleLbl: UILabel!
    @IBOutlet weak var artistView: UIView!
    @IBOutlet weak var artistImg: RoundImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var similarLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    
    var sceneView: SCNView!
    var artInfo: [Any]!
    var arts = [Art]()
    var artImage = UIImage()
    var user: Users!
    var post: Art!
    
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
    var likesRef: FIRDatabaseReference!


    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraView.setupCameraView()
        self.cameraView.isBorderDetectionEnabled = false
        self.cameraView.cameraViewType = .normal
        
        weak var weakSelf = self
        let strongSelf = weakSelf!
        let scnView = self.scnView!
        let scene = artScene
        scnView.scene = scene

        if let info = self.artInfo[1] as? Art {
            self.post = info
            likesRef = DataService.instance.REF_USER_CURRENT.child("likes").child(info.artID)
            //self.userID = info.userUid
            let image = strongSelf.artInfo[0] as? UIImage
              strongSelf.artScene.setup(artInfo: image, height: height, width: width, position: position, rotation: rotation)
            strongSelf.mainTitleLbl.text = info.title

            let date = convertDate(postDate: info.postDate)
            strongSelf.timeLbl.text = date
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

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        likesRef.observe(.value, with: { (snapshot) in
            self.likeLbl.text = " \(self.post.likes)"
            if let _ = snapshot.value as? NSNull {
                self.likeBtn.setImage( UIImage(named: "Hearts-White-22"), for: .normal)
            } else {
                self.likeBtn.setImage( UIImage(named: "Hearts Filled-22"), for: .normal)
            }
        })
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        likesRef.removeAllObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.cameraView.stop()
    }
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
       _ = navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func likeBtnTapped(_ sender: UIButton) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                DispatchQueue.main.async {
                    sender.setImage( UIImage(named: "Hearts Filled-22"), for: .normal)
                    generateAnimatedView(view: self.view, position: self.likeBtn.layer.position)
                    self.likeLbl.text = "\(self.post.likes)"
                }
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                
            } else {
                DispatchQueue.main.async {
                    sender.setImage( UIImage(named: "Hearts-White-22"), for: .normal)
                    self.likeLbl.text = "\(self.post.likes)"
                }
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
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
            collectionView.isHidden = true
        } else {
            showSimilar = true
            let attributedString = NSMutableAttributedString(string: "Similar ")
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "Collapse Arrow white Filled-10")
            attributedString.append(NSAttributedString(attachment: attachment))
            self.similarLbl.attributedText = attributedString
            collectionView.isHidden = false
        }
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
            
            artScene.boxnode.eulerAngles.y = Float(2 * Double.pi) * widthRatio
            lastFingersNumber = fingersNeededToPan
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
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
            self.likeBtn.isHidden = true
            self.likeLbl.isHidden = true
            let view = self.view.captureView()
            self.likeBtn.isHidden = false
            self.likeLbl.isHidden = false
            self.shareChoice(view: view)
        }
        
        let report = UIAlertAction(title: "Report", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "ReportVC", sender: self.artInfo[1])
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarCell", for: indexPath) as? SimilarCell {
            let art = arts[indexPath.row]
            cell.configureCell(forArt: art)
            return cell
        } else {
            return SimilarCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! SimilarCell
        let artImage = cell.artImageView.image
        self.artInfo[0] = artImage!
        let art = arts[indexPath.row]
        //self.userID = art.userUid
        let height = (artImage?.size.height)! / 700
        let width = (artImage?.size.width)! / 700
        artScene.boxnode.removeFromParentNode()
        artScene.setup(artInfo: artImage, height: height, width: width, position: position, rotation: rotation)
        mainTitleLbl.text = art.title
        let date = convertDate(postDate: art.postDate)
        timeLbl.text = date
        textView.text = "\(art.artHeight)'H x \(art.artWidth)'W - \(art.price)$ / month - \(art.type) \n \(art.description)."
        
         DispatchQueue.main.async {
            self.nameLbl.text = self.user.name
            self.artistImg.sd_setImage(with: URL(string: "\(self.user.profilePicUrl!)") , placeholderImage: UIImage(named:"Placeholder") , options: .continueInBackground)
         }
    }
}

