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

    // MARK: - Public Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.config?.preferredStatusBarStyle ?? .default
    }

    // MARK: - Internal Properties
    
    internal var album: PHAssetCollection {
        didSet {
            guard self.album != oldValue else {
                return
            }
            self.selectedAssets = []
            self.assets = []
            self.collectionView?.reloadData()
            
            self.configureForNewAlbum()
        }
    }
    
    internal fileprivate(set) var selectedAssets = [PHAsset]() {
        didSet {
            self.reloadDoneButtonState()
        }
    }
    
    var showingAlbums: Bool {
        guard self.config?.singleViewMode == true, let titleView = self.navigationItem.titleView as? AlbumTitleView else {
            return false
        }
        return titleView.flipArrow
    }
    
    // MARK: - Private Properties
    
    fileprivate var showCameraButton: Bool {
        guard self.album.isUserLibrary, UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            return false
        }
        return self.config?.showCameraOption ?? false
    }
    
    fileprivate var emptyView: AlbumEmptyView? {
        didSet {
            self.emptyView?.colors = self.config?.colors
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
    
    /// When the album view is animating in. Only used when the config is set to "SingleViewMode".
    fileprivate var animatingAlbumView = false
    
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
                        self.selectAsset(selectedAsset)
                    }
                    self.emptyView = collectionView.numberOfItems(inSection: 0) <= 0  ? AlbumEmptyView() : nil
                })
                
            }
        }
    }
    
    lazy fileprivate var doneButton: UIBarButtonItem = {
        let buttonitem = self.pickerViewController?.customDoneButtonItem() ?? UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        buttonitem.target = self
        buttonitem.action = #selector(AssetsGridViewController.done(_:))
        buttonitem.accessibilityIdentifier = "tatsi.button.done"
        buttonitem.tintColor = self.config?.colors.link ?? TatsiConfig.default.colors.link
        return buttonitem
    }()
    
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
        
        self.collectionView?.backgroundColor = self.config?.colors.background ?? TatsiConfig.default.colors.background
        
        self.collectionView?.accessibilityIdentifier = "tatsi.collectionView.photosGrid"
        
        self.configureForNewAlbum()
        
        self.collectionView?.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem = self.doneButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(AssetsGridViewController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        if #available(iOS 13.0, *) {
            // needed because iOS 13 does not call traitCollectionDidChange after being added to the view hierarchy like older iOS versions
            self.updateCollectionViewLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isRootModalViewController = self.navigationController?.viewControllers.first == self && self.presentingViewController != nil
        
        let cancelButtonItem = self.pickerViewController?.customCancelButtonItem() ?? UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        cancelButtonItem.target = self
        cancelButtonItem.action = #selector(cancel(_:))
        cancelButtonItem.tintColor = self.config?.colors.link ?? TatsiConfig.default.colors.link
        cancelButtonItem.accessibilityIdentifier = "tatsi.button.cancel"
        
        self.navigationItem.leftBarButtonItem = isRootModalViewController ? cancelButtonItem : nil
    }
    
    // MARK: - Accessibility
    
    public override func accessibilityPerformEscape() -> Bool {
        if showingAlbums {
            self.changeAlbum(nil)
        } else {
            if self.config?.singleViewMode == true {
                self.cancelPicking()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        return true
    }
    
    // MARK: - Actions
    
    @objc fileprivate func cancel(_ sender: AnyObject) {
        self.cancelPicking()
    }
    
    @objc fileprivate func done(_ sender: AnyObject) {
        let selectedAssets = self.selectedAssets
        if selectedAssets.isEmpty {
            self.cancelPicking()
        } else {
            self.finishPicking(with: selectedAssets)
        }
    }
    
    @objc fileprivate func changeAlbum(_ sender: AnyObject?) {
        guard let titleView = self.navigationItem.titleView as? AlbumTitleView, !self.animatingAlbumView else {
            return
        }
        let animator = UIViewPropertyAnimator(duration: 0.32, curve: .easeInOut) {
            titleView.flipArrow = !titleView.flipArrow
        }
        if !titleView.flipArrow {
            self.showAlbumsViews(animator: animator)
        } else {
            self.hideAlbumsViews(animator: animator)
        }
        animator.addCompletion { (_) in
            self.animatingAlbumView = false
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
        }
        self.animatingAlbumView = true
        animator.startAnimation()
    }
    
    // MARK: - Albums list management
    
    fileprivate func showAlbumsViews(animator: UIViewPropertyAnimator) {
        guard self.children.isEmpty else {
            return
        }
        let albumsViewController = AlbumsViewController()
        albumsViewController.delegate = self

        self.addChild(albumsViewController)
        var frame = self.view.bounds
        frame.origin.y -= frame.height
        albumsViewController.view.frame = frame
        if #available(iOS 11, *) {
            albumsViewController.tableView.contentInset = UIEdgeInsets()
            albumsViewController.tableView.scrollIndicatorInsets = UIEdgeInsets()
        } else {
            albumsViewController.tableView.contentInset = self.collectionView?.contentInset ?? UIEdgeInsets()
            albumsViewController.tableView.scrollIndicatorInsets = self.collectionView?.contentInset ?? UIEdgeInsets()
        }
        self.view.addSubview(albumsViewController.view)
        albumsViewController.didMove(toParent: self)
        
        animator.addAnimations {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            albumsViewController.view.frame = self.view.bounds
        }
    }
    
    fileprivate func hideAlbumsViews(animator: UIViewPropertyAnimator) {
        guard let albumsViewController = self.children.first as? AlbumsViewController else {
            return
        }
        animator.addAnimations {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.reloadDoneButtonState()
            
            var frame = self.view.bounds
            frame.origin.y -= frame.height
            albumsViewController.view.frame = frame
        }
        animator.addCompletion { (_) in
            albumsViewController.removeFromParent()
            albumsViewController.view.removeFromSuperview()
            albumsViewController.didMove(toParent: nil)
        }
    }
    
    fileprivate func configureForNewAlbum() {
        self.title = self.album.localizedTitle
        if let color = self.config?.colors.label {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color]
        }
        self.startFetchingAssets()
        
        self.reloadDoneButtonState()
        
        if self.config?.singleViewMode ?? false {
            let titleView = AlbumTitleView()
            titleView.colors = self.config?.colors
            titleView.title = self.album.localizedTitle
            titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
            titleView.addTarget(self, action: #selector(changeAlbum(_:)), for: .touchUpInside)
            self.navigationItem.titleView = titleView
        }
    }
    
    // MARK: - Button state
    
    fileprivate func reloadDoneButtonState() {
        self.doneButton.isEnabled = !self.selectedAssets.isEmpty
    }
    
    // MARK: - Fetching
    
    fileprivate func startFetchingAssets() {
        guard let fetchOptions = self.config?.assetFetchOptions() else {
            return
        }
        if !self.showCameraButton {
            self.emptyView = AlbumEmptyView(state: .loading)
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
    
    fileprivate func addAsset(_ asset: PHAsset) {
        if self.config?.invertUserLibraryOrder == true {
            self.assets?.insert(asset, at: 0)
        } else {
            self.assets?.append(asset)
        }
    }
    
    fileprivate func selectAsset(_ asset: PHAsset) {
        if !self.selectedAssets.contains(asset) {
            self.selectedAssets.append(asset)
        }
        if let index = self.assets?.firstIndex(of: asset) {
            let additionalIndex = self.config?.invertUserLibraryOrder == true && self.showCameraButton ? 1 : 0
            self.collectionView.selectItem(at: IndexPath(item: index + additionalIndex, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
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
        cell.colors = self.config?.colors
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
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: LocalizableStrings.accessibilityAlertSelectionLimitReached)
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let asset = self.asset(for: indexPath) {
            if !self.selectedAssets.contains(asset) {
                guard self.selectedAssets.count < self.config?.maxNumberOfSelections ?? Int.max else {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: LocalizableStrings.accessibilityAlertSelectionLimitReached)
                    return
                }
                self.selectedAssets.append(asset)
                if let maxSelection = self.config?.maxNumberOfSelections, maxSelection == 1, self.config?.finishImmediatelyWithMaximumOfOne != false {
                    self.finishPicking(with: self.selectedAssets)
                }
            }
        } else {
            let cameraController = UIImagePickerController()
            cameraController.sourceType = UIImagePickerController.SourceType.camera
            cameraController.delegate = self
            self.present(cameraController, animated: true, completion: nil)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let asset = self.asset(for: indexPath), let index = self.selectedAssets.firstIndex(of: asset) else {
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

// MARK: - AlbumsViewControllerDelegate

extension AssetsGridViewController: AlbumsViewControllerDelegate {
    
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection) {
        let titleView = self.navigationItem.titleView as? AlbumTitleView
        
        self.album = album
        let animator = UIViewPropertyAnimator(duration: 0.32, curve: .easeInOut) {
            titleView?.flipArrow = false
        }
        self.hideAlbumsViews(animator: animator)
        animator.addCompletion { (_) in
            self.animatingAlbumView = false
        }
        self.animatingAlbumView = true
        animator.startAnimation()
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension AssetsGridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else {
            return
        }
        self.createAsset(from: image) { [weak self] (asset, error) in
            if let asset = asset {
                self?.addAsset(asset)
                self?.selectAsset(asset)
            } else if let error = error {
                print("Error saving photo \(error)")
            } else {
                self?.startFetchingAssets()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //Save the image
        self.createAsset(from: image) { [weak self] (asset, error) in
            if let asset = asset {
                
                self?.addAsset(asset)
                self?.selectAsset(asset)
            } else if let error = error {
                print("Error saving photo \(error)")
            } else {
                self?.startFetchingAssets()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createAsset(from image: UIImage, completionHandler: @escaping ((_ asset: PHAsset?, _ error: Error?) -> Void)) {
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
        }) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(nil, error)
                } else if let localIdentifier = localIdentifier, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    completionHandler(asset, nil)
                } else {
                    completionHandler(nil, nil)
                }
            }
            
        }
    }
    
}
