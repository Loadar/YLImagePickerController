//
//  DFUtil.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/27.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

public class DFUtil {
    
    public static let shared = DFUtil()
    
    public var buttonInsetHandler: ((UIButton, UIEdgeInsets) -> Void)?
    
    public class var isIPhoneX: Bool {
        // 若安全区域底部大于0，可判定为iPhoneX系列
        var status = false
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first, window.safeAreaInsets.bottom > 0 {
                status = true
            }
        } else {
            // Fallback on earlier versions
        }
        return status
    }
    
    public class func set(button: UIButton, insets: UIEdgeInsets) {
        shared.buttonInsetHandler?(button, insets)
    }
}
