//
//  TitleCell.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-29.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

class TitleCell: UICollectionViewCell, UITextFieldDelegate {
    
    fileprivate let textField: UITextField = {
        let field = UITextField()
        field.editingRect(forBounds: CGRect(x: 10, y: 0, width: field.frame.width, height: field.frame.height))
        field.textRect(forBounds: CGRect(x: 10, y: 0, width: field.frame.width, height: field.frame.height))
        return field
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.textField.becomeFirstResponder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textField)
        contentView.layer.addSublayer(topSeparator)
        contentView.layer.addSublayer(separator)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        textField.frame = bounds
        let height: CGFloat = 0.5
        topSeparator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        separator.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    func configure(title: String) {
        textField.text = title
    }
}
