//
//  SettingsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import SwiftyUserDefaults

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var options: [String] = []
    var userInfo : [AnyObject] = []
    var user: Users!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        options = ["Edit Account", "Privacy Policy", "Log Out"]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userInfo.removeAll()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 55
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
            DispatchQueue.main.async {
                if let url = self.user.profilePicUrl {
                    cell.profileImgView.sd_setImage(with: URL(string: "\(url)") , placeholderImage: UIImage(named: "Placeholder") , options: .continueInBackground)
                }
                cell.nameLbl.text = self.user.name
            }
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
        
        if indexPath.row == 2 {
            logoutAlert()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func reportProblemAlert(){
        let problem = UIAlertController(title: "Report a Problem", message: "", preferredStyle: .alert)
        let SomethingNotWorking = UIAlertAction(title: "Something Is Not Working", style: .default) { (UIAlertAction) in
            let reportTitleSomething = ["Something Is Not Working", "Brieftly explain what happended."]
            self.performSegue(withIdentifier: "FeedbackVC", sender: reportTitleSomething)
        }
        let generalFeedback = UIAlertAction(title: "General Feedback", style: .default) { (UIAlertAction) in
            let reportTitleGeneral = ["General Feedback", "Brieftly explain what you love, or what could improve."]
            self.performSegue(withIdentifier: "FeedbackVC", sender: reportTitleGeneral)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            return
        }
        problem.addAction(SomethingNotWorking)
        problem.addAction(generalFeedback)
        problem.addAction(cancel)
        present(problem, animated: true, completion: nil)
    }
    
    
    func logoutAlert() {
        let vc = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            
                Defaults.remove(.key_uid)
                Defaults.remove(.accountType)
            
            
                let firebaseAuth = FIRAuth.auth()
            do {
                
                try firebaseAuth!.signOut()
                DispatchQueue.main.async {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LogInNav")
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
            editAccountVC.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "FeedbackVC" {
            let feedbackVC = segue.destination as! FeedbackVC
            let report = sender as! [String]
            feedbackVC.report = report
        } else if segue.identifier == "PrivacyVC" {
            let feedbackVC = segue.destination as! PrivacyVC
            feedbackVC.hidesBottomBarWhenPushed = true
        }
    }
}
