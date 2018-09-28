//
//  DFAlbumCell.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/28.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

class DFAlbumCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let imageCountLabel = UILabel()
    let checkView = UIImageView()
    let separator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageCountLabel)
        contentView.addSubview(checkView)
        contentView.addSubview(separator)
        
        imageView.addConstraints(attributes: [.left, .centerY, .width, .height], toItem: contentView, attributes: nil, constants: [15, 0, 55, 55])
        titleLabel.addConstraint(attribute: .top, toItem: imageView, attribute: .top, constant: 2)
        titleLabel.addConstraint(attribute: .left, toItem: imageView, attribute: .right, constant: 10)
        titleLabel.addConstraints(attributes: [.height], toItem: nil, attributes: nil, constant: 20)
        titleLabel.addConstraint(attribute: .right, relatedBy: .lessThanOrEqual, toItem: checkView, attribute: .left, multiplier: 1, constant: -10)
        imageCountLabel.addConstraint(attribute: .bottom, toItem: imageView, attribute: .bottom, constant: -3)
        imageCountLabel.addConstraint(attribute: .left, toItem: imageView, attribute: .right, constant: 10)
        imageCountLabel.addConstraints(attributes: [.height], toItem: nil, attributes: nil, constant: 17)
        imageCountLabel.addConstraint(attribute: .right, relatedBy: .lessThanOrEqual, toItem: checkView, attribute: .left, multiplier: 1, constant: -10)
        checkView.addConstraints(attributes: [.right, .centerY, .width, .height], toItem: contentView, attributes: nil, constants: [-15, 0, 20, 14])
        separator.addConstraints(attributes: [.left, .right, .bottom, .height], toItem: contentView, attributes: nil, constants: [15, -15, 0, 1 / UIScreen.main.scale])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(red: 15.0 / 255.0, green: 15.0 / 255.0, blue: 15.0 / 255.0, alpha: 1)
        imageCountLabel.font = UIFont(name: "PingFangSC-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        imageCountLabel.textAlignment = .left
        imageCountLabel.textColor = UIColor(red: 15.0 / 255.0, green: 15.0 / 255.0, blue: 15.0 / 255.0, alpha: 1)
        checkView.contentMode = .scaleAspectFit
        checkView.image = UIImage.yl_imageName("check")
        checkView.isHidden = true
        separator.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1)
    }
}
