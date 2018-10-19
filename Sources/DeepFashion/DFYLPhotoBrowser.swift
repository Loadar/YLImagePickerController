//
//  DFYLPhotoBrowser.swift
//  YLImagePickerController
//
//  Created by Aaron on 2018/9/28.
//  Copyright © 2018年 February12. All rights reserved.
//

import UIKit

/// DFYLPhotoBrowserDelegate
protocol DFYLPhotoBrowserDelegate: NSObjectProtocol {
    func numberOfPhotos() -> Int
    func photo(at index: Int) -> YLPhoto?
    func photoSelected(at index: Int)
}

//let ImageViewTag = 1000

class DFYLPhotoBrowser: UIViewController {
    weak var delegate: DFYLPhotoBrowserDelegate?
    var dataArray = [Int: YLPhoto]() // 数据源
    
    fileprivate var currentIndex: Int = 0 // 当前index
    fileprivate var animatedTransition:YLAnimatedTransition? // 控制器动画
    var collectionView : UICollectionView!
    
    private let navigationView = UIView()
    private let backButton = UIButton(type: .custom)
    private let selectButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        animatedTransition = nil
    }
    
    convenience init(index: Int, delegate: DFYLPhotoBrowserDelegate) {
        self.init()
        
        currentIndex = index
        self.delegate = delegate
        
        let photo = photoData(at: currentIndex)
        
        animatedTransition = YLAnimatedTransition()
        (delegate as? UIViewController)?.navigationController?.delegate = animatedTransition
        
        editTransitioningDelegate(photo!)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        
        layoutUI()
        configureView()

        let photo = photoData(at: currentIndex)
        updateSelectButton(with: photo?.assetModel)
        
        collectionView.scrollToItem(at: IndexPath.init(row: currentIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
    }
    
    // MARK: - UI
    private func configureView() {
        view.addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(selectButton)
        
        let statusHeight: CGFloat = DFUtil.isIPhoneX ? 44 : 20
        let height: CGFloat = statusHeight + 44
        navigationView.addConstraints(attributes: [.left, .top, .right, .height], toItem: view, attributes: nil, constants: [0, 0, 0, height])
        backButton.addConstraints(attributes: [.left, .width, .height, .centerY], toItem: navigationView, attributes: nil, constants: [15, 10, 20, statusHeight / 2])
        selectButton.addConstraints(attributes: [.right, .width, .height], toItem: navigationView, attributes: nil, constants: [-15, 20, 20])
        selectButton.addConstraint(attribute: .centerY, toItem: backButton, attribute: .centerY, constant: 0)

        navigationView.backgroundColor = .white
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.setImage(UIImage.yl_imageName("dfBack"), for: .normal)
        backButton.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        DFUtil.set(button: backButton, insets: UIEdgeInsets(top: -8, left: -10, bottom: -8, right: -10))

        selectButton.imageView?.contentMode = .scaleAspectFit
        selectButton.setImage(UIImage.yl_imageName("photo_no_selected"), for: .normal)
        selectButton.setImage(UIImage.yl_imageName("photo_selected"), for: .selected)
        selectButton.adjustsImageWhenHighlighted = false
        selectButton.addTarget(self, action: #selector(imageSelected(_:)), for: .touchUpInside)
        DFUtil.set(button: selectButton, insets: UIEdgeInsets(top: -4, left: -10, bottom: -10, right: -4))
    }
    
    private func layoutUI() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        collectionView.register(YLPhotoCell.self, forCellWithReuseIdentifier: "YLPhotoCell")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        // collectionView 约束
        collectionView.addConstraints(toItem: view, edgeInsets: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        view.layoutIfNeeded()
    }
    
    // MARK: -- Update
    private func updateSelectButton(with assetModel: YLAssetModel?) {
        selectButton.isSelected = assetModel?.isSelected ?? false
    }
    
    private func updateSelectButton(with index: Int) {
        let photo = photoData(at: index)
        updateSelectButton(with: photo?.assetModel)
    }

    // MARK: - Action
    @objc private func back(_: Any) {
        let photo = photoData(at: currentIndex)
        editTransitioningDelegate(photo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func imageSelected(_: Any) {
        delegate?.photoSelected(at: currentIndex)
        updateSelectButton(with: currentIndex)
    }
    
    // 获取imageView frame
    class func getImageViewFrame(_ size: CGSize) -> CGRect {
        let window = UIApplication.shared.keyWindow
        
        let w = window?.frame.width ?? UIScreen.main.bounds.width
        let h = window?.frame.height ?? UIScreen.main.bounds.height
        
        if size.width > w {
            let height = w * (size.height / size.width)
            if height <= h {
                
                let frame = CGRect.init(x: 0, y: h/2 - height/2, width: w, height: height)
                return frame
            }else {
                
                let frame = CGRect.init(x: 0, y: 0, width: w, height: height)
                return frame
                
            }
        }else {
            
            if size.height <= h {
                let frame = CGRect.init(x: w/2 - size.width/2, y: h/2 - size.height/2, width: size.width, height: size.height)
                return frame
            }else {
                let frame = CGRect.init(x: w/2 - size.width/2, y: 0, width: size.width, height: size.height)
                return frame
            }
            
        }
    }
    
    // 获取 currentImageView
    func getCurrentImageView() -> UIImageView? {
        guard let collectionView = self.collectionView else { return nil }
        guard let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) else { return nil }
        return cell.viewWithTag(ImageViewTag) as? UIImageView
    }
    
    // 修改 transitioningDelegate
    func editTransitioningDelegate(_ photo: YLPhoto) {
        let currentImageView = getCurrentImageView()
        
        var transitionBrowserImgFrame = CGRect.zero
        if currentImageView != nil {
            transitionBrowserImgFrame = (currentImageView?.frame)!
        }else if photo.image != nil {
            transitionBrowserImgFrame = YLPhotoBrowser.getImageViewFrame((photo.image?.size)!)
        }else {
            transitionBrowserImgFrame = YLPhotoBrowser.getImageViewFrame(CGSize.init(width: view.frame.width, height: view.frame.width))
        }
        
        animatedTransition?.update(photo.image,transitionOriginalImgFrame: photo.frame, transitionBrowserImgFrame: transitionBrowserImgFrame)
    }
    
    // 获取数据源,并缓存数据
    func photoData(at index: Int) -> YLPhoto? {
        if let photo = dataArray[index] { return photo }
        guard let photo = delegate?.photo(at: index) else { return nil }
        
        dataArray[index] = photo
        if dataArray.count > 5 {
            let keys = [Int](dataArray.keys).sorted()
            if abs(keys.first! - index) > abs(keys.last! - index) {
                dataArray.removeValue(forKey: keys.first!)
            }
        }
        return photo
    }
    
    func cache(photo: YLPhoto, at index: Int) {
        dataArray[index] = photo
        
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension DFYLPhotoBrowser:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfPhotos() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: YLPhotoCell.self), for: indexPath)
        guard let photo = photoData(at: indexPath.item) else { return cell }
        guard let photoCell = cell as? YLPhotoCell else { return cell }
        
        photoCell.updatePhoto(photo)
        photoCell.delegate = self
        
        return photoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: view.frame.width, height: view.frame.height)
    }
    
    // 已经停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === collectionView else { return }
        
        currentIndex = Int(scrollView.contentOffset.x / view.frame.width)
        let photo = photoData(at: currentIndex)
        updateSelectButton(with: photo?.assetModel)
    }
}


