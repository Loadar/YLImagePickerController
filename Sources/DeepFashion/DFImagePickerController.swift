//
//  DFImagePickerController.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/27.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit
import Photos

public class DFImagePickerController: UIViewController {
    private struct DFConfiguration {
        static let imageInterSpace: CGFloat = 3
        static let imageEdgeSpace: CGFloat = 3
        static let imageCountInRow: CGFloat = 4
        static let imageSize: CGSize = {
            let width = floor((UIScreen.main.bounds.width - imageEdgeSpace * 2 - imageInterSpace * 3) / imageCountInRow)
            return CGSize(width: width, height: width)
        }()
    }
    
    private let navigationView = UIView()
    private let backButton = UIButton(type: .custom)
    private let albumButton = DFYLCustomButton(type: .custom)
    private let confirmButton = UIButton(type: .custom)
    
    private let albumView = UIView()
    private let albumBackgroundView = UIView()
    private let albumContainerView = UIView()
    private let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 75)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = DFConfiguration.imageSize
        layout.minimumLineSpacing = DFConfiguration.imageInterSpace
        layout.minimumInteritemSpacing = DFConfiguration.imageInterSpace
        layout.sectionInset = UIEdgeInsets(top: DFConfiguration.imageEdgeSpace, left: DFConfiguration.imageEdgeSpace, bottom: DFConfiguration.imageEdgeSpace, right: DFConfiguration.imageEdgeSpace)
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let noAuthView = UIView()
    private let noAuthLabel = UILabel()
    
    private var albumList = [PHAssetCollection]()
    private var showAlbumList = false
    private var albumIndex = 0
    
    private var imageList = [YLAssetModel]()
    private var selectedImageIndexPathes = [IndexPath]()
    
    var maxImageCount = Int.max
    var completionHandler: (([YLPhotoModel]) -> Void)?

    private var photoBrowserDataSource: YLPhotoBrowserDataSource = YLPhotoBrowserDataSource.all
    
    public class func controller(maxImageCount: Int, completion handler: @escaping ([YLPhotoModel]) -> Void) -> UINavigationController {
        let controller = DFImagePickerController()
        controller.maxImageCount = maxImageCount
        controller.completionHandler = handler
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureView()
        updateAlbumButton()
        
        let status = DFImagePickerController.checkPhotoAuth { (isEnabled) in
            DispatchQueue.main.async {
                if isEnabled {
                    self.noAuthView.isHidden = true
                    
                } else {
                    self.noAuthView.isHidden = false
                }
            }
        }
        self.noAuthView.isHidden = status
        
        fetchAlbumData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView() {
        view.addSubview(imageCollectionView)
        view.addSubview(albumView)
        albumView.addSubview(albumBackgroundView)
        albumView.addSubview(albumContainerView)
        albumContainerView.addSubview(albumCollectionView)
        view.addSubview(noAuthView)
        noAuthView.addSubview(noAuthLabel)
        view.addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(albumButton)
        navigationView.addSubview(confirmButton)
        
        let statusHeight: CGFloat = DFUtil.isIPhoneX ? 44 : 20
        let height: CGFloat = statusHeight + 44
        navigationView.addConstraints(attributes: [.left, .top, .right, .height], toItem: view, attributes: nil, constants: [0, 0, 0, height])
        backButton.addConstraints(attributes: [.left, .width, .height, .centerY], toItem: navigationView, attributes: nil, constants: [15, 10, 20, statusHeight / 2])
        
        albumButton.addConstraints(attributes: [.centerX], toItem: navigationView, attributes: nil, constants: [0])
        albumButton.addConstraints(attributes: [.centerY], toItem: backButton, attributes: nil, constants: [0])
        albumButton.addConstraints(attributes: [.height], toItem: nil, attributes: nil, constants: [20])
        albumButton.addConstraints(attributes: [.width], toItem: nil, attributes: nil, constant: 60)
        
        confirmButton.addConstraints(attributes: [.right], toItem: navigationView, attributes: nil, constants: [-15])
        confirmButton.addConstraints(attributes: [.centerY], toItem: backButton, attributes: nil, constants: [0])
        
        albumView.addConstraints(attributes: [.left, .bottom, .right], toItem: view, attributes: nil, constants: [0, 0, 0])
        albumView.addConstraint(attribute: .top, toItem: navigationView, attribute: .bottom, constant: 0)
        albumBackgroundView.addConstraints(toItem: albumView, edgeInsets: .zero)
        albumContainerView.addConstraints(attributes: [.left, .top, .right, .height], toItem: albumView, attributes: nil, constants: [0, 0, 0, 0])
        albumCollectionView.addConstraints(attributes: [.left, .top, .right, .height], toItem: albumContainerView, attributes: nil, constants: [0, 0, 0, 300])

        imageCollectionView.addConstraints(attributes: [.left, .bottom, .right], toItem: view, attributes: nil, constants: [0, 0, 0])
        imageCollectionView.addConstraint(attribute: .top, toItem: navigationView, attribute: .bottom, constant: 0)

        noAuthView.addConstraints(attributes: [.left, .bottom, .right], toItem: view, attributes: nil, constants: [0, 0, 0])
        noAuthView.addConstraint(attribute: .top, toItem: navigationView, attribute: .bottom, constant: 0)
        noAuthLabel.addConstraints(attributes: [.top, .centerX], toItem: noAuthView, attributes: nil, constants: [100, 0])
        
        view.backgroundColor = .white
        navigationView.backgroundColor = .white
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.setImage(UIImage.yl_imageName("dfBack"), for: .normal)
        backButton.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        DFUtil.set(button: backButton, insets: UIEdgeInsets(top: -8, left: -10, bottom: -8, right: -10))
        
        albumButton.imageView?.contentMode = .scaleAspectFit
        albumButton.setImage(UIImage.yl_imageName("expand"), for: .normal)
        albumButton.setImage(UIImage.yl_imageName("collapse"), for: .selected)
        albumButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        albumButton.titleLabel?.textAlignment = .left
        albumButton.setTitleColor(UIColor(red: 18.0 / 255.0, green: 18.0 / 255.0, blue: 18.0 / 255.0, alpha: 1), for: .normal)
        albumButton.setTitle("相册", for: .normal)
        albumButton.titleLabel?.lineBreakMode = .byTruncatingTail
        albumButton.addTarget(self, action: #selector(toSelectAlbum(_:)), for: .touchUpInside)
        DFUtil.set(button: albumButton, insets: UIEdgeInsets(top: -8, left: 0, bottom: -8, right: 0))
        
        confirmButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        confirmButton.titleLabel?.textAlignment = .right
        confirmButton.setTitle("确定", for: .normal)
        confirmButton.setTitleColor(UIColor(red: 18.0 / 255.0, green: 18.0 / 255.0, blue: 18.0 / 255.0, alpha: 1), for: .normal)
        confirmButton.setTitleColor(UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1), for: .disabled)
        confirmButton.addTarget(self, action: #selector(confirm(_:)), for: .touchUpInside)
        DFUtil.set(button: confirmButton, insets: UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
        confirmButton.isEnabled = false
        
        albumView.backgroundColor = .clear
        albumView.isHidden = true
        albumBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        albumBackgroundView.alpha = 0
        albumBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toSelectAlbum(_:))))
        albumContainerView.backgroundColor = .white
        albumContainerView.clipsToBounds = true
        
        albumCollectionView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            albumCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        albumCollectionView.register(DFAlbumCell.self, forCellWithReuseIdentifier: String(describing: DFAlbumCell.self))
        
        imageCollectionView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            imageCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.register(DFYLImageCell.self, forCellWithReuseIdentifier: String(describing: DFYLImageCell.self))
        if DFUtil.isIPhoneX {
            imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        }
        
        noAuthView.backgroundColor = .white
        noAuthLabel.font = UIFont(name: "PingFangSC-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        noAuthLabel.textAlignment = .center
        noAuthLabel.textColor = UIColor(red: 150.0 / 255.0, green: 150.0 / 255.0, blue: 150.0 / 255.0, alpha: 1)
        noAuthLabel.text = "请在iPhone的“设置-隐私-相册”选项中\r\n允许Deep Fashion访问你的相册"
        noAuthLabel.numberOfLines = 2
        noAuthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toSettings(_:))))
        noAuthView.isHidden = true
        
        // line
        let line = UIView()
        navigationView.addSubview(line)
        line.addConstraints(attributes: [.left, .bottom, .right, .height], toItem: navigationView, attributes: nil, constants: [0, 0, 0, 1 / UIScreen.main.scale])
        line.backgroundColor = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1)
    }
    
    private func updateAlbumButton() {
        var showAlbumButton = false
        defer { albumButton.isHidden = !showAlbumButton }
        guard (0..<albumList.count).contains(albumIndex) else { return }
        let item = albumList[albumIndex]
        let name: String = item.localizedTitle ?? ""
        showAlbumButton = true
        
        albumButton.setTitle(name, for: .normal)
        var width = name.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: [.font: albumButton.titleLabel!.font], context: nil).width
        let maxTextWidth = UIScreen.main.bounds.width - 150
        width = min(width, maxTextWidth)
        
        albumButton.updateConstraint(attribute: .width, toItem: nil, attribute: .width, constant: width + 20)
        albumButton.df_set(imageInsets: UIEdgeInsets(top: 6, left: width + 5, bottom: 6, right: 0), for: .normal)
        albumButton.df_set(titleInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15), for: .normal)
    }
    
    private func updateConfirmButton() {
        confirmButton.isEnabled = selectedImageIndexPathes.count > 0
    }
    
    // MARK: - Action
    @objc private func back(_: Any) {
        confirmSelection(photos: [])
    }
    
    // 统一的退出处理
    private func confirmSelection(photos: [YLPhotoModel]) {
        let handler = self.completionHandler
        self.dismiss(animated: true, completion: {
            handler?(photos)
        })
    }
    
    @objc private func toSelectAlbum(_: Any) {
        showAlbumList = !showAlbumList
        albumButton.isSelected = !albumButton.isSelected
        
        let height = min(albumCollectionView.contentSize.height, UIScreen.main.bounds.height / 2)
        let containerHeight = showAlbumList ? height : 0
        albumContainerView.updateConstraint(attribute: .height, toItem: nil, attribute: .height, constant: containerHeight)
        albumCollectionView.updateConstraint(attribute: .height, toItem: nil, attribute: .height, constant: height)
        if showAlbumList {
            albumView.isHidden = false
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.albumBackgroundView.alpha = self.showAlbumList ? 1 : 0
            self.albumView.layoutIfNeeded()
        }) { (_) in
            self.albumView.isHidden = !self.showAlbumList
        }
    }
    
    @objc private func confirm(_: Any) {
        selectionFinished()
    }
    
    @objc private func toSettings(_: Any) {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.openURL(url)
    }
}

