//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import Firebase
import SDWebImage
import DZNEmptyDataSet
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SDWebImagePrefetcherDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
    let refreshCtrl = UIRefreshControl()
    var tapGesture = UITapGestureRecognizer()
    var segmentedCtrl = UISegmentedControl()
    
    let editNotif = NSNotification.Name("edit")
    let cancelNotif = NSNotification.Name("cancel")
    let kPrefetchRowCount = 10
    
    var sizeView = SizeView()
    var typesView = UIView()
    var DetailsView = UIView()
    var swipeView = SwipeView()
    var cell = ProfileArtCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        loadUserInfo()
        //websiteTextView.delegate = self
        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
            self.arts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Art(key: key, artData: postDict)
                        self.art = Art(key: key, artData: postDict)
                        self.arts.insert(post, at: 0)
                    }
                }
            }
            
            self.collectionView.reloadData()
        }
        
        refreshCtrl.tintColor = UIColor.flatBlack()
        refreshCtrl.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshCtrl)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.updateLbl), name: editNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.updateLbl), name: cancelNotif, object: nil)
        
        // add a tap gesture recognizer
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }

    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "SettingsVC", sender: user)
    }
    
    
    func refresh() {
        tableView.reloadData()
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            refreshCtrl.endRefreshing()
        }
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let art = arts[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
        let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
            cell.artRoomScene.setup(artInfo: image, height: image!.size.height / 700, width: image!.size.width / 700)
        }
        cell.artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
        DispatchQueue.main.async {
        cell.titleLbl.text = art.title
        cell.typeLbl.text = art.type
        cell.sizeLbl.text = "\(art.artHeight)'H x \(art.artWidth)'W - \(art.price)$ / month"
        cell.descLbl.text = art.description
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.showAlert(sender:)))
        cell.addGestureRecognizer(self.tapGesture)
    }

        return cell
            
        } else {
            return ProfileArtCell()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
//    func prefetchImages(for tableView: UITableView) {
//        // determine the minimum and maximum visible rows
//        var indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
//        var minimumVisibleRow: Int = (indexPathsForVisibleRows[0]).row
//        var maximumIndexPath: Int = (indexPathsForVisibleRows[0]).row
//        for indexPath: IndexPath in indexPathsForVisibleRows {
//            if indexPath.row < minimumVisibleRow {
//                minimumVisibleRow = indexPath.row
//            }
//            if indexPath.row > maximumIndexPath {
//                maximumIndexPath = indexPath.row
//            }
//        }
//    }
//
//    
//    
//    func collectionView(_ collectionView: UICollectionView, priorIndexPathCount count: Int, from indexPath: IndexPath) -> [Any] {
//        var indexPaths = [Any]()
//        var row: Int = indexPath.row
//        var section: Int = indexPath.section
//        for _ in 0..<count {
//            if row == 0 {
//                if section == 0 {
//                    return indexPaths
//                }
//                else {
//                    section -= 1
//                    row = collectionView.numberOfItems(inSection: section) - 1
//                }
//            }
//            else {
//                row -= 1
//            }
//            indexPaths.append(IndexPath(row: row, section: section))
//        }
//        return indexPaths
//    }
//    
//    
//    
//    
//    
//    func collectionView(_ collectionView: UICollectionView, nextIndexPathCount count: Int, from indexPath: IndexPath) -> [Any] {
//        var indexPaths = [Any]()
//        var row: Int = indexPath.row
//        var section: Int = indexPath.section
//        var rowCountForSection: Int = collectionView.numberOfItems(inSection: section)
//        for _ in 0..<count {
//            row += 1
//            if row == rowCountForSection {
//                row = 0
//                section += 1
//                if section == collectionView.numberOfSections{
//                    return indexPaths
//                }
//                rowCountForSection = collectionView.numberOfItems(inSection: section)
//            }
//            indexPaths.append(IndexPath(row: row, section: section))
//        }
//        return indexPaths
//    }
//
//    
    
    
    func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
        let alert = Alerts()
        alert.changeProfilePicture(self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtRoomVC" {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == "WallviewVC" {
            let wallviewVC = segue.destination as! WallViewVC
            wallviewVC.hidesBottomBarWhenPushed = true
            if let artImage = sender as? UIImage {
                wallviewVC.artImage = artImage
            }
        }
        
        if segue.identifier == "SettingsVC" {
            let settingsVC = segue.destination as! SettingsVC
            settingsVC.hidesBottomBarWhenPushed = true
            if let user = sender as? Users {
                settingsVC.user = user
            }
        }
    }
    
    
    func loadUserInfo(){
        DataService.ds.REF_USERS.child("\(FIRAuth.auth()!.currentUser!.uid)").observe(.value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.user = Users(key: key, artistData: postDict)
                
                if let user = self.user {
                    self.titleLbl.text = user.name
                    //self.websiteTextView.text = user.website
                    //self.profileImageView.sd_setImage(with: URL(string: "\(self.user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground)
                }
            }
        })
    }


    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.url = URL
        present(vc, animated: true, completion: nil)
        return false
    }
    
        
    //MARK: DZNEmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no artwork yet. Click on the capture button to start sharing"
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}


 //MARK: Extension Edit Art

