////
////  UserProfileCell.swift
////  Flaintartist
////
////  Created by Kerby Jean on 1/9/17.
////  Copyright © 2017 Kerby Jean. All rights reserved.
////
//
//import UIKit
//import SDWebImage
//import FirebaseStorage
//
//class UserProfileCell: UITableViewCell {
//    
//    @IBOutlet weak var profileImage: UIImageView!
//    @IBOutlet weak var nameLbl: UILabel!
//    @IBOutlet weak var websiteTextView: UITextView!
//
//    var user: Users!
//    
//    func configureView(_ user: Users, img: UIImage? = nil) {
//        
//        self.user = user
//        self.nameLbl.text = user.name
//        print("USERNAME: \(user.name)")
//        self.websiteTextView.text = user.website
//        if img != nil {
//            self.profileImage.image = img
//        } else {
//            let ref = FIRStorage.storage().reference(forURL: user.profilePicUrl)
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                if error != nil {
//                    print("KURBS: Unable to download image from Firebase storage")
//                } else {
//                    print("KURBS: Image downloaded from Firebase storage")
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData) {
//                            print("CELL 4")
//                            self.profileImage.image = img
//                            self.profileImage.sd_setImage(with: URL(string: "\(user.profilePicUrl)"), placeholderImage:UIImage(named:"placeholder.png"))
//                        }
//                    }
//                }
//            })
//       }
//   }
//}
