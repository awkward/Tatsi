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
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private  var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        label.textColor = UIColor.gray
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
    
    private var albumChanged = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        
        self.album?.fetchNumberOfItems(for: fetchOptions, completionHandler: { [weak self] (count, collection) in
            guard let strongSelf = self, collection == strongSelf.album else {
                return
            }
            self?.countLabel.text = AlbumTableViewCell.numberFormatter.string(from: NSNumber(value: count))
        })

        
        self.albumImageView.imageView.contentMode = UIViewContentMode.center
        self.albumImageView.image = nil
        
        guard let album = self.album, !album.isRecentlyDeletedCollection && album.assetCollectionSubtype != .smartAlbumAllHidden else {
            return
        }
        album.loadPreviewImage(self.albumImageView.preferredImageSize, fetchOptions: fetchOptions, completionHandler: { [weak self] (image, _) in
            if let image = image {
                self?.albumImageView.imageView.contentMode = UIViewContentMode.scaleAspectFill
                self?.albumImageView.image = image
            }
            
        })
    }
    
}