extension ProfileVC {
    
    func showAlert(sender : UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.collectionView)
        let indexPath : IndexPath = self.collectionView.indexPathForItem(at: tapLocation)!
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
        let art = self.arts[indexPath.row]
        let image = cell.artImageView.image
            
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let wallView = UIAlertAction(title: "Wallview", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "WallviewVC", sender: image)
        })
        
        let share = UIAlertAction(title: "Share", style: .default, handler: { (UIAlertAction) in
            self.share(image: image!, title: art.title)
        })
        
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in
            self.edit()
        })
        
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            self.remove(artID: art.artID, artTitle: art.title)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(wallView)
        alert.addAction(share)
        //alert.addAction(edit)
        alert.addAction(remove)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
       }
    }
    
    
    func share(image: UIImage, title: String) {
        let share = Share()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let facebook = UIAlertAction(title: "Facebook", style: .default, handler: { (UIAlertAction) in
            share.facebookShare(self, image: image, text: title)
        })
        
        let messenger = UIAlertAction(title: "Mesenger", style: .default, handler: { (UIAlertAction) in
            //share.messengerShare(self, image: self.artInfo[0] as! UIImage)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(facebook)
        //alert.addAction(messenger)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func remove(artID: String, artTitle: String) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove \(artTitle). After removing it you can't get it back.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Remove", style: .destructive) { (UIAlertAction) in
            DataService.ds.REF_USERS.child(self.user.userId).child("arts").child(artID).removeValue(completionBlock: { (error, ref) in
                DataService.ds.REF_ARTS.child(ref.key).removeValue()
                self.collectionView.reloadData()
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    func edit() {
        NotificationCenter.default.post(name: editNotif, object: self)
        collectionView.isScrollEnabled = false
        UIView.animate(withDuration: 0.3) {
        self.titleLbl.text = "Edit"
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ProfileVC.cancelBtnTapped))
            let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ProfileVC.doneBtnTapped))
        self.navigationItem.leftBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem = doneBtn
        }
        setTabBarVisible(visible: !tabBarIsVisible(), animated: true)
        view.gestureRecognizers = nil
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        
        let segItemsArray: [Any] = ["Size", "Type", "Modern"]
        self.segmentedCtrl = UISegmentedControl(items: segItemsArray)
        segmentedCtrl.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(250), height: CGFloat(30))
        //segmentedControl.segmentedControlStyle = .bar
        segmentedCtrl.selectedSegmentIndex = 0
        segmentedCtrl.addTarget(self, action: #selector(ProfileVC.segmentTapped(_:)), for: .valueChanged)
        let segmentedControlButtonItem = UIBarButtonItem(customView: (segmentedCtrl))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barArray: [UIBarButtonItem] = [flexibleSpace, segmentedControlButtonItem, flexibleSpace]
        self.toolbarItems = barArray
     }
    
    
    func updateLbl() {
        titleLbl.text = "Work"
    }
    
    
    func segmentTapped(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            swipeView.scrollToItem(at: 0, duration: 0.5)
        } else if  segmentedCtrl.selectedSegmentIndex == 1 {
            swipeView.scrollToItem(at: 1, duration: 0.5)
        } else if segmentedCtrl.selectedSegmentIndex == 2 {
            swipeView.scrollToItem(at: 2, duration: 0.5)
        }
    }
    
    
    func doneBtnTapped() {
        NotificationCenter.default.removeObserver(self, name: editNotif, object: self)
        NotificationCenter.default.post(name: cancelNotif, object: self)
        self.titleLbl.text = user.name
        let menuBtn = UIBarButtonItem(image: UIImage(named: "Menu-20"), style: .plain, target: self, action: #selector(ProfileVC.settingsBtnTapped(_:)))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = menuBtn
        setTabBarVisible(visible: !tabBarIsVisible(), animated: true)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.showAlert))
        self.navigationController?.setToolbarHidden(true, animated: true)
        view.addGestureRecognizer(tapGesture)

    }
    
    func cancelBtnTapped() {
        NotificationCenter.default.post(name: cancelNotif, object: self)
        collectionView.isScrollEnabled = true
        self.titleLbl.text = user.name
        let menuBtn = UIBarButtonItem(image: UIImage(named: "Menu-20"), style: .plain, target: self, action: #selector(ProfileVC.settingsBtnTapped(_:)))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = menuBtn
        setTabBarVisible(visible: !tabBarIsVisible(), animated: true)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.showAlert))
         self.navigationController?.setToolbarHidden(true, animated: true)
        view.addGestureRecognizer(tapGesture)
    }

    
  // SetTabBar Visible
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        
        if (tabBarIsVisible() == visible) { return }
        
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)

        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! < self.view.frame.maxY
    }
}


