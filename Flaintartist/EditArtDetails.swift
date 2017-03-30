//
//  DetailsView.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/31/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftMessages

class EditArtDetails: MessageView, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var art: Art!

    var saveAction: (() -> Void)?

    
    func configureView(forArt: Art) {
        self.art = forArt
        priceField.text = "\(art.price)"
        titleField.text = art.title
        descField.text = art.description
        if art.isPrivate == true {
            privateSwitch.setOn(true, animated: false)
        }
    }
    
    
    
    @IBAction func privateSwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            self.art.isPrivate = true
        } else {
            self.art.isPrivate = false
        }
    }
    

    @IBAction func saveBtnTapped(_ sender: UIButton) {
        sender.setTitle("", for: .normal)
        indicator.startAnimating()
        saveAction?()
        sender.setTitle("Save", for: .normal)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == priceField {
            textField.resignFirstResponder()
            titleField.becomeFirstResponder()
        }
        return true
    }
}

