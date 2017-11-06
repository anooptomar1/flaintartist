//
//  InputCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class InputCell: UICollectionViewCell, UITextFieldDelegate {
    
    let textField: TextFieldRect = {
        let field = TextFieldRect()
        field.returnKeyType = .continue
        field.autocapitalizationType = .none
        field.attributedPlaceholder = NSAttributedString(string: "Sign up with Phone or Email",  attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        field.font = UIFont.systemFont(ofSize: 15)
        return field
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textField)
        contentView.layer.addSublayer(separator)
        textField.addTarget(self, action: #selector(textHasChanged(texfield:)), for: .editingChanged)
        textField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.characters.count < 0 {
            NotificationCenter.default.post(name: emailNotEnteredNotification, object: nil)
        } else {
            NotificationCenter.default.post(name: emailEnteredNotification, object: nil)
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: emailEnteredNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: emailNotEnteredNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        textField.frame = bounds
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    @objc func textHasChanged(texfield: UITextField) {
        Defaults[.email] = textField.text!
    }
}


final class NextCell: UICollectionViewCell {
    
    let button: UIButton = {
        let but = UIButton()
        but.isEnabled = false
        but.contentHorizontalAlignment = .left
        but.setTitleColor(UIColor.lightGray, for: .normal)
        but.setTitle("Continue", for: .normal)
        but.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return but
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        contentView.layer.addSublayer(separator)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextTapped)))
        NotificationCenter.default.addObserver(self, selector: #selector(enableButton), name:emailEnteredNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableButton), name:emailNotEnteredNotification, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: emailEnteredNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: emailNotEnteredNotification, object: nil)
    }
    
    
    @objc func enableButton() {
        button.setTitleColor(self.tintColor, for: .normal)
        button.isEnabled = true
    }
    
    @objc func disableButton() {
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.isEnabled = false
    }
    
    
    @objc func nextTapped() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterNextVC") as! RegisterNextVC
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        button.frame = CGRect(x: 10, y: 0, width: bounds.width, height: bounds.height)
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
}

final class SignInCell: UICollectionViewCell {
    
    let button: UIButton = {
        let but = UIButton()
        but.contentHorizontalAlignment = .left
        but.setTitleColor(but.tintColor, for: .normal)
        but.setTitle("Already have an account? Sign In", for: .normal)
        but.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return but
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        contentView.layer.addSublayer(separator)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signIn)))
    }
    
   
    
    @objc func signIn() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        button.frame = CGRect(x: 10, y: 0, width: bounds.width, height: bounds.height)
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
}

