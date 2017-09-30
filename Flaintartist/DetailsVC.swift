//
//  DetailsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import YYText

final class DetailsVC: UITableViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}


extension DetailsVC:  YYTextViewDelegate, YYTextKeyboardObserver {
    
    func configure() {
        let textView = YYTextView()
        textView.delegate = self
        textView.frame = textCell.bounds
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.darkText
        textView.tintColor = UIColor.darkText
        textView.dataDetectorTypes = .all
        textView.placeholderText = "Description"
        textView.keyboardDismissMode = .interactive
        textView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0)
        textView.scrollIndicatorInsets = textView.contentInset
        textCell.addSubview(textView)
    }
}
