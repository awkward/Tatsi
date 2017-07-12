//
//  AssetsGridViewController.swift
//  AWKImagePickerController
//
//  Created by Rens Verhoeven on 27-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AssetsGridViewController: UICollectionViewController, PickerViewController {
    
    // MARK: - Internal Properties
    
    internal let album: PHAssetCollection
    
    internal fileprivate(set) var selectedAssets = [PHAsset]()
    
    // MARK: - Private Properties
    
    fileprivate var showCameraButton: Bool {
        guard self.album.isUserLibrary, UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) else {
            return false
        }
        return self.config?.showCameraOption ?? false
    }
    
    fileprivate var emptyView: AlbumEmptyView? {
        didSet {
            self.collectionView?.backgroundView = self.emptyView
        }
    }
    
    fileprivate let thumbnailCachingManager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        manager.allowsCachingHighQualityImages = false
        return manager
    }()
    
    fileprivate var thumbnailImageSize = CGSize(width: 100, height: 100)
    
    fileprivate var numberOfCells: Int {
        return (self.assets?.count ?? 0) + (self.showCameraButton ? 1 : 0)
    }
    
    /// If the user scrolled the grid by dragging
    fileprivate var userScrolled = false
    
    fileprivate var assets: [PHAsset]? {
        didSet {
            guard let collectionView = self.collectionView else {
                return
            }
            DispatchQueue.main.async {
                UIView.performWithoutAnimation({
                    collectionView.reloadSections(IndexSet(integer: 0))
                    if self.config?.invertUserLibraryOrder == false && self.userScrolled == false && self.album.assetCollectionType == .smartAlbum {
                        self.scrollToEnd()
                    }
                    for selectedAsset in self.selectedAssets {
                        if let index = self.assets?.index(of: selectedAsset) {
                            collectionView.selectItem(at: IndexPath(item: index + (self.showCameraButton ? 1 : 0), section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
                        }
                    }
                    if collectionView.numberOfItems(inSection: 0) <= 0 {
                        self.emptyView = AlbumEmptyView()
                    }
                })
                
            }
        }
    }
    
    // MARK: - Initializers
    
    init(album: PHAssetCollection) {
        self.album = album
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifier)
        self.collectionView?.register(CameraCollectionViewCell.self, forCellWithReuseIdentifier: CameraCollectionViewCell.reuseIdentifier)
        
        self.collectionView?.backgroundColor = .white
        
        self.title = album.localizedTitle
        self.startFetchingAssets()
        
        self.collectionView?.allowsMultipleSelection = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AssetsGridViewController.done(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(AssetsGridViewController.applicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func done(_ sender: AnyObject) {
        let selectedAssets = self.selectedAssets
        if selectedAssets.isEmpty {
            self.cancelPicking()
        } else {
            self.finishPicking(with: selectedAssets)
        }
    }
    
    // MARK: - Fetching
    
    fileprivate func startFetchingAssets() {
        guard let fetchOptions = self.config?.assetFetchOptions() else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let result = PHAsset.fetchAssets(in: strongSelf.album, options: fetchOptions)
            var allAssets = [PHAsset]()
            result.enumerateObjects({ (asset, _, _) in
                allAssets.append(asset)
            })
            DispatchQueue.main.async {
                self?.emptyView = nil
                if self?.config?.invertUserLibraryOrder == true && strongSelf.album.isUserLibrary {
                    allAssets.reverse()
                }
                self?.assets = allAssets
            }
        }
        
    }
    
    // MARK: - Notifications
    
    @objc fileprivate func applicationDidBecomeActive(_ notification: Notification) {
        self.startFetchingAssets()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.emptyView?.layoutMargins = UIEdgeInsets(top: self.topLayoutGuide.length + 20, left: 20, bottom: self.bottomLayoutGuide.length + 20, right: 20)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateCollectionViewLayout()
    }
    
    fileprivate func updateCollectionViewLayout() {
        var numberOfColumns: CGFloat = 4
        if self.view.frame.width >= 480 {
            numberOfColumns = 7
        }
        if let fixedNumberOfColumns = self.config?.numberOfColumns {
            numberOfColumns = CGFloat(fixedNumberOfColumns)
        }
        let spacing: CGFloat = 1
        let cellWidth = floor((self.view.frame.width - (spacing * numberOfColumns - 1)) / numberOfColumns)
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            self.thumbnailImageSize = CGSize(width: cellWidth, height: cellWidth)
            flowLayout.itemSize = self.thumbnailImageSize
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.minimumLineSpacing = spacing
        }
        
    }
    
    // MARK: - Helpers
    
    fileprivate func asset(for indexPath: IndexPath) -> PHAsset? {
        guard let assets = self.assets else {
            return nil
        }
        if self.config?.invertUserLibraryOrder == true {
            if indexPath.row == 0 && self.showCameraButton {
                return nil
            }
        } else {
            if indexPath.row >= assets.count && self.showCameraButton {
                return nil
            }
        }
        
        let index = indexPath.row - (self.showCameraButton && self.config?.invertUserLibraryOrder == true ? 1 : 0)
        guard index < assets.count && index >= 0 else {
            return nil
        }
        return assets[index]
    }

    fileprivate func scrollToEnd() {
        guard let collectionView = self.collectionView else {
            return
        }
        let section = collectionView.numberOfSections - 1
        let item = collectionView.numberOfItems(inSection: section) - 1
        guard section >= 0, item >= 0 else {
            return
        }
        let lastIndexPath = IndexPath(item: item, section: section)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
    }
    
}

// MARK: - UICollectionViewDataSource

extension AssetsGridViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfCells
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = self.asset(for: indexPath) else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCollectionViewCell.reuseIdentifier, for: indexPath) as? CameraCollectionViewCell else {
                fatalError("CameraCollectionViewCell should be registered")
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.reuseIdentifier, for: indexPath) as? AssetCollectionViewCell else {
            fatalError("AssetCollectionViewCell should be registered")
        }
        cell.imageSize = self.thumbnailImageSize
        cell.imageManager = self.thumbnailCachingManager
        cell.asset = asset
        cell.reloadContents()
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension AssetsGridViewController {

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard self.selectedAssets.count < self.config?.maxNumberOfSelections ?? Int.max else {
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let asset = self.asset(for: indexPath) {
            if !self.selectedAssets.contains(asset) {
                guard self.selectedAssets.count < self.config?.maxNumberOfSelections ?? Int.max else {
                    return
                }
                self.selectedAssets.append(asset)
                if let maxSelection = self.config?.maxNumberOfSelections, maxSelection == 1 {
                    self.finishPicking(with: self.selectedAssets)
                }
            }
        } else {
            let cameraController = UIImagePickerController()
            cameraController.sourceType = UIImagePickerControllerSourceType.camera
            cameraController.delegate = self
            self.present(cameraController, animated: true, completion: nil)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let asset = self.asset(for: indexPath), let index = self.selectedAssets.index(of: asset) else {
            return
        }
        self.selectedAssets.remove(at: index)
    }
    
}

// MARK: - UIScrollViewDelegate

extension AssetsGridViewController {

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.userScrolled = true
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension AssetsGridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Save the image
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
            }) { (_, error) in
                DispatchQueue.main.async(execute: { [weak self] in
                    if let error = error {
                        NSLog("Error performing changes \(error)")
                    } else {
                        if let localIdentifier = localIdentifier, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                            self?.selectedAssets.append(asset)
                            self?.assets?.insert(asset, at: 0)
                            
                        } else {
                            self?.startFetchingAssets()
                        }
                    }
                })
                
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
