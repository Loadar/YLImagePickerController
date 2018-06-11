//
//  YLToolbarBottom.swift
//  YLImagePickerController
//
//  Created by yl on 2017/9/1.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit

class YLToolbarBottom: UIView {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var originalImageClickBtn: UIButton!
    @IBOutlet weak var originalImageImageView: UIImageView!
    @IBOutlet weak var previewBtn: UIButton!
    
    var sendBtnDefaultColor: UIColor?
    
    override func awakeFromNib() {
        sendBtnDefaultColor = sendBtn.backgroundColor
        originalImageImageView.layer.cornerRadius = 7
        originalImageImageView.clipsToBounds = true
        originalImageImageView.layer.borderColor = UIColor.white.cgColor
        originalImageImageView.layer.borderWidth = 0.5
        
        previewBtn.isHidden = true
    }
    
    func originalImageBtnIsSelect(_ isSelect: Bool) {
        if isSelect == false {
            originalImageImageView.image = nil
        }else {
           originalImageImageView.image = UIImage.yl_imageName("photo_selected")
        }
    }
    
    func sendBtnIsSelect(_ isSelect: Bool) {
        if isSelect == false {
            sendBtn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            sendBtn.isEnabled = false
        }else {
            sendBtn.setTitleColor(UIColor.init(red: 0.28, green: 0.53, blue: 0.98, alpha: 1.00), for: UIControlState.normal)
            sendBtn.isEnabled = true
        }
    }
    
    func previewBtnIsSelect(_ isSelect: Bool) {
        if isSelect == false {
            previewBtn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            previewBtn.isEnabled = false
        }else {
//            (r:0.28 g:0.53 b:0.98 a:1.00)
            previewBtn.setTitleColor(UIColor.init(red: 0.28, green: 0.53, blue: 0.98, alpha: 1.00), for: UIControlState.normal)
            previewBtn.isEnabled = true
        }
    }
    
    // 根据xib初始化
    class func loadNib() -> YLToolbarBottom {
        
        if let toolbar = Bundle.yl_imagePickerNibBundle().loadNibNamed("YLToolbarBottom", owner: nil, options: nil)?.first as? YLToolbarBottom {
            return toolbar
        }else {
            return YLToolbarBottom()
        }
        
    }
}
