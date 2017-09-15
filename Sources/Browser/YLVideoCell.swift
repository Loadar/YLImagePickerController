//
//  YLVideoCell.swift
//  YLImagePickerController
//
//  Created by yl on 2017/9/15.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit
import Photos

protocol YLVideoCellDelegate :NSObjectProtocol {
    func epVideoPanGestureRecognizerBegin(_ pan: UIPanGestureRecognizer,photo: YLPhoto)
    func epVideoPanGestureRecognizerEnd(_ currentImageViewFrame: CGRect,photo: YLPhoto)
    func epVideoSingleTap()
}

class YLVideoCell: UICollectionViewCell {
    
    var photo: YLPhoto!
    
    weak var delegate: YLVideoCellDelegate?
    
    // 图片容器
    let imageView: UIImageView = {
        
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.clear
        imgView.tag = ImageViewTag
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        return imgView
        
    }()
    
    let playBtn: UIButton = {
        
        let playBtn = UIButton.init(type: UIButtonType.custom)
        playBtn.setTitle("播放", for: UIControlState.normal)
        playBtn.setTitleColor(UIColor.red, for: UIControlState.normal)
        return playBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        
        backgroundColor = UIColor.clear
        
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addLayoutConstraint(toItem: self, edgeInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        
        self.addSubview(playBtn)
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        playBtn.addLayoutConstraint(attributes: [.centerX,.centerY], toItem: self, constants: [0,0])
     
        
        // 手势
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(YLPhotoCell.singleTap))
        self.addGestureRecognizer(singleTap)
    }
    
    /// 单击手势
    func singleTap() {
        delegate?.epVideoSingleTap()
    }
    
    func updatePhoto(_ photo: YLPhoto) {
        
        self.photo = photo
    
        imageView.image = nil
        
        if let image = photo.image {
            imageView.frame = YLPhotoBrowser.getImageViewFrame(image.size)
            imageView.image = image
        }
        
//        if photo.assetModel?.type == .gif {
//            if let asset = photo.assetModel?.asset {
//                let options = PHImageRequestOptions()
//                options.resizeMode = PHImageRequestOptionsResizeMode.fast
//                options.isSynchronous = true
//                PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { [weak self] (data:Data?, dataUTI:String?, _, _) in
//                    
//                    if let data = data {
//                        self?.imageView.image =  UIImage.yl_gifWithData(data)
//                    }
//                    
//                })
//            }
//        }
    }
    
}
