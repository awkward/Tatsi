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
    return config?.preferredStatusBarStyle ?? .default
  }
  
  // MARK: - Internal Properties
  
  internal var album: PHAssetCollection {
    didSet {
      guard album != oldValue else {
        return
      }
      selectedAssets = []
      assets = []
      collectionView?.reloadData()
      
      configureForNewAlbum()
    }
  }
  
  internal fileprivate(set) var selectedAssets = [PHAsset]() {
    didSet {
      reloadDoneButtonState()
    }
  }
  
  var showingAlbums: Bool {
    guard config?.singleViewMode == true, let titleView = navigationItem.titleView as? AlbumTitleView else {
      return false
    }
    return titleView.flipArrow
  }
  
  // MARK: - Private Properties
  
  fileprivate var showCameraButton: Bool {
    guard album.isUserLibrary, UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
      return false
    }
    return config?.showCameraOption ?? false
  }
  
  fileprivate var emptyView: AlbumEmptyView? {
    didSet {
      emptyView?.colors = config?.colors
      collectionView?.backgroundView = emptyView
    }
  }
  
  fileprivate let thumbnailCachingManager: PHCachingImageManager = {
    let manager = PHCachingImageManager()
    manager.allowsCachingHighQualityImages = false
    return manager
  }()
  
  fileprivate var thumbnailImageSize = CGSize(width: 100, height: 100)
  
  fileprivate var numberOfCells: Int {
    return (assets?.count ?? 0) + (showCameraButton ? 1 : 0)
  }
  
  /// If the user scrolled the grid by dragging
  fileprivate var userScrolled = false
  
  /// When the album view is animating in. Only used when the config is set to "SingleViewMode".
  fileprivate var animatingAlbumView = false
  
  fileprivate var assets: [PHAsset]? {
    didSet {
      guard let collectionView = collectionView else {
        return
      }
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        UIView.performWithoutAnimation({
          collectionView.reloadSections(IndexSet(integer: 0))
          if strongSelf.config?.invertUserLibraryOrder == false && strongSelf.userScrolled == false && strongSelf.album.assetCollectionType == .smartAlbum {
            strongSelf.scrollToEnd()
          }
          for selectedAsset in strongSelf.selectedAssets {
            strongSelf.selectAsset(selectedAsset)
          }
          strongSelf.emptyView = collectionView.numberOfItems(inSection: 0) <= 0  ? AlbumEmptyView() : nil
        })
        
      }
    }
  }
  
  lazy fileprivate var doneButton: UIBarButtonItem = {
    // If we have a custom button bar item that uses a UIButton, we cannot leverage the `target` and `action` for the UIButtonBar. We must use the UIButton.addTarget
    if let button = pickerViewController?.customDoneButtonItem() {
      button.addTarget(self, action: #selector(done), for: .touchUpInside)
      let doneBarButton = UIBarButtonItem(customView: button)
      doneBarButton.accessibilityIdentifier = "tatsi.button.done"
      doneBarButton.tintColor = config?.colors.link ?? TatsiConfig.default.colors.link
      return doneBarButton
    } else {
      // We use the default
      let defaultDoneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
      defaultDoneBarButton.accessibilityIdentifier = "tatsi.button.done"
      defaultDoneBarButton.tintColor = config?.colors.link ?? TatsiConfig.default.colors.link
      return defaultDoneBarButton
    }
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
    
    PHPhotoLibrary.shared().register(self)
    
    collectionView?.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifier)
    collectionView?.register(CameraCollectionViewCell.self, forCellWithReuseIdentifier: CameraCollectionViewCell.reuseIdentifier)
    
    collectionView?.backgroundColor = config?.colors.background ?? TatsiConfig.default.colors.background
    
    collectionView?.accessibilityIdentifier = "tatsi.collectionView.photosGrid"
    
    configureForNewAlbum()
    
    collectionView?.allowsMultipleSelection = true
    
    navigationItem.rightBarButtonItem = doneButton
    
    NotificationCenter.default.addObserver(self, selector: #selector(AssetsGridViewController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    if #available(iOS 13.0, *) {
      // needed because iOS 13 does not call traitCollectionDidChange after being added to the view hierarchy like older iOS versions
      updateCollectionViewLayout()
    }
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let isRootModalViewController = navigationController?.viewControllers.first == self && presentingViewController != nil
    
    let cancelButtonItem = pickerViewController?.customCancelButtonItem() ?? UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    cancelButtonItem.target = self
    cancelButtonItem.action = #selector(cancel(_:))
    cancelButtonItem.tintColor = config?.colors.link ?? TatsiConfig.default.colors.link
    cancelButtonItem.accessibilityIdentifier = "tatsi.button.cancel"
    
    navigationItem.leftBarButtonItem = isRootModalViewController ? cancelButtonItem : nil
  }
  
  // MARK: - Accessibility
  
  public override func accessibilityPerformEscape() -> Bool {
    if showingAlbums {
      changeAlbum(nil)
    } else {
      if config?.singleViewMode == true {
        cancelPicking()
      } else {
        navigationController?.popViewController(animated: true)
      }
    }
    return true
  }
  
  // MARK: - Actions
  
  @objc fileprivate func cancel(_ sender: AnyObject) {
    cancelPicking()
  }
  
  @objc fileprivate func done(_ sender: AnyObject) {
    let selectedAssets = selectedAssets
    if selectedAssets.isEmpty {
      cancelPicking()
    } else {
      finishPicking(with: selectedAssets)
    }
  }
  
  @objc fileprivate func changeAlbum(_ sender: AnyObject?) {
    guard let titleView = navigationItem.titleView as? AlbumTitleView, !animatingAlbumView else {
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.32, curve: .easeInOut) {
      titleView.flipArrow = !titleView.flipArrow
    }
    if !titleView.flipArrow {
      showAlbumsViews(animator: animator)
    } else {
      hideAlbumsViews(animator: animator)
    }
    animator.addCompletion { [weak self] _ in
      self?.animatingAlbumView = false
      UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
    }
    animatingAlbumView = true
    animator.startAnimation()
  }
  
  // MARK: - Albums list management
  
  fileprivate func showAlbumsViews(animator: UIViewPropertyAnimator) {
    guard children.isEmpty else {
      return
    }
    let albumsViewController = AlbumsViewController()
    albumsViewController.delegate = self
    
    addChild(albumsViewController)
    var frame = view.bounds
    frame.origin.y -= frame.height
    albumsViewController.view.frame = frame
    if #available(iOS 11, *) {
      albumsViewController.tableView.contentInset = UIEdgeInsets()
      albumsViewController.tableView.scrollIndicatorInsets = UIEdgeInsets()
    } else {
      albumsViewController.tableView.contentInset = collectionView?.contentInset ?? UIEdgeInsets()
      albumsViewController.tableView.scrollIndicatorInsets = collectionView?.contentInset ?? UIEdgeInsets()
    }
    view.addSubview(albumsViewController.view)
    albumsViewController.didMove(toParent: self)
    
    animator.addAnimations { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.navigationItem.leftBarButtonItem?.isEnabled = false
      strongSelf.navigationItem.rightBarButtonItem?.isEnabled = false
      albumsViewController.view.frame = strongSelf.view.bounds
    }
  }
  
  fileprivate func hideAlbumsViews(animator: UIViewPropertyAnimator) {
    guard let albumsViewController = children.first as? AlbumsViewController else {
      return
    }
    animator.addAnimations { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.navigationItem.leftBarButtonItem?.isEnabled = true
      strongSelf.reloadDoneButtonState()
      
      var frame = strongSelf.view.bounds
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
    title = updateTitleBasedOnSelectedAssets()
    if let color = config?.colors.label {
      navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color]
    }
    startFetchingAssets()
    
    reloadDoneButtonState()
    
    if config?.singleViewMode ?? false {
      let titleView = AlbumTitleView()
      titleView.colors = config?.colors
      titleView.title = album.localizedTitle
      titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
      titleView.addTarget(self, action: #selector(changeAlbum(_:)), for: .touchUpInside)
      navigationItem.titleView = titleView
    }
  }
  
  fileprivate func updateTitleBasedOnSelectedAssets() -> String {
    var updatedTitle = ""
    let assetCount = selectedAssets.count
    let videoSelected = selectedAssets.contains(where: { $0.mediaType == .video })
    let photosSelected = selectedAssets.contains(where: { $0.mediaType == .image })
    
    if videoSelected && photosSelected {
      // We know we have more than 1 item if both are true.
      updatedTitle = "\(assetCount) items selected"
    } else if videoSelected {
      // User can only select one video.
      updatedTitle = "\(assetCount) video selected"
    } else if photosSelected {
      // We only have photo(s)
      updatedTitle = assetCount > 1 ? "\(assetCount) photos selected" : "\(assetCount) photo selected"
    } else {
      // There are no selected assets
      updatedTitle = "Tap to Select"
    }
    return updatedTitle
  }
  
  // MARK: - Button state
  
  fileprivate func reloadDoneButtonState() {
    doneButton.isEnabled = !selectedAssets.isEmpty
  }
  
  // MARK: - Fetching
  
  fileprivate func startFetchingAssets() {
    guard let fetchOptions = config?.assetFetchOptions() else {
      return
    }
    if !showCameraButton {
      emptyView = AlbumEmptyView(state: .loading)
    }
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let strongSelf = self else {
        return
      }
      let result = PHAsset.fetchAssets(in: strongSelf.album, options: fetchOptions)
      var allAssets = [PHAsset]()
      result.enumerateObjects({ asset, _, _ in
        allAssets.append(asset)
      })
      DispatchQueue.main.async {
        if strongSelf.config?.invertUserLibraryOrder == true && strongSelf.album.isUserLibrary {
          allAssets.reverse()
        }
        strongSelf.assets = allAssets
      }
    }
    
  }
  
  // MARK: - Notifications
  
  @objc fileprivate func applicationDidBecomeActive(_ notification: Notification) {
    startFetchingAssets()
  }
  
  // MARK: - Layout
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    emptyView?.layoutMargins = UIEdgeInsets(top: topLayoutGuide.length + 20, left: 20, bottom: bottomLayoutGuide.length + 20, right: 20)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateCollectionViewLayout()
  }
  
  fileprivate func updateCollectionViewLayout() {
    var numberOfColumns: CGFloat = 4
    if view.frame.width >= 480 {
      numberOfColumns = 7
    }
    if let fixedNumberOfColumns = config?.numberOfColumns {
      numberOfColumns = CGFloat(fixedNumberOfColumns)
    }
    let spacing: CGFloat = 1
    let cellWidth = floor((view.frame.width - (spacing * numberOfColumns - 1)) / numberOfColumns)
    if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
      thumbnailImageSize = CGSize(width: cellWidth, height: cellWidth)
      flowLayout.itemSize = thumbnailImageSize
      flowLayout.minimumInteritemSpacing = spacing
      flowLayout.minimumLineSpacing = spacing
    }
    
  }
  
  // MARK: - Helpers
  
  fileprivate func asset(for indexPath: IndexPath) -> PHAsset? {
    guard let assets = assets else {
      return nil
    }
    if config?.invertUserLibraryOrder == true {
      if indexPath.row == 0 && showCameraButton {
        return nil
      }
    } else {
      if indexPath.row >= assets.count && showCameraButton {
        return nil
      }
    }
    
    let index = indexPath.row - (showCameraButton && config?.invertUserLibraryOrder == true ? 1 : 0)
    guard index < assets.count && index >= 0 else {
      return nil
    }
    return assets[index]
  }
  
  fileprivate func addAsset(_ asset: PHAsset) {
    if config?.invertUserLibraryOrder == true {
      assets?.insert(asset, at: 0)
    } else {
      assets?.append(asset)
    }
  }
  
  fileprivate func selectAsset(_ asset: PHAsset) {
    if !selectedAssets.contains(asset) {
      selectedAssets.append(asset)
    }
    if let index = assets?.firstIndex(of: asset) {
      let additionalIndex = config?.invertUserLibraryOrder == true && showCameraButton ? 1 : 0
      collectionView.selectItem(at: IndexPath(item: index + additionalIndex, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
    }
  }
  
  fileprivate func scrollToEnd() {
    guard let collectionView = collectionView else {
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
    return numberOfCells
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let asset = asset(for: indexPath) else {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCollectionViewCell.reuseIdentifier, for: indexPath) as? CameraCollectionViewCell else {
        fatalError("CameraCollectionViewCell should be registered")
      }
      return cell
    }
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.reuseIdentifier, for: indexPath) as? AssetCollectionViewCell else {
      fatalError("AssetCollectionViewCell should be registered")
    }
    cell.colors = config?.colors
    cell.imageSize = thumbnailImageSize
    cell.imageManager = thumbnailCachingManager
    cell.asset = asset
    cell.reloadContents()
    return cell
  }
  
}

