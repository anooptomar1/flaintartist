//
//  ArtRoomVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

    import UIKit
    import SDWebImage
    import SceneKit
    import Firebase
    import ChameleonFramework
    import SwiftyUserDefaults
    
    class ArtRoomVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
        
        @IBOutlet var scnView: SCNView!
        @IBOutlet var artInfoView: UIView!
        @IBOutlet var titleLbl: UILabel!
        @IBOutlet var typeLbl: UILabel!
        @IBOutlet var sizeLbl: UILabel!
        @IBOutlet var descriptionLbl: UILabel!
        @IBOutlet var artistNameBtn: UIButton!
        @IBOutlet var stackView: UIStackView!
        var collectionView: UICollectionView!
        
        var artRoomScene = ArtRoomScene(create: true)
        var sceneView = SCNView()
        var artImage = UIImage()
        var artInfo: [Any] = []
        var posts = [Art]()
        var post: Art!
        var user: Users!
        var showInfo: Bool = false
        var showSimilar: Bool = false
        let alert = Alerts()
        
        var lastWidthRatio: Float = 0
        var lastHeightRatio: Float = 0
        
        static var imageCache: NSCache<NSString, UIImage> = NSCache()
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.artInfoView.isHidden = false
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            scnView = self.scnView!
            let scene = artRoomScene
            scnView.scene = scene
            
            scnView.allowsCameraControl = true
            scnView.autoenablesDefaultLighting = true
            scnView.isJitteringEnabled = true
            
            scnView.backgroundColor = UIColor.white
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: 70, height: 70)
            
            collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            collectionView.dataSource = self
            collectionView.delegate = self
            let similarCell = UINib(nibName: "SimilarCell", bundle:nil)
            collectionView.register(similarCell, forCellWithReuseIdentifier: "SimilarCell")
            collectionView.backgroundColor = UIColor(white: 1, alpha: 1)
            
            if let info = artInfo[1] as? Art {
                let image = artInfo[0] as? UIImage
                let height = (image?.size.height)! / 1000
                let width = (image?.size.width)! / 1000
                self.artRoomScene.setup(artInfo: image, height: height, width: width)
                titleLbl.text = info.title
                typeLbl.text = info.type
                sizeLbl.text = "\(info.artHeight)'H x \(info.artWidth)'W - \(info.price)$ / month"
                descriptionLbl.text = info.description
                
                DataService.ds.REF_USERS.child("\(info.userUid)").observe(.value, with: { (snapshot) in
                    
                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                        let key = snapshot.key
                        self.user = Users(key: key, artistData: postDict)
                        
                        if let user = self.user {
                            self.artistNameBtn.setTitle("\(user.name) ›", for: .normal)

                        }
                    }
                })
            }

            self.navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
            self.navigationController?.toolbar.setBackgroundImage(UIImage(),  forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
            self.navigationController?.toolbar.isTranslucent = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ArtRoomVC.showArtInfo))
            tapGesture.numberOfTapsRequired = 2
            stackView.addGestureRecognizer(tapGesture)
            
//            let gesture = UIPanGestureRecognizer(target: self, action: #selector(ArtRoomVC.panDetected(sender:)))
//            scnView.addGestureRecognizer(gesture)
            

            
//            let similarCell = UINib(nibName: "SimilarCell", bundle:nil)
//            collectionView.register(similarCell, forCellWithReuseIdentifier: "SimilarCell")
        }
        

        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            FIRDatabase.database().reference().child("arts").queryOrdered(byChild: "type").queryEqual(toValue : typeLbl.text).queryLimited(toFirst: 3).observe(.value) { (snapshot: FIRDataSnapshot) in
                self.posts = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let post = Art(key: key, artData: postDict)
                            self.posts.insert(post, at: 0)
                        }
                    }
                }
                self.collectionView.reloadData()
            }

            self.navigationController?.setToolbarHidden(false, animated: false)
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
            UIView.animate(withDuration: 1.5) {
                self.navigationController?.navigationBar.alpha = 0
                self.navigationController?.toolbar.tintColor = UIColor(white: 1, alpha: 0)
                self.navigationController?.setToolbarHidden(true, animated: true)
            }
        }
        
        
        
