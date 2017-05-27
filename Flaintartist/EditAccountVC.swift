//
//  EditAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import Firebase

class EditAccountVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let gender = ["Not Specified", "Female", "Male"]
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.endEditing(true)
    }

    @IBOutlet weak var profileImage: RoundImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    
    var user: Users?
    var imageChanged: Bool = false
    var imagePicker = UIImagePickerController()
    var pickerView: UIPickerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.instance.currentUserInfo { (user) in
            self.nameField.text = user?.name
            self.websiteField.text = user?.website
            self.emailField.text = Auth.auth().currentUser?.email
            self.phoneNumTextField.text = user?.phoneNumber
            if user?.gender == "" {
                 self.genderLabel.text = "Not Specified"
            }
            self.genderLabel.text = user?.gender
            self.profileImage.sd_setImage(with: URL(string: (user?.profilePicUrl!)!), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
        }
        imagePicker.delegate = self
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        pickerView.backgroundColor = UIColor.flatWhite()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.center = CGPoint(x: self.view.layer.position.x, y: 640)
        pickerView.isHidden = true
        self.view.addSubview(self.pickerView)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.instance.REF_USER_CURRENT.removeAllObservers()
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderLabel.text = self.gender[row]
        hidePickerView()
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
        let phoneNumber = self.phoneNumTextField.text!
        let gender = self.genderLabel.text!
        let data = UIImageJPEGRepresentation(profileImage.image!, 0.1)
        
        DataService.instance.saveCurrentUserInfo(name: name, website: website, email: email, phoneNumber: phoneNumber, gender: gender, data: data!)
        _ = navigationController?.popViewController(animated: true)
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
    
    //override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return 1.0
    //}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 2 {
            bringUpPickerView(withRow: indexPath)
        }
    }
    
  
    
    func bringUpPickerView(withRow indexPath: IndexPath) {
        let currentCellSelected: UITableViewCell? = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {() -> Void in
            self.pickerView.isHidden = false
            self.pickerView.center = CGPoint(x: (currentCellSelected?.frame.size.width)! / 2, y: 500)
        })
    }
    
    func hidePickerView() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.pickerView.center = CGPoint(x: self.view.layer.position.x, y: 800)
        }, completion: {(_ finished: Bool) -> Void in
            self.pickerView.isHidden = true
        })
    }

}
