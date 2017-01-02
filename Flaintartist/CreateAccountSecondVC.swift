//
//  CreateAccountSecondVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftyUserDefaults



class CreateArtistSecondVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var profileImg: BorderImg!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var addProfilePicLbl: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var nameStackView: UIStackView!
    
    
    var profilePicColor: String!
    var userUID = ""
    
    let storage = FIRStorage.storage()
    
    var info: [String] = []
    
    var stackViewConstant: CGFloat!
    var countLblConstant: CGFloat!
    
    var profileUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImg.layer.borderColor = UIColor.flatSkyBlue().cgColor
        profileImg.layer.borderWidth = 3.0
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(CreateArtistSecondVC.tapProfilePicture))
        profileImg.addGestureRecognizer(tapProfileGesture)
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        doneBtn.isEnabled = false
    }
    
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        done()
    }
    
    
    
    @IBAction func GoToLoginBtnTapped(_ sender: AnyObject) {
        let logInVC = storyboard?.instantiateViewController(withIdentifier: "LogInNav")
        present(logInVC!, animated: true, completion: nil)
    }
    
    
    func postToFirebase() {
        let name = nameTextField.text!
        let color = profilePicColor!
        let userData = [
            "name": name,
            "profileImg": profileUrl,
            "color": color,
            "userType": "artist"
        ]
        self.completeSignIn(id: userUID, userData: userData)
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(id, userData: userData)
        Defaults[.key_uid] = id
        if let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
            self.present(tabBarVC, animated: true, completion: nil)
        }
    }
    
    // MARK: Change photos gesture recognizer
    func tapProfilePicture() {
        let alert = Alerts()
        alert.changeProfilePicture(self)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImg.image = image
        profileImg.configure(UIColor.flatWhite(), width: 1)
        self.addImgLbl()
        let backgroundPicColor: UIColor = UIColor(averageColorFrom: image, withAlpha: 0.8)
        let color = backgroundPicColor.hexValue()
        self.profilePicColor = color
        
        picker.dismiss(animated: true, completion: nil)
        
        if  let uicolor = UIColor(averageColorFrom: profileImg.image, withAlpha: 0.8) {
            let hexColor = uicolor.hexValue()
            self.profilePicColor = hexColor
            self.gradientView.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(x:0 , y: 0, width: 375, height: 242) , andColors: [ uicolor, UIColor.white ])
        }
    }
    
    //MARK: TextField
    func editingChanged(_ sender: Any) {
        if nameTextField.text != "" {
            nameLbl.isHidden = false
            nameLbl.text = nameTextField.text!
        } else {
            nameLbl.isHidden = true
        }
    }
    
    func addImgLbl() {
        if profileImg.image != nil {
            UIView.animate(withDuration: 3.0, animations: {
                self.profileImg.layer.borderWidth = 0.0
                self.addProfilePicLbl.alpha = 0.0
                self.nameStackView.alpha = 1.0
                self.doneBtn.isHidden = false
                
            })
        }
    }

    
    func alert(title: String, message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func credentialAlert(title: String, message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            self.navigationController!.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    func done() {
        doneBtn.BtnTapped()
        let alert = Alerts()
        let email = info[0]
        let pwd = info[1]
        let name = nameTextField.text!
        
        if name.isEmpty {
            alert.showAlert("Empty fields", message: "All fields must be filled. Try again", target: self)
            return
        }
        
        if profileImg.image == nil{
            alert.showAlert("Image", message: "An profile image is required to create an account", target: self)
            return
        }
        
        doneBtn.setTitle("", for: .normal)
        indicatorView.hidesWhenStopped = true
        indicatorView.alpha = 1
        indicatorView.startAnimating()
        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
            
            if let error = error as? NSError {
                print(" ERROR CODE: \(error.code)")
                if error.code == 17799 {
                    self.dismiss(animated: true, completion: nil)
                } else if error.code == 17007 {
                    self.credentialAlert(title: "Email", message: "\(error.localizedDescription) Please choose another one.")
                    return
                }
            }
            if error != nil {
                self.indicatorView.stopAnimating()
                self.indicatorView.alpha = 1
                self.doneBtn.setTitle("Done", for: .normal)
                self.alert(title: "Error", message: "\(error!.localizedDescription)")
                return
            } else {
                Defaults[.email] = email
                self.userUID = (user?.uid)!
                DataService.ds.storeProfileImg((user?.uid)!, img: self.profileImg.image!, vc: self)
                self.postToFirebase()
            }
        })
    }
    
    func textChanged(sender: NSNotification) {
        if nameTextField.hasText {
            doneBtn.isEnabled = true
            doneBtn.alpha = 1
        } else {
            doneBtn.alpha = 0.7
        }
    }
}