// MARK: - UICollectionViewDelegate

extension AssetsGridViewController {
  
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard selectedAssets.count < config?.maxNumberOfSelections ?? Int.max else {
      UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: LocalizableStrings.accessibilityAlertSelectionLimitReached)
      return false
    }
    return true
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let asset = asset(for: indexPath) {
      if !selectedAssets.contains(asset) {
        guard selectedAssets.count < config?.maxNumberOfSelections ?? Int.max else {
          UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: LocalizableStrings.accessibilityAlertSelectionLimitReached)
          return
        }
        selectedAssets.append(asset)
        title = updateTitleBasedOnSelectedAssets()
        if let maxSelection = config?.maxNumberOfSelections, maxSelection == 1, config?.finishImmediatelyWithMaximumOfOne != false {
          finishPicking(with: selectedAssets)
        }
      }
    } else {
      let cameraController = UIImagePickerController()
      cameraController.sourceType = UIImagePickerController.SourceType.camera
      cameraController.delegate = self
      present(cameraController, animated: true, completion: nil)
      collectionView.deselectItem(at: indexPath, animated: true)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let asset = asset(for: indexPath), let index = selectedAssets.firstIndex(of: asset) else {
      return
    }
    selectedAssets.remove(at: index)
    title = updateTitleBasedOnSelectedAssets()
  }
  
}

// MARK: - UIScrollViewDelegate

extension AssetsGridViewController {
  
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    userScrolled = true
  }
  
}

// MARK: - AlbumsViewControllerDelegate

extension AssetsGridViewController: AlbumsViewControllerDelegate {
  
  func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection) {
    let titleView = navigationItem.titleView as? AlbumTitleView
    
    self.album = album
    let animator = UIViewPropertyAnimator(duration: 0.32, curve: .easeInOut) {
      titleView?.flipArrow = false
    }
    hideAlbumsViews(animator: animator)
    animator.addCompletion { [weak self] _ in
      self?.animatingAlbumView = false
    }
    animatingAlbumView = true
    animator.startAnimation()
  }
  
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetsGridViewController: PHPhotoLibraryChangeObserver {
  
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.async { [weak self] in
      self?.startFetchingAssets()
    }
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
    createAsset(from: image) { [weak self] (asset, error) in
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
    createAsset(from: image) { [weak self] (asset, error) in
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
