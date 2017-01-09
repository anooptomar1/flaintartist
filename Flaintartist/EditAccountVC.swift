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
                
                DataService.ds.REF_STORAGE.reference(forURL: user.profilePicUrl).data(withMaxSize: 15 * 1024 * 1024, completion: { (data, error) in
                    if let error = error {
                        print(error)
                    } else {
                        DispatchQueue.main.async {
                            if let data = data {
                            self.profileImage.image = UIImage(data: data)
                            }
                        }
                    }
                })
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
                print(error?.localizedDescription)
            }
           })
        
        let imageData = UIImageJPEGRepresentation(profileImage.image!, 1)
        let imagePath = "profileImage\(user.userId) userPic.jpeg"
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
                    userRef.setValue(userInfo)
                }
                _ = self.navigationController?.popViewController(animated: true)
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
    
    
    
    
//    
//    @IBOutlet weak var gradientView: UIView!
//    @IBOutlet weak var profileImg: BorderImg!
//    @IBOutlet weak var nameLbl: UILabel!
//    @IBOutlet weak var nameTextField: UITextField!
//    
//    
//    var profilePicColor: String!
//    var userUID = ""
//    
//    let storage = FIRStorage.storage()
//    
//    var info: [String] = []
//    var userInfo: [AnyObject] = []
//    var constant: CGFloat!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        if let profileImage = userInfo[0] as? UIImage, let name = userInfo[1] as? String, let color = userInfo[2] as? UIColor{
//            profileImg.image = profileImage
//            nameLbl.text = name
//            gradientView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: self.gradientView.frame, andColors: [color, UIColor.flatWhite()])
//            
//        }
//        
//        profileImg.configure(UIColor.flatWhite(), width: 0.5)
//        
//        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(EditAccountVC.tapProfilePicture))
//        profileImg.addGestureRecognizer(tapProfileGesture)
//        
//        nameTextField.delegate = self
//        nameTextField.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(EditAccountVC.saveBtnTapped))
//        self.navigationItem.rightBarButtonItem = saveBtn
//        self.navigationItem.title = "Edit Account"
//    }
//    
//    
//    func saveBtnTapped(_ sender: UIBarButtonItem) {
//        save()
//    }
//    
//    
//    // MARK: Change photos gesture recognizer
//    func tapProfilePicture(_ gesture: UITapGestureRecognizer) {
//        let alert = Alerts()
//        alert.changeProfilePicture(self)
//    }
//    
//    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImage.image = image
        self.imageChanged = true
        picker.dismiss(animated: true, completion: nil)
        
    }
//
//    //MARK: TextField
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == nameTextField {
//            textField.resignFirstResponder()
//            save()
//        }
//        return true
//    }
//    
//    func editingChanged(_ sender: Any) {
//        if nameTextField.text != "" {
//            nameLbl.isHidden = false
//            nameLbl.text = nameTextField.text!
//        } else {
//            nameLbl.isHidden = true
//        }
//    }
//    
//    func save() {
//        let ref = DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!)
//        let name = nameLbl.text!
//        ref.child("name").setValue(name)
//        DataService.ds.storeProfileImg((FIRAuth.auth()!.currentUser!.uid), img: profileImg.image!, vc: self)
//        
//        //let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//        //navigationController?.show(profileVC, sender: nil)
//        
//    }
}