// MARK: - Export
extension DFImagePickerController {
    private func selectionFinished() {
        let models: [YLAssetModel] = selectedImageIndexPathes.map { imageList[$0.item] }
        
        var photos = [YLPhotoModel]()
        for assetModel in models {
            if assetModel.type == .gif || assetModel.type == .video {
                continue
            }
                
            let options = PHImageRequestOptions()
            options.resizeMode = PHImageRequestOptionsResizeMode.fast
            options.isSynchronous = true
            PHImageManager.default().requestImage(for: assetModel.asset, targetSize: CGSize.init(width: assetModel.asset.pixelWidth, height: assetModel.asset.pixelHeight), contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (result:UIImage?, _) in
                if let image = result {
                    let photoModel = YLPhotoModel.init(image: image,asset: assetModel.asset)
                    photos.append(photoModel)
                }
            })
        }
        
        self.confirmSelection(photos: photos)
    }
}

// MARK: - Auth
extension DFImagePickerController {
    class func checkPhotoAuth(checkPhotoAuthBlock: @escaping CheckPhotoAuthBlock) -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus) in
                if(status == PHAuthorizationStatus.authorized) {
                    checkPhotoAuthBlock(true)
                }else {
                    checkPhotoAuthBlock(false)
                }
            })
        } else if authStatus == PHAuthorizationStatus.authorized {
            return true
        }
        return false
    }
}

