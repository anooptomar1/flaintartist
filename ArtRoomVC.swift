//
//  ArtRoomVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

    import UIKit
    import SceneKit
    import Firebase
    import ChameleonFramework
    import SwiftyUserDefaults
    
    class ArtRoomVC: UIViewController {
        
        @IBOutlet var scnView: SCNView!
        @IBOutlet var artInfoView: UIView!
        @IBOutlet var titleLbl: UILabel!
        @IBOutlet var typeLbl: UILabel!
        @IBOutlet var sizeLbl: UILabel!
        @IBOutlet var descriptionLbl: UILabel!
        @IBOutlet var artistNameBtn: UIButton!
        
        var artRoomScene = ArtRoomScene(create: true)
        var sceneView = SCNView()
        var artImage = UIImage()
        var artInfo: [Any] = []
        var showInfo: Bool = false
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
            
            if let info = artInfo[1] as? Art {
                self.artRoomScene.setup(artInfo: artInfo[0] as? UIImage)
                titleLbl.text = info.title
                typeLbl.text = info.type
                sizeLbl.text = "\(info.artHeight)'H x \(info.artWidth)'W - \(info.price)$ / month"
                descriptionLbl.text = info.description
                
                let userID = info.userUid
                DataService.ds.REF_USERS.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let username = value?["name"] as? String ?? ""
                    self.artistNameBtn.setTitle("\(username) ›", for: .normal)
                })
            }

            self.navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
            self.navigationController?.toolbar.setBackgroundImage(UIImage(),  forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
            self.navigationController?.toolbar.isTranslucent = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ArtRoomVC.showArtInfo))
            view.addGestureRecognizer(tapGesture)
            
//            let gesture = UIPanGestureRecognizer(target: self, action: #selector(ArtRoomVC.panDetected(sender:)))
//            scnView.addGestureRecognizer(gesture)
        }
        

        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            self.navigationController?.setToolbarHidden(false, animated: false)
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
            
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
        
        
        @IBAction func settingBtnTapped(_ sender: Any) {
            self.showAlert()
        }
        
        
        @IBAction func artistBtnTapped(_ sender: Any) {
            if let info = artInfo[1] as? Art {
               if info.userUid == FIRAuth.auth()?.currentUser?.uid {
                   tabBarController?.selectedIndex = 2
               } else {
                   performSegue(withIdentifier: "GalleryVC", sender: artInfo[1] as! Art)
                }
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
            
            let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
                //Remove
                
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(wallView)
            alert.addAction(share)
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
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "GalleryVC" {
                let vc = segue.destination as! GalleryVC
                if let post = sender as? Art {
                    vc.hidesBottomBarWhenPushed = false
                    vc.post = post
                }
            }
            
            if segue.identifier == "WallviewVC" {
                let vc = segue.destination as! WallViewVC
                if let artImage = sender as? UIImage {
                    vc.artImage = artImage
               }
            }
            
            if segue.identifier == "ReportVC" {
               let navVC = segue.destination as! UINavigationController
               let reportVC = navVC.topViewController as! ReportVC
                    reportVC.headerTitle = "Please choose the reason for reporting the Piece."
                    reportVC.artInfo = artInfo
                
            }
        }
    }
