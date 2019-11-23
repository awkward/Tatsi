//
//  AlbumTableViewCell.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 27-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AlbumTableViewCell: UITableViewCell {
    
    fileprivate static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static var reuseIdentifier: String {
        return "album-cell"
    }
    
    lazy private var albumImageView: AlbumImageView = {
        let imageView = AlbumImageView()
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = TatsiConfig.default.colors.label
        return label
    }()
    
    lazy private  var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.textColor = TatsiConfig.default.colors.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.countLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var album: PHAssetCollection? {
        didSet {
            self.albumChanged = self.album != oldValue
        }
    }

    var colors: TatsiColors? {
        didSet {
            self.backgroundColor = self.colors?.background ?? TatsiConfig.default.colors.background
            self.titleLabel.textColor = self.colors?.label ?? TatsiConfig.default.colors.label
            self.countLabel.textColor = self.colors?.secondaryLabel ?? TatsiConfig.default.colors.secondaryLabel
        }
    }
    
    private var albumChanged = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(self.albumImageView)
        self.contentView.addSubview(self.labelsStackView)
        
        self.accessibilityIdentifier = "tatsi.cell.album"
        
        self.accessoryType = .disclosureIndicator
        
        self.setupConstraints()
    }

    private func setupConstraints() {
        
        let constraints = [
            self.albumImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.layoutMarginsGuide.bottomAnchor.constraint(equalTo: self.albumImageView.bottomAnchor),
            
            self.labelsStackView.centerYAnchor.constraint(equalTo: self.albumImageView.centerYAnchor),
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.albumImageView.trailingAnchor, constant: 16),
            self.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.labelsStackView.trailingAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func reloadContents(with options: PHFetchOptions?) {
        guard self.albumChanged else {
            return
        }
        self.albumChanged = false
        
        self.titleLabel.text = self.album?.localizedTitle
        
        let fetchOptions = options
        let count = self.album?.estimatedAssetCount ?? 0
        
        //First we set a temporary count that might not represent the actual count
        if count != NSNotFound {
            self.countLabel.text = AlbumTableViewCell.numberFormatter.string(from: NSNumber(value: count))
        } else {
            self.countLabel.text = "0"
        }
        
        self.accessibilityLabel = self.album?.localizedTitle
        self.accessibilityValue = String(format: LocalizableStrings.accessibilityAlbumImagesCount, locale: nil, arguments: [count])
        
        self.album?.fetchNumberOfItems(for: fetchOptions, completionHandler: { [weak self] (count, collection) in
            guard let strongSelf = self, collection == strongSelf.album else {
                return
            }
            self?.countLabel.text = AlbumTableViewCell.numberFormatter.string(from: NSNumber(value: count))
            self?.accessibilityValue = String(format: LocalizableStrings.accessibilityAlbumImagesCount, locale: nil, arguments: [count])
        })

        
        self.albumImageView.imageView.contentMode = UIView.ContentMode.center
        self.albumImageView.image = nil
        
        guard let album = self.album, !album.isRecentlyDeletedCollection && album.assetCollectionSubtype != .smartAlbumAllHidden else {
            return
        }
        album.loadPreviewImage(self.albumImageView.preferredImageSize, fetchOptions: fetchOptions, completionHandler: { [weak self] (image, _) in
            if let image = image {
                self?.albumImageView.imageView.contentMode = UIView.ContentMode.scaleAspectFill
                self?.albumImageView.image = image
            }
            
        })
    }
    
}
