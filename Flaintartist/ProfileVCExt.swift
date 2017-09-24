//
//  ProfileVCExt.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-07.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import Firebase
import SDWebImage
import SwiftyUserDefaults

extension ProfileVC {
    
    func showRequestAlert(artImage: UIImage?, art: Art?, artRoomScene: ArtRoomScene) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit art", style: .default, handler: { (UIAlertAction) in
            self.b = MyBool.True
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
            vc.art = art
            vc.modalPresentationStyle = UIModalPresentationStyle.custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        })
        
        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            
            for cell in self.collectionView.visibleCells {
                let indexPath = self.collectionView.indexPath(for: cell as! ProfileArtCell)
                let cell = self.collectionView.cellForItem(at: indexPath!) as! ProfileArtCell
                let image = cell.scnView.snapshot()
                self.shareChoice(view: image)
            }
        })
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            self.removeRequest(art: art)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(edit)
        alert.addAction(share)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
    
    
    
    @objc func cancelSave() {
        self.b = MyBool.False
        //switchInfo()
        
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
    
    func removeRequest(art: Art?) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove \(String(describing: art!.title)). After removing it, you can't get it back.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Remove from gallery", style: .destructive) { (UIAlertAction) in
            
            if let artId = art?.artID {
                DataService.instance.REF_ARTISTARTS.child((Auth.auth().currentUser?.uid)!).child(artId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        print("Failed to delete art:", error!)
                        return
                    }
                    SDImageCache.shared().removeImage(forKey: art?.imgUrl, fromDisk: true)
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func hideBars() {
        UIView.animate(withDuration: 1.3) {
            self.navigationController?.navigationBar.alpha = 1
        }
    }
    
    @objc func showBars() {
        UIView.animate(withDuration: 2.5) {
            self.navigationController?.navigationBar.alpha = 0
        }
    }
    
    
    // MARK: - Set Delegate
    func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    // MARK: - Views
    func setupViews() {
        v = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(30), height: CGFloat(30)))
        v?.contentMode = .scaleAspectFill
        v?.layer.masksToBounds = true
        v?.layer.cornerRadius = (v?.frame.width)! / 2
        v?.isUserInteractionEnabled = true
        
        v?.layer.borderWidth = 1.3
        v?.layer.borderColor = UIColor.white.cgColor
        
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsBtnTapped(_:))))
        
        self.navigationItem.titleView = v
        
        pageControl = FlexiblePageControl(frame: bottomView.bounds)
        pageControl.isUserInteractionEnabled = true
        pageControl.dotSize = 6
        pageControl.dotSpace = 5
        pageControl.hidesForSinglePage = true
        pageControl.displayCount = 5
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        pageControl.autoresizingMask = [.flexibleWidth]
        bottomView.addSubview(pageControl)
        pageControl.updateViewSize()
    }
    
    // Add Gestures
    
    func addGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeRight.direction = .right
        self.bottomView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeDown.direction = .left
        self.bottomView.addGestureRecognizer(swipeDown)
    }
    
    func verifyConnection() {
        if currentReachabilityStatus == .notReachable {
            let alert = Alerts()
            alert.showNotif(text: "No internet connection.", vc: self, backgroundColor: UIColor.red, textColor: UIColor.lightGray, autoHide: false)
        }
        print(currentReachabilityStatus != .notReachable) //true connected
    }
}

class HalfSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect  {
        return CGRect(x: 0 , y: 372, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
        
    }
    
}


