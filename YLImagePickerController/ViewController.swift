//
//  ViewController.swift
//  YLImagePickerController
//
//  Created by yl on 2017/8/30.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView: UITableView = {
    
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        
        return tableView
        
    }()
    
    var dataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataArray += ["单选不裁剪","单选方形裁剪","单选圆形裁剪","多选","拍照不裁剪","拍照方形裁剪"]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = dataArray[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var imagePicker:YLImagePickerController?
        
        switch indexPath.row {
        case 0:
            imagePicker = YLImagePickerController.init(imagePickerType: ImagePickerType.album, cropType: CropType.none)
        case 1:
            imagePicker = YLImagePickerController.init(imagePickerType: ImagePickerType.album, cropType: CropType.square)
        case 2:
            imagePicker = YLImagePickerController.init(imagePickerType: ImagePickerType.album, cropType: CropType.circular)
        case 3:
            imagePicker = YLImagePickerController.init(maxImagesCount: 3)
        case 4:
            imagePicker = YLImagePickerController.init(imagePickerType: ImagePickerType.camera, cropType: CropType.none)
        case 5:
            imagePicker = YLImagePickerController.init(imagePickerType: ImagePickerType.camera, cropType: CropType.square)
        default:
            break
        }
        /// 可以选择GIf
        imagePicker?.isNeedSelectGifImage = true
        /// 可以选择视频
        imagePicker?.isNeedSelectVideo = true
        imagePicker?.didFinishPickingPhotosHandle = {(photos: [YLPhotoModel]) in
            for photo in photos {
                
                if photo.type == YLAssetType.photo {
                    print((UIImagePNGRepresentation(photo.image!)?.count)! / 1024)
                }else if photo.type == YLAssetType.gif {
                    print((photo.data?.count)! / 1024)
                }else if photo.type == YLAssetType.video {
                    print("视频")
                }
            }
        }
        present(imagePicker!, animated: true, completion: nil)
        
    }
}