//        func panDetected(sender: UIPanGestureRecognizer) {
//            
//            let translation = sender.translation(in: sender.view!)
//            let widthRatio = Float(translation.x) / Float(sender.view!.frame.size.width) + lastWidthRatio
//            let heightRatio = Float(translation.y) / Float(sender.view!.frame.size.height) + lastHeightRatio
//            artRoomScene.boxnode.eulerAngles.y = Float(-M_PI_2) + Float(-M_PI_2) * widthRatio
//            
//            print(Float(-2 * M_PI) * widthRatio)
//            
//            if (sender.state == .ended) {
//                lastWidthRatio = widthRatio.truncatingRemainder(dividingBy: 1)
//                lastHeightRatio = heightRatio.truncatingRemainder(dividingBy: 1)
//            }
//        }
        
        
        
        
    @IBAction func similarBtnTapped(_ sender: Any) {
        
        if showSimilar {
            showSimilar = false
        } else {
            showSimilar = true
            UIView.animate(withDuration: 0.5, animations: {
            self.stackView.insertArrangedSubview(self.collectionView, at: 1)
            
            })
        }
    }
        
        
        
        @IBAction func moreBtnTapped(_ sender: Any) {
            self.showAlert()
        }

        
        
        @IBAction func artistBtnTapped(_ sender: Any) {
            if user.userId == FIRAuth.auth()?.currentUser?.uid {
                   tabBarController?.selectedIndex = 2
               } else {
                   performSegue(withIdentifier: "GalleryVC", sender: user)
            }
        }
        
        func showArtInfo() {
            if showInfo {
                showInfo = false
                UIView.animate(withDuration: 1.3) {
                    self.artInfoView.alpha = 0
                    self.navigationController?.navigationBar.alpha = 0
                    self.navigationController?.setToolbarHidden(true, animated: true)
                }
                
            } else {
                showInfo = true
                UIView.animate(withDuration: 1.3) {
                    self.artInfoView.alpha = 1
                    self.navigationController?.navigationBar.alpha = 1
                    self.navigationController?.setToolbarHidden(false, animated: true)
                }
            }
        }
        
        
        func showAlert() {
            if let info = artInfo[1] as? Art {
                if info.userUid == FIRAuth.auth()?.currentUser?.uid {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "WallviewVC", sender: self.artInfo[0] as! UIImage)
            })
            
            let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
                self.share()
            })
                    
            let edit = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "EditArtVC", sender: self.artInfo[0] as! UIImage )
            })

            
            let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
                //self.remove()
                if let info = self.artInfo[1] as? Art {
                    DataService.ds.REF_USERS.child(self.user.userId).child("arts").child(info.artID).removeValue(completionBlock: { (error, ref) in
                        DataService.ds.REF_ARTS.child(ref.key).removeValue()
                        return
                    })
                }
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(wallView)
            alert.addAction(share)
            alert.addAction(edit)
            alert.addAction(remove)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
                    
            } else {
                    
                let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
                    self.performSegue(withIdentifier: "WallviewVC", sender:self.artInfo[0] as! UIImage)
                    })
                    
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
                        self.share()
                    })
                
                 let report = UIAlertAction(title: "Report", style: .destructive, handler: { (UIAlertAction) in
                    self.performSegue(withIdentifier: "ReportVC", sender: self.artInfo[1])
                 })
                    
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                alert.addAction(wallView)
                alert.addAction(share)
                alert.addAction(report)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
        }
    }
        
        
        func share() {
            let share = Share()
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let facebook = UIAlertAction(title: "Facebook", style: .default, handler: { (UIAlertAction) in
                share.facebookShare(self, image: self.artInfo[0] as! UIImage, text: self.titleLbl.text!)
            })
            
            let messenger = UIAlertAction(title: "Mesenger", style: .default, handler: { (UIAlertAction) in
                //share.messengerShare(self, image: self.artInfo[0] as! UIImage)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(facebook)
            alert.addAction(messenger)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
        }
        
        
        func remove() {
            let alert = Alerts()
            if let info = artInfo[1] as? Art {
                
            DataService.ds.REF_USERS.child(self.user.userId).child("arts").child(info.artID).removeValue(completionBlock: { (error, ref) in
                 DataService.ds.REF_ARTS.child(ref.key).removeValue()
                 alert.showAlert("\(info.title) have been removed successfully", message: "", target: self)
                 return
               })
             }
           }
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "GalleryVC" {
                let navVC = segue.destination as! UINavigationController
                let vc = navVC.topViewController as! GalleryVC
                vc.hidesBottomBarWhenPushed = true
                if let user = sender as? Users {
                    vc.user = user
                }
            }
            
            if segue.identifier == "WallviewVC" {
                let vc = segue.destination as! WallViewVC
                if let artImage = sender as? UIImage {
                    vc.artImage = artImage
               }
            }
            
            if segue.identifier == "EditArtVC" {
                let navVC = segue.destination as! UINavigationController
                let vc = navVC.topViewController as! EditArtVC
                vc.artImg = self.artInfo[0] as! UIImage
                vc.artDetails = self.artInfo[1] as! Art
            }
            
            if segue.identifier == "ReportVC" {
               let navVC = segue.destination as! UINavigationController
               let reportVC = navVC.topViewController as! ReportVC
                    reportVC.headerTitle = "Please choose the reason for reporting the Piece."
                    reportVC.artInfo = artInfo
                
            }
        }
    }


extension ArtRoomVC {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = posts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarCell", for: indexPath) as? SimilarCell {
            DispatchQueue.main.async {
            }
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                //cell.similarScene.setup(artInfo: image)
            }
            
            cell.artImageView.sd_setImage(with: URL(string: "\(post.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            return cell
        } else {
            return SimilarCell()
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? SimilarCell {
        let art = posts[indexPath.row]
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.titleLbl.text = art.title
                self.artistNameBtn.setTitle(self.user.name, for: .normal)
                self.typeLbl.text = art.type
                self.sizeLbl.text =  "\(art.artHeight)'H x \(art.artWidth)'W - \(art.price)$ / month"
                self.descriptionLbl.text = art.description       
                let material = SCNMaterial()
                let lenght: CGFloat = CGFloat(57)
                let image = cell.artImageView.image
                material.diffuse.contents = image
                self.artRoomScene.geometry.firstMaterial =  material
                self.artRoomScene.geometry.height = (image?.size.height)! / 1000
                self.artRoomScene.geometry.width = (image?.size.width)! / 1000
              })
           }
        }
    }
}
