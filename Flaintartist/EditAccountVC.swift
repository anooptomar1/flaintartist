//
//  EditAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import Firebase

class EditAccountVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImage: RoundImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    
    var user: Users?
    var imageChanged: Bool = false
    var imagePicker = UIImagePickerController()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.instance.currentUserInfo { (user) in
            self.nameField.text = user?.name
            self.emailField.text = Auth.auth().currentUser?.email
            self.websiteField.text = user?.website
            self.profileImage.setImageWith(URL(string: (user?.profilePicUrl!)!), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
        }
        imagePicker.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.instance.REF_USER_CURRENT.removeAllObservers()
    }
    
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView()
        DispatchQueue.main.async {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.rightBarButtonItem = spinner
            activityIndicator.startAnimating()
        }
        let name = self.nameField.text!
        let email = self.emailField.text!
        let website = self.websiteField.text!
        let data = UIImageJPEGRepresentation(profileImage.image!, 0.1)
        DataService.instance.saveCurrentUserInfo(name: name, email: email, data: data!)
        activityIndicator.stopAnimating()
    }
    
    
    
    func editPhotoAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Take a Picture", style: .default) { (action) in
            self.openCamera()
        }
        
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.openLibrary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(takePhoto)
        alert.addAction(library)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openLibrary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    


    
    @IBAction func editImageBtnTapped(_ sender: Any) {
         editPhotoAlert()
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

}
