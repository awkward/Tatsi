//
//  AssetCollectionViewCell.swift
//  AWKImagePickerController
//
//  Created by Rens Verhoeven on 29-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AssetCollectionViewCell: UICollectionViewCell {
  
  static var reuseIdentifier: String {
    return "asset-cell"
  }
  
  internal var colors: TatsiColors?
  
  internal var imageSize: CGSize = CGSize(width: 100, height: 100) {
    didSet {
      guard imageSize != oldValue else {
        return
      }
      shouldUpdateImage = true
    }
  }
  
  internal var imageManager: PHImageManager?
  
  internal var asset: PHAsset? {
    didSet {
      metadataView.asset = asset
      guard asset != oldValue || imageView.image == nil else {
        return
      }
      accessibilityLabel = asset?.accessibilityLabel
      shouldUpdateImage = true
    }
  }
  
  private var currentRequest: PHImageRequestID?
  
  fileprivate var shouldUpdateImage = false
  
  lazy private var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    return imageView
  }()
  
  lazy private var metadataView: AssetMetadataView = {
    let view = AssetMetadataView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy private var selectedOverlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
    
    view.addSubview(iconView)
    view.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 3).isActive = true
    view.trailingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 3).isActive = true
    
    return view
  }()
  
  lazy private var iconView: SelectionIconView = {
    let iconView = SelectionIconView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    return iconView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    contentView.addSubview(imageView)
    contentView.addSubview(metadataView)
    contentView.addSubview(selectedOverlay)
    
    accessibilityIdentifier = "tatsi.cell.asset"
    accessibilityTraits = UIAccessibilityTraits.image
    isAccessibilityElement = true
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
      contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
      
      selectedOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
      selectedOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      contentView.bottomAnchor.constraint(equalTo: selectedOverlay.bottomAnchor),
      contentView.trailingAnchor.constraint(equalTo: selectedOverlay.trailingAnchor),
      
      metadataView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      contentView.bottomAnchor.constraint(equalTo: metadataView.bottomAnchor),
      contentView.rightAnchor.constraint(equalTo: metadataView.rightAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
  internal func reloadContents() {
    guard shouldUpdateImage else {
      return
    }
    shouldUpdateImage = false
    
    // Set the correct checkmark color
    iconView.tintColor = colors?.checkMark ?? colors?.link
    
    startLoadingImage()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.image = nil
    
    if let currentRequest = currentRequest {
      let imageManager = imageManager ?? PHImageManager.default()
      imageManager.cancelImageRequest(currentRequest)
    }
    
  }
  
  fileprivate func startLoadingImage() {
    imageView.image = nil
    guard let asset = asset else {
      return
    }
    let imageManager = imageManager ?? PHImageManager.default()
    
    let requestOptions = PHImageRequestOptions()
    requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
    requestOptions.isSynchronous = false
    
    imageView.contentMode = UIView.ContentMode.center
    imageView.image = nil
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      autoreleasepool {
        let scale = UIScreen.main.scale > 2 ? 2 : UIScreen.main.scale
        guard let targetSize = self?.imageSize.scaled(with: scale), self?.asset?.localIdentifier == asset.localIdentifier else {
          return
        }
        self?.currentRequest = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
          DispatchQueue.main.async {
            autoreleasepool {
              guard let image = image, self?.asset?.localIdentifier == asset.localIdentifier else {
                return
              }
              self?.imageView.contentMode = UIView.ContentMode.scaleAspectFill
              self?.imageView.image = image
            }
          }
        }
      }
    }
  }
  
  override var isSelected: Bool {
    didSet {
      selectedOverlay.isHidden = !isSelected
    }
  }
}
