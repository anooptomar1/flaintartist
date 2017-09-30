//
//  DescriptionCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-29.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import YYText

class DescriptionCell: UICollectionViewCell, UITextFieldDelegate, YYTextViewDelegate {
    
    fileprivate let textView: YYTextView = {
        let field = YYTextView()
        field.font = UIFont.systemFont(ofSize: 18)
        field.textColor = UIColor.darkText
        field.dataDetectorTypes = .all
        field.placeholderText = "Description"
        field.keyboardDismissMode = .interactive
        field.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0)
        field.scrollIndicatorInsets = field.contentInset
        return field
    }()
    
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.separatorColor
        return layer
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textView)
        contentView.layer.addSublayer(separator)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        textView.frame = bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    func configure(description: String) {
        textView.text = description
    }
}

