//
//  ReportVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/5/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ReportVC: UITableViewController {

    
    var artInfo: [Any] = []
    var art: Art!
    var headerTitle = ""
    var user: Users!
    var reportsTitle = ["Off Topic Content.", "Sexual Content or Nudity.", "Poor quality artwork."]
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!

    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let title = reportsTitle[indexPath.row]
        cell.textLabel?.font = UIFont(name: (cell.textLabel?.font.fontName)!, size:14)
        cell.textLabel?.text = title
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reportType = reportsTitle[indexPath.row]
        confirmSheet(reportType: reportType)
        
    }
    
    func confirmSheet(reportType: String) {
       _ = self.user
       let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
       let confirm = UIAlertAction(title: "Confirm", style: .destructive) { (UIAlertAction) in
        
        _ = Defaults[.email]
        
        if !self.artInfo.isEmpty {
        if self.artInfo[1] is Art {
        /*DataService.instance.REF_MAILGUN.sendMessage(to: "kerby.jean@hotmail.fr", from: "user@hotmail.fr", subject: "Report Art", body: "Report type: \(reportType), Art Title: \(art.title), Artist: \(art.userUid)", success: { (success) in
            self.confirmAlert(title:"\(art.title) Reported" , message: "Your opinion is important for us. We'll contact you soon for more information. Thank you.")
            self.cancelBtn.title = "Done"
        }, failure: { (error) in
            self.confirmAlert(title:"Failed to report" , message: "Sorry the request failed. Please try again.")
        })*/
      }
        } else {
          
            /*DataService.instance.REF_MAILGUN.sendMessage(to: "kerby.jean@hotmail.fr", from: userEmail, subject: "Report User", body: "Report type: \(reportType), Artist name: \(user!.name)", success: { (success) in
                self.confirmAlert(title:"\(user!.name) has been Reported" , message: "Your opinion is important for us. We'll contact you soon for more information. Thank you.")
            self.cancelBtn.title = "Done"
            }, failure: { (error) in
                self.confirmAlert(title:"Failed to report" , message: "Sorry the request failed. Please try again.")
            })*/

        }
}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(confirm)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }
    
    func confirmAlert(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}