// MARK: - Data
extension DFImagePickerController {
    private func fetchAlbumData() {
        DispatchQueue.global().async { [weak self] in
            let smartAssetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
            smartAssetCollections.enumerateObjects({ (assetCollection, _, _) in
                let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                // 过滤空相册
                if assets.count != 0 {
                    self?.albumList.append(assetCollection)
                }
            })
            
            var photoFetched = false
            var count = self?.albumList.count ?? 0
            if count > 0 {
                DispatchQueue.main.async {
                    self?.fetchPhotoData()
                }
                photoFetched = true
            }
            
            let userAssetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
            userAssetCollections.enumerateObjects({ (assetCollection, _, _) in
                let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                // 过滤空相册
                if assets.count != 0 {
                    self?.albumList.append(assetCollection)
                }
            })
            
            DispatchQueue.main.async {
                self?.albumCollectionView.reloadData()
                
                count = self?.albumList.count ?? 0
                if count > 0, !photoFetched {
                    self?.fetchPhotoData()
                }
            }
        }
    }
    
    private func fetchPhotoData() {
        guard (0..<albumList.count).contains(albumIndex) else { return }
        let album = albumList[albumIndex]
        
        self.updateAlbumButton()
        
        imageList.removeAll()
        selectedImageIndexPathes.removeAll()
        updateConfirmButton()
        
        DispatchQueue.global().async { [weak self] in
            let assets = PHAsset.fetchAssets(in: album, options: nil)
            assets.enumerateObjects({ (asset, _, _) in
                let model = YLAssetModel()
                model.asset = asset
                
                // 忽略视频
                if asset.mediaType == .video {
                    return
                }
                // 忽略gif
                if asset.mediaType == .image {
                    if let assetType = asset.value(forKey: "filename") as? String {
                        if assetType.hasSuffix("GIF") == true {
                            return
                        }
                    }
                }
                
                self?.imageList.append(model)
                
            })
            
            
            DispatchQueue.main.async {
                self?.imageCollectionView.reloadData()
                //                    self?.navigationItem.title = self?.assetCollection?.localizedTitle
                //                    self?.collectionView.reloadData()
                //                    if (self?.photos.count)! > 12 {
                //                        self?.collectionView.scrollToItem(at: IndexPath.init(row: (self?.photos.count)! - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: false)
                //                    }
            }
        }
    }
}

