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


class ProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, iCarouselDelegate, iCarouselDataSource {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var websiteTextView: UITextView!
    @IBOutlet weak var carouselView: iCarousel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var tapOnCameraStackView: UIStackView!

    
    var user: Users!
    var posts = [Art]()
    var post: Art!
    var artView = UIView()
    var artImgView = FXImageView()
    var artImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
        
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.type = .linear
        carouselView.clipsToBounds = true
        websiteTextView.delegate = self

        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("arts").observe(.value) { (snapshot: FIRDataSnapshot) in
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
            self.carouselView.reloadData()
        }
        
        self.gradientView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(x:0 , y: 100, width: self.view.frame.width, height: 172) , andColors: [UIColor.white, UIColor.white])
        carouselView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.carouselView.frame.width, height:  437) , andColors: [  UIColor.white, UIColor.flatWhite()])
        
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
        carouselView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        self.navigationController?.navigationBar.isTranslucent = false
    }

    
    func numberOfItems(in carousel: iCarousel) -> Int {
        if posts.count == 0 {
            tapOnCameraStackView.isHidden = false
        } else {
            tapOnCameraStackView.isHidden = true
        }
        return posts.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        if (view == nil) {
            let post = posts[index]
            artView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            artImgView = FXImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            artImgView.image = UIImage(named:"White")
            artImgView.contentMode = .scaleAspectFit
            artImgView.isAsynchronous = true
            artImgView.reflectionScale = 0.5
            artImgView.reflectionAlpha = 0.15
            artImgView.reflectionGap = 10.0
            artImgView.shadowOffset = CGSize(width: 0.0, height: 2.0)
            artImgView.shadowBlur = 1.0
            
            let myBlock: SDWebImageCompletionBlock! = {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageUrl: URL?) -> Void in
                
            }
            artImgView.sd_setImage(with: URL(string: "\(post.imgUrl)") , placeholderImage: nil , options: .continueInBackground, completed: myBlock)
            
            artView.addSubview(artImgView)
        }
        return artView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.spacing {
            return 1.1
        }
        return value
    }
    
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let index = carouselView.currentItemIndex
        let post = posts[index]
        
       let artImage = profileImageView.sd_setImage(with: URL(string: "\(post.imgUrl)"))
        
        let artInfo = [artImage, post] as [Any]
        performSegue(withIdentifier: "ArtRoomVC", sender: artInfo)
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
