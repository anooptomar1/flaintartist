//
//  EditAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Firebase

final class EditAccountVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.endEditing(true)
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    var user: User?
    private var imageChanged: Bool = false
    lazy var imagePicker = UIImagePickerController()
    lazy var alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupInfo()
    }
    
    func setupInfo() {
        profileImage.sd_setImage(with: URL(string: user?.profilePicUrl ?? "" ))
        nameField.text = user?.name ?? ""
        websiteField.text = user?.website ?? ""
        emailField.text = user?.email ?? ""
        phoneField.text = user?.phoneNumber ?? ""
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
        let phoneNumber = self.phoneField.text!
        let data = UIImageJPEGRepresentation(profileImage.image!, 0.1)
        
        DataService.instance.saveCurrentUserInfo(name: name, website: website, email: email, phoneNumber: phoneNumber, data: data!)
        activityIndicator.stopAnimating()
        
        _ = navigationController?.popToRootViewController(animated: true)
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
    

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.5
        } else {
            return 40.0
        }
    }
}

