//
//  TitleCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-29.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import SwiftyUserDefaults

class TitleCell: UICollectionViewCell, UITextFieldDelegate {
    
    fileprivate let textField: TextFieldRect = {
        let field = TextFieldRect()
        field.attributedPlaceholder = NSAttributedString(string: "Title",  attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return field
    }()
    
    fileprivate let label: UILabel = {
        let view = UILabel()
        view.text = "Title"
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()

    
    let topSeparator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()

    
   @objc func textHasChanged(texfield: UITextField) {
         Defaults[.title] = textField.text!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(textField)
        contentView.layer.addSublayer(topSeparator)
        contentView.layer.addSublayer(separator)
        
        textField.delegate = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.textField.becomeFirstResponder()
        }
        textField.addTarget(self, action: #selector(textHasChanged(texfield:)), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let width: CGFloat = 80
        let height: CGFloat = 0.5
        label.frame = CGRect(x: 10, y: 0, width: width, height: bounds.height)
        textField.frame = CGRect(x:  width + 20, y: 0, width: bounds.width - label.frame.width, height: bounds.height)
        topSeparator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        separator.frame = CGRect(x: width + 20, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    func configure(title: String) {
        textField.text = title
    }
}
