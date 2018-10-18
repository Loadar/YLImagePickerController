//
//  DFYLImageCell.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/28.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

class DFYLImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    let selectButton = UIButton(type: .custom)
    
    var imageSelectHandler: ((UICollectionViewCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectButton)
        
        imageView.addConstraints(toItem: contentView, edgeInsets: .zero)
        selectButton.addConstraints(attributes: [.top, .right, .width, .height], toItem: contentView, attributes: nil, constants: [4, -4, 20, 20])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        selectButton.imageView?.contentMode = .scaleAspectFit
        selectButton.setImage(UIImage.yl_imageName("photo_no_selected"), for: .normal)
        selectButton.setImage(UIImage.yl_imageName("photo_selected"), for: .selected)
        selectButton.adjustsImageWhenHighlighted = false
        selectButton.addTarget(self, action: #selector(imageSelected(_:)), for: .touchUpInside)
        DFUtil.set(button: selectButton, insets: UIEdgeInsets(top: -4, left: -10, bottom: -10, right: -4))
    }
    
    @objc private func imageSelected(_: Any) {
        imageSelectHandler?(self)
    }
}
