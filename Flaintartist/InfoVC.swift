//
//  InfoVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-23.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class InfoVC: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    
    var art: Art?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let title = art?.title
         let type = art?.type
         let height = art!.artHeight
         let width = art!.artWidth
        
        titleTextField.text = title
        typeTextField.text = type
        heightTextField.text = "\(String(describing: height)) cm"
        widthTextField.text = "\(String(describing: width)) cm"
        
    }
    
    
    func save() {
        let ref = DataService.instance.REF_ARTISTARTS.child(Auth.auth().currentUser!.uid).child((self.art?.artID)!)
        let title = titleTextField.text!
        let type = typeTextField.text!
        let height = heightTextField.text!
        let width = widthTextField.text!
        ref.updateChildValues(["title": title, "type": type, "artHeight": height, "artWidth": width]) { (error, reference) in
            guard error == nil else {
                print("ERROR SAVE NEW INFO")
                return
            }
        }
    }

}
