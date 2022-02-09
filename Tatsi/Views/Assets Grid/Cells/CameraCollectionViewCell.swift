//
//  CameraCollectionViewCell.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 30-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

final internal class CameraCollectionViewCell: UICollectionViewCell {
  
  static var reuseIdentifier: String {
    return "camera-cell"
  }
  
  lazy private var iconView: CameraIconView = {
    let iconView = CameraIconView()
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
    contentView.addSubview(iconView)
    contentView.backgroundColor = UIColor.lightGray
    
    accessibilityIdentifier = "tatsi.cell.camera"
    accessibilityLabel = LocalizableStrings.cameraButtonTitle
    accessibilityTraits = UIAccessibilityTraits.button
    isAccessibilityElement = true
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
}
