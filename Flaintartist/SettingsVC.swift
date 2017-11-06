//
//  SettingsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FBSDKLoginKit
import SwiftyUserDefaults

final class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var options: [String] = []
    var user: User!
    lazy var loginVC = LoginViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        options = ["Edit account details", "Gallery code and link", "Privacy Policy", "Sign Out"]
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 96
        }
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
            cell.configureCell(user: user)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.optionLbl.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "EditAccountVC", sender: nil)
        }
        
        if indexPath.row == 1 {
            performSegue(withIdentifier: "PrivacyVC", sender: nil)
        }
        
        if indexPath.row == 3 {
            logoutAlert()
        }
    }
    
    func logoutAlert() {
        let vc = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .actionSheet)
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Sign Out", style: .destructive) { (UIAlertAction) in
            
            Defaults.remove(.key_uid)
            let firebaseAuth = Auth.auth()
            let loginManager = FBSDKLoginManager()
            do {
                loginManager.logOut()
                try firebaseAuth.signOut()
                DispatchQueue.main.async {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "SignInNav") as! UINavigationController
                    self.present(controller, animated: true, completion: nil)
                }
            } catch let signOutError as NSError {
                print("SIGNOUT ERROR:\(signOutError)")
            }
        }
        vc.addAction(yes)
        vc.addAction(no)
        present(vc, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditAccountVC" {
            let editAccountVC = segue.destination as! EditAccountVC
            editAccountVC.user = self.user
            editAccountVC.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "PrivacyVC" {
            let feedbackVC = segue.destination as! PrivacyVC
            feedbackVC.hidesBottomBarWhenPushed = true
        }
    }
}

