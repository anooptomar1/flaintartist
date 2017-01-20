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
            
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet var artworkCountLbl: UILabel!
    @IBOutlet var collectionView: UICollectionView!
            
            
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
                
        loadUserInfo()
        //websiteTextView.delegate = self
                
        DataService.ds.REF_USERS.child((user.userId)).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
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
                    
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                    cell.artRoomScene.setup(artInfo: image, height: image!.size.height / 700, width: image!.size.width / 700)
                }
                cell.artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
                
                cell.titleLbl.text = art.title
                cell.typeLbl.text = art.type
                cell.sizeLbl.text = "\(art.artHeight)'H x \(art.artWidth)'W - \(art.price)$ / month"
                cell.descLbl.text = art.description
                
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
        DataService.ds.REF_USERS.child("\(user.userId)").observe(.value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.user = Users(key: key, artistData: postDict)
                        
                if let user = self.user {
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
    
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let website = UIAlertAction(title: "Visit website", style: .default) { (UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
          let url = URL(string: "\(self.user.website)")
                print("FIRSTURL: \(url)")
                vc.url = url
                self.present(vc, animated: true, completion: nil)
        }
        
        
        let report = UIAlertAction(title: "Report", style: .destructive) { (UIAlertAction) in
            
            let reportsTitle = ["I believe this account violate Flaint's community guideline.", "Inapropriate language.", "Others."]
            self.performSegue(withIdentifier: "ReportVC", sender: reportsTitle)
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
        if segue.identifier == "ArtRoomVC" {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
        
        if segue.identifier == "SettingsVC" {
            let settingsVC = segue.destination as! SettingsVC
            let userInfo = sender as! [AnyObject]
            settingsVC.userInfo = userInfo
        }
        
        if segue.identifier == "ReportVC" {
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
