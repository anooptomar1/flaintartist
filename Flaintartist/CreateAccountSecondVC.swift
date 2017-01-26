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



class CreateArtistSecondVC: UIViewController , UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var profileImg: BorderImg!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var addProfilePicLbl: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var nameStackView: UIStackView!
    
    
    
    let storage = FIRStorage.storage()
    
    var info: [String] = []

    
    var profileUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImg.layer.borderColor = UIColor.white.cgColor
        profileImg.layer.borderWidth = 3.0
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(CreateArtistSecondVC.choosePictureAction(sender:)))
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
                self.addProfilePicLbl.alpha = 0.0
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
        let pictureData = UIImageJPEGRepresentation(self.profileImg.image!, 0.70)
        
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
        
        nameTextField.resignFirstResponder()
        DataService.ds.signUp(name: name, email: email, password: pwd, pictureData: pictureData as NSData!, userType: "artist")
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

extension CreateArtistSecondVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func choosePictureAction(sender: AnyObject) {
        
        let alert = Alerts()
        alert.changeProfilePicture(self)
        
//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self
//        pickerController.allowsEditing = true
//        
//        let alertController = UIAlertController(title: "Add a Profile Picture", message: "Choose From", preferredStyle: .actionSheet)
//        
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
//            pickerController.sourceType = .camera
//            self.present(pickerController, animated: true, completion: nil)
//            
//        }
//        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
//            pickerController.sourceType = .photoLibrary
//            self.present(pickerController, animated: true, completion: nil)
//            
//        }
//        
//        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
//            pickerController.sourceType = .savedPhotosAlbum
//            self.present(pickerController, animated: true, completion: nil)
//            
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
//        
//        alertController.addAction(cameraAction)
//        alertController.addAction(photosLibraryAction)
//        alertController.addAction(savedPhotosAction)
//        alertController.addAction(cancelAction)
//        
//        
//        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            self.profileImg.image = image
        }else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImg.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
