//
//  DFYLCustomButton.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/28.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

class DFYLCustomButton: UIButton {
    private var dfImageInsetsMap = [UInt: UIEdgeInsets]()
    private var dfTitleInsetsMap = [UInt: UIEdgeInsets]()
    private var dfContentInsetsMap = [UInt: UIEdgeInsets]()
    
    private var dfImageInsets: UIEdgeInsets { return insets(with: dfImageInsetsMap) }
    private var dfTitleInsets: UIEdgeInsets { return insets(with: dfTitleInsetsMap) }
    private var dfContentInsets: UIEdgeInsets { return insets(with: dfContentInsetsMap) }
    
    private func insets(with map: [UInt: UIEdgeInsets]) -> UIEdgeInsets {
        let state = self.state
        // 查找当前状态
        if let insets = map[state.rawValue] { return insets }
        // selected高亮与非高亮一致
        if state.contains(.selected), let insets = map[UIControlState.selected.rawValue] { return insets }
        // 查找normal状态
        if let insets = map[UIControlState.normal.rawValue] { return insets }
        // 默认值
        return .zero
    }
    
    func df_set(imageInsets: UIEdgeInsets, for state: UIControlState) {
        self.dfImageInsetsMap[state.rawValue] = imageInsets
    }
    
    func df_set(titleInsets: UIEdgeInsets, for state: UIControlState) {
        self.dfTitleInsetsMap[state.rawValue] = titleInsets
    }
    
    func df_set(contentInsets: UIEdgeInsets, for state: UIControlState) {
        self.dfContentInsetsMap[state.rawValue] = contentInsets
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(contentRect, dfImageInsets)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(contentRect, dfTitleInsets)
    }
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, dfContentInsets)
    }
}

