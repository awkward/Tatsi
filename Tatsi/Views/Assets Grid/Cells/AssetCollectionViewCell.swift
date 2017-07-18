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
    
    internal var imageSize: CGSize = CGSize(width: 100, height: 100) {
        didSet {
            guard self.imageSize != oldValue else {
                return
            }
            self.shouldUpdateImage = true
        }
    }
    
    internal var imageManager: PHImageManager?
    
    internal var asset: PHAsset? {
        didSet {
            self.metadataView.asset = self.asset
            guard self.asset != oldValue else {
                return
            }
            self.accessibilityLabel = asset?.accessibilityLabel
            self.shouldUpdateImage = true
        }
    }
    
    private var currentRequest: PHImageRequestID?
    
    fileprivate var shouldUpdateImage = false
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        
        let iconView = SelectionIconView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconView)
        view.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 3).isActive = true
        view.trailingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 3).isActive = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.metadataView)
        self.contentView.addSubview(self.selectedOverlay)
        
        self.accessibilityIdentifier = "tatsi.cell.asset"
        self.accessibilityTraits = UIAccessibilityTraitImage
        self.isAccessibilityElement = true
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            
            self.selectedOverlay.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.selectedOverlay.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.selectedOverlay.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.selectedOverlay.trailingAnchor),
            
            self.metadataView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.metadataView.bottomAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.metadataView.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    internal func reloadContents() {
        guard self.shouldUpdateImage else {
            return
        }
        self.shouldUpdateImage = false
        if let currentRequest = self.currentRequest {
            var imageManager = PHImageManager.default()
            if let customImageManager = self.imageManager {
                imageManager = customImageManager
            }
            imageManager.cancelImageRequest(currentRequest)
        }
        self.startLoadingImage()
    }
    
    fileprivate func startLoadingImage() {
        self.imageView.image = nil
        guard let asset = self.asset else {
            return
        }
        var imageManager = PHImageManager.default()
        if let customImageManager = self.imageManager {
            imageManager = customImageManager
        }
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.isSynchronous = false
        
        self.imageView.contentMode = UIViewContentMode.center
        self.imageView.image = nil
        DispatchQueue.global(qos: .userInteractive).async {
            self.currentRequest = imageManager.requestImage(for: asset, targetSize: self.imageSize.scaled(with: UIScreen.main.scale), contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
                DispatchQueue.main.async {
                    if let image = image {
                        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
                        self.imageView.image = image
                    }
                }
            }
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            self.selectedOverlay.isHidden = !self.isSelected
        }
    }
}