// MARK: EDIT SWIPEVIEW
//
//extension ProfileVC: SwipeViewDelegate, SwipeViewDataSource {
////    
////    func numberOfItems(in swipeView: SwipeView!) -> Int {
////        return 3
////    }
////    
////    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
////        if index == 0 {
////            UIView.animate(withDuration: 2, animations: {
////                self.sizeView = Bundle.main.loadNibNamed("Size", owner: self, options: nil)?[0] as! SizeView
////                self.sizeView.isUserInteractionEnabled = true
////                self.sizeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
////                self.sizeView.heightSlider.value = 40
////                self.sizeView.widthSlider.value = 40
////                self.sizeView.heightLbl.text = "Height: \(Int(self.sizeView.widthSlider.value)) cm"
////                //self.sizeView.heightSlider.addTarget(self, action: #selector(ProfileVC.SliderValueChanged(_:)), for: .valueChanged)
////                //self.sizeView.widthSlider.addTarget(self, action: #selector(ProfileVC.SliderValueChanged(_:)), for: .valueChanged)
////            })
////            return self.sizeView
////        }
//    
//        //        else if index == 1 {
//        //            UIView.animate(withDuration: 2, animations: {
//        //                self.typesView = Bundle.main.loadNibNamed("Types", owner: self, options: nil)?[0] as! UIView
//        //                self.segmentedCtrl.selectedSegmentIndex = 1
//        //                self.typesView.isUserInteractionEnabled = true
//        //                //self.typesView.frame = CGRect(x: 0, y: 0, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
//        ////                self.typePickerView.delegate = self
//        ////                self.typePickerView.dataSource = self
//        ////                let row = self.typePickerView.selectedRow(inComponent: 0)
//        ////                self.pickerView(self.typePickerView, didSelectRow: row, inComponent:0)
//        //            })
//        //            return typesView
//        //        } else if index == 2 {
//        //            UIView.animate(withDuration: 2, animations: {
//        //                self.DetailsView = Bundle.main.loadNibNamed("Details", owner: self, options: nil)?[0] as! UIView
//        //                self.segmentedCtrl.selectedSegmentIndex = 2
//        //                self.DetailsView.isUserInteractionEnabled = true
//        //                //self.DetailsView.frame = CGRect(x: 0, y: 0, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
//        ////                self.priceTextField.delegate = self
//        ////                self.titleTextField.delegate = self
//        ////                self.descTextView.delegate = self
//        ////                self.descTextView.text = "Description..."
//        ////                self.descTextView.textColor = UIColor.lightGray
//        //            })
//        //            return DetailsView
//        //        }
//        return UIView()
//    }
//    
//    
//    func SliderValueChanged(_ sender: UISlider) {
//        if sender.tag == 1 {
//           self.sizeView.heightLbl.text = "Height: \(Int(sender.value)) cm"
//            
//        } else if sender.tag == 2 {
//            UIView.animate(withDuration: 0.5) {
//               self.sizeView.widthLbl.isHidden = false
//            }
//            if sender.value == 0 {
//                
//            }
//            self.sizeView.widthLbl.text = "Width: \(Int(sender.value)) cm"
//        }
//    }
//
//
//
//}












