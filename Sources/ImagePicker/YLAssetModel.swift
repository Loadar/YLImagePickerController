//
//  YLAssetModel.swift
//  YLImagePickerController
//
//  Created by yl on 2017/8/30.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit
import Photos


/// 图片类型
///
/// - photo: jpg、png
/// - gif: gif动画
/// - video: 视频
enum YLAssetType {
    case photo
    case gif
    case video
}

class YLAssetModel {
    /// 资源
    var asset: PHAsset!
    /// 类型
    var type: YLAssetType!
    /// 缩略图
    var thumbnailImage: UIImage?
    /// 是否选择
    var isSelected: Bool = false
    /// 第几个被选择的
    var selectedSerialNumber: Int = 0
    
}
