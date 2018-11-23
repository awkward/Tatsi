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
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(self.iconView)
        self.contentView.backgroundColor = UIColor.lightGray
        
        self.accessibilityIdentifier = "tatsi.cell.camera"
        self.accessibilityLabel = LocalizableStrings.cameraButtonTitle
        self.accessibilityTraits = UIAccessibilityTraits.button
        self.isAccessibilityElement = true
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.iconView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.iconView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
