//
//  DFUtil.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/27.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

class DFUtil {
    
    class var isIPhoneX: Bool {
        let size = UIScreen.main.bounds.size
        let iPhoneXSize = CGSize(width: 375, height: 812)
        let status = abs(size.width - iPhoneXSize.width) < 1e-6 && abs(size.height - iPhoneXSize.height) < 1e-6
        return status
    }

    
}
