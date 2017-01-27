//
//  GalleryVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage
import DZNEmptyDataSet
import ChameleonFramework

  class GalleryVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
            
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet var artworkCountLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
            
            
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
    
    var tapGesture = UITapGestureRecognizer()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
                
        loadUserInfo()
                
        DataService.instance.REF_USERS.child((user.userId)).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
           self.arts = []
             if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
               for snap in snapshot {
                  if let postDict = snap.value as? Dictionary<String, AnyObject> {
                  let key = snap.key
                  let post = Art(key: key, artData: postDict)
                  self.arts.insert(post, at: 0)
                }
             }
          }
           self.collectionView.reloadData()
       }

                

        let backBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(GalleryVC.backBtnTapped))
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.title = "\(user.name)'s gallery"
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.flatBlack()
        refreshControl.addTarget(self, action: #selector(GalleryVC.refresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
        
        let moreBtn = UIBarButtonItem(image: UIImage(named:"More Filled-25"), style: .plain, target: self, action: #selector(GalleryVC.moreBtnTapped(_:)))
        navigationItem.rightBarButtonItem = moreBtn
    }
    
            
    func moreBtnTapped(_ sender: Any) {
        self.showAlert()
    }
    
    func backBtnTapped() {
        _ = navigationController?.popViewController(animated: true)
    }

            
    func refresh() {
        tableView.reloadData()
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            // Fallback on earlier versions
        }
    }
            
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.artworkCountLbl.text = "\(arts.count)"
         return arts.count
    }
            
            
            
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let art = arts[indexPath.row]
                
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
                DispatchQueue.main.async {
                cell.artRoomScene.boxnode.removeFromParentNode()
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                    cell.artRoomScene.setup(artInfo: image, height: image!.size.height / 700, width: image!.size.width / 700)
                }
                cell.artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
                
                cell.titleLbl.text = art.title
                cell.typeLbl.text = art.type
                cell.sizeLbl.text = "\(art.artHeight)'H x \(art.artWidth)'W - \(art.price)$ / month"
                cell.descLbl.text = art.description
               }
                self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(GalleryVC.artAlert(sender:)))
                cell.addGestureRecognizer(self.tapGesture)
                 return cell
            } else {
            return ProfileArtCell()
        }
    }
            
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
            
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
            
            
    func loadUserInfo(){
        DataService.instance.REF_USERS.child("\(user.userId)").observe(.value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.user = Users(key: key, artistData: postDict)
                        
                if let user = self.user {
                    self.titleLbl.text = "\( user.name)'s gallery"
                    self.nameLbl.text = user.name
                    //self.websiteTextView.text = user.website
                    self.profileImageView.sd_setImage(with: URL(string: "\(self.user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground)
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
    
    func artAlert(sender : UITapGestureRecognizer) {
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
            
            _ = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in
                //self.edit()
            })
            
            _ = UIAlertAction(title: "Report", style: .destructive, handler: { (UIAlertAction) in
                let navVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportNav") as! UINavigationController
                let reportVC = navVC.topViewController as! ReportVC
                reportVC.headerTitle = "Please choose the reason for reporting the piece."
                let artInfo = [art]
                reportVC.artInfo = artInfo
                self.present(navVC, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(wallView)
            alert.addAction(share)
            //alert.addAction(report)
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
        
        _ = UIAlertAction(title: "Mesenger", style: .default, handler: { (UIAlertAction) in
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
            DataService.instance.REF_USERS.child(self.user.userId).child("arts").child(artID).removeValue(completionBlock: { (error, ref) in
                DataService.instance.REF_ARTS.child(ref.key).removeValue()
                self.collectionView.reloadData()
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let website = UIAlertAction(title: "Visit website", style: .default) { (UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
          let url = URL(string: "\(self.user.website)")
                print("FIRSTURL: \(url)")
                vc.url = url
                self.present(vc, animated: true, completion: nil)
        }
        
        
        let report = UIAlertAction(title: "Report \(user.name)", style: .destructive) { (UIAlertAction) in
            
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportNav") as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose a reason for reporting \(self.user.name)"
            reportVC.reportsTitle =  ["I believe this account violate Flaint's community guideline.", "Inapropriate language.", "Others."]
            reportVC.user = self.user
            self.present(navVC, animated: true, completion: nil)
        }
    
    
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if user.website != nil {
        alert.addAction(website)
        }
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Seg_ArtroomVC {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == Seg_ReportVC {
            let navVC = segue.destination as! UINavigationController
            let reportVC = navVC.topViewController as! ReportVC
            reportVC.headerTitle = "Please choose a reason for reporting \(user.name)."
            reportVC.user = user
            reportVC.reportsTitle = sender as! [String]
        }
    }
    
    //MARK: EmptyDataSet
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "\(user.name) haven't share any artwork yet."
        let attrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
}
