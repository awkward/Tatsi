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
    let stackView = UIStackView(arrangedSubviews: [titleLabel, countLabel])
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  var album: PHAssetCollection? {
    didSet {
      albumChanged = album != oldValue
    }
  }
  
  var colors: TatsiColors? {
    didSet {
      backgroundColor = colors?.background ?? TatsiConfig.default.colors.background
      titleLabel.textColor = colors?.label ?? TatsiConfig.default.colors.label
      countLabel.textColor = colors?.secondaryLabel ?? TatsiConfig.default.colors.secondaryLabel
    }
  }
  
  private var albumChanged = false
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    contentView.addSubview(albumImageView)
    contentView.addSubview(labelsStackView)
    
    accessibilityIdentifier = "tatsi.cell.album"
    
    accessoryType = .disclosureIndicator
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    
    let constraints = [
      albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      layoutMarginsGuide.bottomAnchor.constraint(equalTo: albumImageView.bottomAnchor),
      
      labelsStackView.centerYAnchor.constraint(equalTo: albumImageView.centerYAnchor),
      labelsStackView.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 16),
      layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: labelsStackView.trailingAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
  func reloadContents(with options: PHFetchOptions?) {
    guard albumChanged else {
      return
    }
    albumChanged = false
    
    titleLabel.text = album?.localizedTitle
    
    let fetchOptions = options
    let count = album?.estimatedAssetCount ?? 0
    
    //First we set a temporary count that might not represent the actual count
    if count != NSNotFound {
      countLabel.text = AlbumTableViewCell.numberFormatter.string(from: NSNumber(value: count))
    } else {
      countLabel.text = "0"
    }
    
    accessibilityLabel = album?.localizedTitle
    accessibilityValue = String(format: LocalizableStrings.accessibilityAlbumImagesCount, locale: nil, arguments: [count])
    
    album?.fetchNumberOfItems(for: fetchOptions, completionHandler: { [weak self] (count, collection) in
      guard let strongSelf = self, collection == strongSelf.album else {
        return
      }
      strongSelf.countLabel.text = AlbumTableViewCell.numberFormatter.string(from: NSNumber(value: count))
      strongSelf.accessibilityValue = String(format: LocalizableStrings.accessibilityAlbumImagesCount, locale: nil, arguments: [count])
    })
    
    
    albumImageView.imageView.contentMode = UIView.ContentMode.center
    albumImageView.image = nil
    
    guard let album = self.album, !album.isRecentlyDeletedCollection && album.assetCollectionSubtype != .smartAlbumAllHidden else {
      return
    }
    album.loadPreviewImage(albumImageView.preferredImageSize, fetchOptions: fetchOptions, completionHandler: { [weak self] (image, _) in
      if let image = image {
        self?.albumImageView.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self?.albumImageView.image = image
      }
      
    })
  }
  
}
