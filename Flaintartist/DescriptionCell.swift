//
//  DescriptionCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-29.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import YYText
import SwiftyUserDefaults

class DescriptionCell: UICollectionViewCell, YYTextViewDelegate {
    
    fileprivate let textView: UITextView = {
        let field = UITextView()
        field.font = UIFont.systemFont(ofSize: 18)
        field.textColor = UIColor.darkText
        field.keyboardDismissMode = .interactive
        field.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0)
        field.scrollIndicatorInsets = field.contentInset
        return field
    }()
    
    fileprivate let label: UILabel = {
        let view = UILabel()
        view.text = "Description"
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(textView)
        contentView.layer.addSublayer(separator)
    }
    
    
    @objc func textHasChanged(textView: UITextView) {
        print("TEXTVIW: \(textView.text)")
        Defaults[.description] = textView.text!
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
        textView.frame = CGRect(x:  width + 20, y: 0, width: bounds.width - label.frame.width, height: bounds.height)
        separator.frame = CGRect(x: width + 20, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    func configure(description: String) {
        textView.text = description
    }
}

