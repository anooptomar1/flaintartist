//
//  EditAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditAccountVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var websiteField: UITextField!
    
    var user: Users!
    var imageChanged: Bool = false
    
    
        override func viewDidLoad() {
           super.viewDidLoad()
        
            DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value) { (snapshot: FIRDataSnapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
            let key = snapshot.key
            self.user = Users(key: key, artistData: postDict)
            }
            if let user = self.user {
                self.nameField.text = user.name
                self.emailField.text = FIRAuth.auth()?.currentUser?.email
                self.websiteField.text = user.website
                self.profileImage.sd_setImage(with: URL(string: "\(self.user.profilePicUrl)") , placeholderImage: UIImage(named:"User-70") , options: .continueInBackground)
            }
        }
        //profileImage.addObserver(self, forKeyPath: "image", options: .new, context: nil)
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print("IMAGE CHANGES")
//    }

    @IBAction func doneBtnTapped(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = spinner
        activityIndicator.startAnimating()

        let name = self.nameField.text!
        let email = self.emailField.text!
        let website = self.websiteField.text!
    
        
           FIRAuth.auth()?.currentUser?.updateEmail(email, completion: { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
           })
                
        let imageData = UIImageJPEGRepresentation(profileImage.image!, 1)
        let imagePath = "profileImage\(user.userId)userPic.jpeg"
        let imageRef = STORAGE.child(imagePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(imageData!, metadata: metaData) { (metaData, error) in
            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
            changeRequest?.displayName = name
            
            if let photoUrl = metaData!.downloadURL() {
                changeRequest?.photoURL = photoUrl
            }
            
            changeRequest?.commitChanges(completion: { (error) in
                if error == nil {
                    let user = FIRAuth.auth()!.currentUser!
                    let userInfo = ["email": email, "name": name, "website": website, "uid": user.uid, "profileImg": String(describing: user.photoURL!)] as [String : Any]
                    let userRef = DataService.ds.REF_USERS.child(user.uid)
                    userRef.updateChildValues(userInfo, withCompletionBlock: { (error, reference) in
                        
                    })
                }
            })
        }
    }
    

    @IBAction func editImageBtnTapped(_ sender: Any) {
        let alert = Alerts()
        alert.changeProfilePicture(self)
        
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImage.image = image
        self.imageChanged = true
        picker.dismiss(animated: true, completion: nil)
        
    }
}
