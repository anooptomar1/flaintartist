//
//  ProfileVCExt.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-07.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import Firebase
import SDWebImage
import SwiftMessages
import SwiftyUserDefaults

extension ProfileVC {
    
    func showRequestAlert(artImage: UIImage?, art: Art?, artRoomScene: ArtRoomScene) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in
            self.b = MyBool.True
            self.switchInfo()
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
    
    // Save Info Actions
    
    @objc func switchInfo() {
        switch b {
        case .True:
            self.infoView.isHidden = false
            self.swipeLabel.text = "Edit Mode"
            self.titleTextField.text = art?.title
            self.typeTextField.text = art?.type
            self.priceTextField.text = "\(String(describing: art?.price))"
            self.heightTextField.text = "\(String(describing: art!.artHeight))"
            self.widthTextField.text = "\(String(describing: art!.artWidth))"
            self.rotateButton.setImage(UIImage(named: ""), for: .normal)
            self.addButton.setImage(UIImage(named: ""), for: .normal)
            self.addButton.setTitle("Cancel", for: .normal)
            self.rotateButton.setTitle("Save", for: .normal)
            self.addButton.setTitleColor( UIColor.gray, for: .normal)
            self.rotateButton.setTitleColor( UIColor.blue, for: .normal)
            self.addButton.removeTarget(self, action: #selector(self.addBtnTapped(_:)), for: .touchUpInside)
            self.addButton.removeTarget(self, action: #selector(self.cameraBtnTapped(sender:)), for: .touchUpInside)
            self.addButton.addTarget(self, action:  #selector(ProfileVC.cancelSave), for: .touchUpInside)
            self.rotateButton.addTarget(self, action: #selector(ProfileVC.saveInfo), for: .touchUpInside)
        case .False:
            self.infoView.isHidden = true
            self.view.endEditing(true)
            self.swipeLabel.text = ""
            self.rotateButton.setImage(#imageLiteral(resourceName: "Synchronize-24"), for: .normal)
            self.addButton.setImage(#imageLiteral(resourceName: "add"), for: .normal)
            self.addButton.setTitle("", for: .normal)
            self.rotateButton.setTitle("", for: .normal)
            self.addButton.addTarget(self, action: #selector(ProfileVC.addBtnTapped(_:)), for: .touchUpInside)
            self.rotateButton.addTarget(self, action: #selector(ProfileVC.cameraBtnTapped(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func saveInfo() {
        let ref = DataService.instance.REF_ARTISTARTS.child(Defaults[.key_uid]!).child((self.art?.artID)!)
        let title = titleTextField.text!
        let type = typeTextField.text!
        let height = heightTextField.text!
        let width = widthTextField.text!
        ref.updateChildValues(["title": title, "type": type, "artHeight": height, "artWidth": width]) { (error, reference) in
            guard error == nil else {
                print("ERROR SAVE NEW INFO")
                return
            }
        }
    }
    
    
    @objc func cancelSave() {
        self.b = MyBool.False
        switchInfo()
        
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
        let width: CGFloat = v!.frame.size.width
        let height: CGFloat = v!.frame.size.height
        
        v?.contentMode = .scaleAspectFill
        v?.layer.masksToBounds = true
        v?.layer.cornerRadius = (v?.frame.width)! / 2
        v?.isUserInteractionEnabled = true
        
        v?.layer.borderWidth = 1.3
        v?.layer.borderColor = UIColor.white.cgColor
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width + 4), height: CGFloat(height + 4))
        
        let ringProgressView = MKRingProgressView(frame: frame)
        ringProgressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ringProgressView.addSubview(v!)
        
        let profileBtn = UIBarButtonItem(customView: ringProgressView)
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsBtnTapped(_:))))
        
        
        DataService.instance.currentUserInfo { (user) in
            if let url = user?.profilePicUrl {
                self.v?.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .continueInBackground, completed: { (image, error, cache, url) in
                    
                })
            }
        }
        self.navigationItem.leftBarButtonItem = profileBtn
        //profileBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsBtnTapped(_:))))
        self.navigationItem.leftBarButtonItem = profileBtn
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.showsCancelButton = false
        self.searchController.searchBar.placeholder = "Search"
        self.searchController.searchBar.returnKeyType = .done
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchBar.becomeFirstResponder()
        //self.navigationItem.titleView = searchController.searchBar
        self.searchController.dimsBackgroundDuringPresentation = false
        
        pageControl = FlexiblePageControl(frame: bottomView.bounds)
        pageControl.isUserInteractionEnabled = true
        pageControl.dotSize = 6
        pageControl.dotSpace = 5
        pageControl.hidesForSinglePage = true
        pageControl.displayCount = 5
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.flatGrayColorDark()
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
            alert.showNotif(text: "No internet connection.", vc: self, backgroundColor: UIColor.flatRed(), textColor: UIColor.flatWhite(), autoHide: false)
        }
        print(currentReachabilityStatus != .notReachable) //true connected
    }
}


