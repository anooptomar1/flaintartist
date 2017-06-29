//
//  CreateAccountVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 3/30/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class CreateAccountVC: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: TextFieldRect!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        doneBtn.isEnabled = false
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        sender.setTitle("", for: .normal)
        let email = emailTextField.text!
        let pwd = passwordTextField.text!
        let name = nameTextField.text!
        self.view.endEditing(true)
        AuthService.instance.signUp(name: name, email: email, password: pwd, userType: "artist") { (errMsg, data) in
            self.doneBtn.setTitle("Done", for: .normal)
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            sender.setTitle("Done", for: .normal)
            guard errMsg == nil else {
                self.alert.showAlert("Error", message: errMsg!, target: self)
                return
            }
        }
    }
    
    
    @IBAction func goToLogInBtnTapped(_ sender: AnyObject) {
        let logInVC = storyboard?.instantiateViewController(withIdentifier: "LogInNav")
        present(logInVC!, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            nameTextField.becomeFirstResponder()
        } else  {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textChanged(sender: NSNotification) {
        if emailTextField.hasText && passwordTextField.hasText {
            doneBtn.isEnabled = true
            doneBtn.alpha = 1
        } else {
            doneBtn.isEnabled = false
            doneBtn.alpha = 0.7
        }
    }
}
