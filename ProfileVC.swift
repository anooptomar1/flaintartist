//
//  ProfileVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ChameleonFramework
import SwiftyUserDefaults


class ProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var websiteTextView: UITextView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var tapOnCameraStackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!

    
    var user: Users!
    var arts = [Art]()
    var art: Art!
    var artImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadUserInfo()
        websiteTextView.delegate = self
  
        

        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
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
    
        self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 172) , andColors: [UIColor.white, UIColor.white])
        collectionView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height:  437) , andColors: [  UIColor.white, UIColor.flatWhite()])
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tapProfilePicture))
        profileImageView.addGestureRecognizer(tapProfileGesture)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.flatBlack()
        refreshControl.addTarget(self, action: #selector(ProfileVC.refresh), for: UIControlEvents.valueChanged)

        tableView.refreshControl = refreshControl
    }

    
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "SettingsVC", sender: nil)
    }
    
    
    func refresh() {
        loadUserInfo()
        collectionView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arts.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let art = arts[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileArtCell", for: indexPath) as? ProfileArtCell {
        
        let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
        }
        
        cell.artImageView.sd_setImage(with: URL(string: "\(art.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)

        return cell
            
        } else {
            return ProfileArtCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileArtCell {
            
            if let artImage = cell.artImageView.image {
                let art = arts[indexPath.row]
                let artInfo = [artImage, art] as [Any]
                performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
            }
        }
    }
    
    
       func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
        let alert = Alerts()
        alert.changeProfilePicture(self)
    }
 

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtRoomVC" {
            let artRoomVC = segue.destination as! ArtRoomVC
            artRoomVC.hidesBottomBarWhenPushed = true
            if let artInfo = sender as? [Any] {
                artRoomVC.artInfo = artInfo
            }
        }
    }
    
    
    func loadUserInfo(){
        
        DataService.ds.REF_USERS.child("\(FIRAuth.auth()!.currentUser!.uid)").observe(.value, with: { (snapshot) in
            
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.user = Users(key: key, artistData: postDict)
                
                if let user = self.user {
                    self.nameLbl.text = user.name
                    self.websiteTextView.text = user.website
                    
                    DataService.ds.REF_STORAGE.reference(forURL: user.profilePicUrl).data(withMaxSize: 15 * 1024 * 1024, completion: { (data, error) in
                        if let error = error {
                            print(error)
                        } else {
                            self.profileImageView.sd_setImage(with: URL(string: "\(self.user.profilePicUrl)") , placeholderImage: nil , options: .continueInBackground)
                        }
                    })
                }
            }
        })
    }


    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.url = URL
        present(vc, animated: true, completion: nil)
        return false
    }
 
}





