// MARK: - YLPhotoCellDelegate
extension DFYLPhotoBrowser: YLPhotoCellDelegate {
    
    func epPhotoPanGestureRecognizerBegin(_ pan: UIPanGestureRecognizer, photo: YLPhoto) {
        navigationView.isHidden = true
        
        animatedTransition?.transitionOriginalImgFrame = photo.frame
        animatedTransition?.gestureRecognizer = pan
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func epPhotoPanGestureRecognizerEnd(_ currentImageViewFrame: CGRect, photo: YLPhoto) {
        animatedTransition?.gestureRecognizer = nil
        animatedTransition?.update(photo.image,transitionOriginalImgFrame: photo.frame, transitionBrowserImgFrame: currentImageViewFrame)
    }
    
    func epPhotoSingleTap() {
        navigationView.isHidden = !navigationView.isHidden
    }
    
    func epPhotoDoubleTap() {
        if let imageView = getCurrentImageView(),
            let scrollView = imageView.superview as? UIScrollView,
            let image = imageView.image {
            
            if scrollView.zoomScale == 1 {
                
                var scale:CGFloat = 0
                
                let height = ceil(DFYLPhotoBrowser.getImageViewFrame(image.size).height)
                if height >= view.frame.height {
                    scale = 2
                }else {
                    scale = view.frame.height / height
                }
                
                scale = scale > 4 ? 4: scale
                scale = scale < 1 ? 2: scale
                
                scrollView.setZoomScale(scale, animated: true)
            }else {
                scrollView.setZoomScale(1, animated: true)
            }
            
        }
    }
}
