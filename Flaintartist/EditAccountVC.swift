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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value) { (snapshot: FIRDataSnapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
            let key = snapshot.key
            self.user = Users(key: key, artistData: postDict)
                print("NAME: \(self.user.name)")
            }
            if let user = self.user {
                self.nameField.text = user.name
                self.emailField.text = FIRAuth.auth()?.currentUser?.email
                self.websiteField.text = user.website
                
            }
        }
    }


    @IBAction func doneBtnTapped(_ sender: Any) {
        DispatchQueue.main.async {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = spinner
        activityIndicator.startAnimating()

        let name = self.nameField.text!
        let email = self.emailField.text!
        let website = self.websiteField.text!
        
        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["name": name, "website": website]) { (error,reference) in
            if error == nil {
                activityIndicator.stopAnimating()
                _ = self.navigationController?.popViewController(animated: true)
                print("No Error")
                FIRAuth.auth()?.currentUser?.updateEmail(email, completion: { (error) in
                    if error != nil {
                        print("ERROR:\(error?.localizedDescription)")
                    }
                })
            } else {
                activityIndicator.stopAnimating()
                print("ERROR UPDATING DETAILS: \(error?.localizedDescription)")
           }
        }
      }
    }
    
    
    

    @IBAction func editImageBtnTapped(_ sender: Any) {
        
        
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let image = info[UIImagePickerControllerEditedImage] as! UIImage
//        profileImg.image = image
//        let profilePicColor: UIColor = UIColor(averageColorFrom: image, withAlpha: 0.8)
//        let color = profilePicColor.hexValue()
//        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("color").setValue(color)
//        self.profilePicColor = color
//        if  let uicolor = UIColor(averageColorFrom: profileImg.image, withAlpha: 0.8) {
//            let hexColor = uicolor.hexValue()
//            self.profilePicColor = hexColor
//            self.gradientView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: self.gradientView.frame, andColors: [uicolor, UIColor.white])
//            //picker.dismiss(animated: true, completion: nil)
//        }
//    }
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