extension DFImagePickerController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === albumCollectionView { return albumList.count }
        if collectionView === imageCollectionView { return imageList.count }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = String(describing: DFAlbumCell.self)
        if collectionView === imageCollectionView {
            identifier = String(describing: DFYLImageCell.self)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        
        if let albumCell = cell as? DFAlbumCell, (0..<albumList.count).contains(indexPath.item) {
            let item = albumList[indexPath.item]
            
            let assets = PHAsset.fetchAssets(in: item, options: nil)

            albumCell.titleLabel.text = item.localizedTitle
            albumCell.imageCountLabel.text = "\(assets.count)张图片"
            albumCell.separator.isHidden = indexPath.item == albumList.count - 1
            albumCell.checkView.isHidden = albumIndex != indexPath.item
            
            if let asset = assets.lastObject {
                
                let options = PHImageRequestOptions()
                options.resizeMode = PHImageRequestOptionsResizeMode.fast
                options.isSynchronous = true
                
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 55, height: 55), contentMode: PHImageContentMode.aspectFill, options: options) { (image: UIImage?, _) in
                    albumCell.imageView.image = image
                }
            }
        } else if let imageCell = cell as? DFYLImageCell, (0..<imageList.count).contains(indexPath.item) {
            let item = imageList[indexPath.item]
            
            if item.thumbnailImage == nil {
                // 生成缩略图
                let options = PHImageRequestOptions()
                options.resizeMode = PHImageRequestOptionsResizeMode.fast
                options.isSynchronous = true
                
                PHImageManager.default().requestImage(for: item.asset, targetSize: DFConfiguration.imageSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image:UIImage?, _) in
                    
                    item.thumbnailImage = image
                })
            }
            
            imageCell.imageView.image = item.thumbnailImage
            imageCell.selectButton.isSelected = item.isSelected
            
            imageCell.imageSelectHandler = { [weak self] (cell) in
                self?.selectImage(of: cell)
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === albumCollectionView {
            defer { toSelectAlbum(albumButton) }
            if albumIndex == indexPath.item { return }
            var indexPathes: [IndexPath] = [IndexPath(item: albumIndex, section: 0)]
            indexPathes.append(indexPath)
            albumIndex = indexPath.item

            collectionView.reloadItems(at: indexPathes)
            self.fetchPhotoData()
        } else if collectionView === imageCollectionView {
            let photoBrowser = DFYLPhotoBrowser(index: indexPath.item, delegate: self)
            self.navigationController?.pushViewController(photoBrowser, animated: true)
        }
    }
    
    private func selectImage(of cell: UICollectionViewCell) {
        guard let indexPath = imageCollectionView.indexPath(for: cell) else { return }
        guard (0..<imageList.count).contains(indexPath.item) else { return }
        let item = imageList[indexPath.item]
        
        if !item.isSelected {
            if selectedImageIndexPathes.count >= maxImageCount {
                UIAlertView.init(title: nil, message: "最多只能选择\(maxImageCount)张照片", delegate: nil, cancelButtonTitle: "确定").show()
                return
            }
            
            item.isSelected  = true
            selectedImageIndexPathes.append(indexPath)
            
            imageCollectionView.reloadItems(at: [indexPath])
        } else {
            item.isSelected = false
            if let index = selectedImageIndexPathes.index(of: indexPath) {
                selectedImageIndexPathes.remove(at: index)
            }
        }
        
        imageCollectionView.reloadItems(at: [indexPath])
        updateConfirmButton()
    }
    
    private func selectImage(with model: YLAssetModel) {
        guard let index = imageList.index(where: { $0 === model }) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        
        let item = imageList[indexPath.item]
        
        if !item.isSelected {
            if selectedImageIndexPathes.count >= maxImageCount {
                UIAlertView.init(title: nil, message: "最多只能选择\(maxImageCount)张照片", delegate: nil, cancelButtonTitle: "确定").show()
                return
            }
            
            item.isSelected  = true
            selectedImageIndexPathes.append(indexPath)
            
            imageCollectionView.reloadItems(at: [indexPath])
        } else {
            item.isSelected = false
            if let index = selectedImageIndexPathes.index(of: indexPath) {
                selectedImageIndexPathes.remove(at: index)
            }
        }
        
        imageCollectionView.reloadItems(at: [indexPath])
        updateConfirmButton()

    }
}

// MARK: - YLPhotoBrowserDelegate
extension DFImagePickerController : DFYLPhotoBrowserDelegate {
    func numberOfPhotos() -> Int {
        return imageList.count
    }
    
    func photo(at index: Int) -> YLPhoto? {
        guard (0..<imageList.count).contains(index) else { return YLPhoto() }
        let assetModel = imageList[index]
        
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.fast
        options.isSynchronous = true
        
        var photo: YLPhoto?
        
        let aspectRatio: CGFloat = CGFloat(assetModel.asset.pixelWidth) / CGFloat(assetModel.asset.pixelHeight)
        var pixelWidth: CGFloat = imageCollectionView.frame.width * 2
        // 超宽图片
        if aspectRatio > 1.8 {
            pixelWidth = pixelWidth * aspectRatio
        }
        // 超高图片
        if aspectRatio < 0.2 {
            pixelWidth = pixelWidth * 0.5
        }
        var pixelHeight:CGFloat = pixelWidth / aspectRatio
        
        if pixelWidth > CGFloat(assetModel.asset.pixelWidth) ||
            pixelHeight > CGFloat(assetModel.asset.pixelHeight) {
            
            pixelWidth = CGFloat(assetModel.asset.pixelWidth)
            pixelHeight = CGFloat(assetModel.asset.pixelHeight)
        }
        
        let imageSize = CGSize.init(width: pixelWidth, height: pixelHeight)
        PHImageManager.default().requestImage(for: assetModel.asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFill, options: options) { (result:UIImage?, _) in
            if let image = result {
                var frame:CGRect?
                
                if let row = self.imageList.index(where: { $0 === assetModel }),
                    let cell = self.imageCollectionView.cellForItem(at: IndexPath.init(row: row, section: 0)) {
                    
                    frame = self.imageCollectionView.convert(cell.frame, to: self.imageCollectionView.superview)
                    
                    if frame!.minY < 64 ||  frame!.maxY > self.view.frame.height - 44 {
                        frame = CGRect.zero
                    }
                }
                
                photo = YLPhoto.addImage(image, frame: frame)
                photo?.assetModel = assetModel
            }
        }
        
        return photo ?? YLPhoto()
    }
    
    func photoSelected(at index: Int) {
        guard (0..<imageList.count).contains(index) else { return }
        let model = imageList[index]
        selectImage(with: model)
    }
}
