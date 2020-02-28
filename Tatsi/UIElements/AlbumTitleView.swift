//
//  AlbumTitleView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/12/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import UIKit

/// The title view that is used in the case that "singleViewMode" is enabled. This title view will display the title of the Album, but also act as a control.
final class AlbumTitleView: UIControl {

    /// The title that should be displayed. This can be the name of the album.
    var title: String? {
        didSet {
            self.accessibilityLabel = self.title
            self.titleLabel.text = self.title
        }
    }
    
    /// If the arrow should flip 180 degrees. Can be used in an animation block.
    var flipArrow: Bool = false {
        didSet {
            guard self.flipArrow != oldValue else {
                return
            }
            let radians: CGFloat = 180 * (CGFloat.pi / 180)
            self.arrowIconView.transform = self.flipArrow ? CGAffineTransform(rotationAngle: radians) : .identity
            self.accessibilityHint = self.flipArrow ? LocalizableStrings.accessibilityActivateToHideAlbumList : LocalizableStrings.accessibilityActivateToShowAlbumList
        }
    }
    
    lazy fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = TatsiConfig.default.colors.label
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.isUserInteractionEnabled = false
        label.isAccessibilityElement = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy fileprivate var arrowIconView: ChangeAlbumArrowView = {
        let imageView = ChangeAlbumArrowView()
        imageView.isUserInteractionEnabled = false
        imageView.isAccessibilityElement = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
   lazy fileprivate var directionLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.tapToChangeAlbumTitle
        label.textColor = TatsiConfig.default.colors.secondaryLabel
        label.font = UIFont.systemFont(ofSize: 10)
        label.isUserInteractionEnabled = false
        label.isAccessibilityElement = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var colors: TatsiColors? {
        didSet {
            guard let colors = colors else { return }
            
            self.titleLabel.textColor = colors.label
            self.directionLabel.textColor = colors.secondaryLabel
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.arrowIconView)
        self.addSubview(self.directionLabel)
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraits.button
        self.accessibilityHint = LocalizableStrings.accessibilityActivateToShowAlbumList
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Note: Because this is a view that is placed inside a UINavigationBar auto layout can't be used. It can only be used when the target is iOS 11 or higher.
        
        let arrowIconOffset = CGPoint(x: 3, y: 2)
        
        var titleLabelSize = self.titleLabel.intrinsicContentSize
        titleLabelSize.width = min(titleLabelSize.width, bounds.width)
        var titleLabelOrigin = CGPoint()
        
        var arrowIconViewSize = self.arrowIconView.intrinsicContentSize
        arrowIconViewSize.width = min(arrowIconViewSize.width, bounds.width)
        var arrowIconViewOrigin = CGPoint()
        
        var directionLabelSize = self.directionLabel.intrinsicContentSize
        directionLabelSize.width = min(directionLabelSize.width, bounds.width)
        var directionLabelOrigin = CGPoint()
        
        titleLabelOrigin.x = (self.bounds.width - (titleLabelSize.width + arrowIconViewSize.width + arrowIconOffset.x)) / 2
        arrowIconViewOrigin.x = titleLabelOrigin.x + titleLabelSize.width + arrowIconOffset.x
        directionLabelOrigin.x = (self.bounds.width - directionLabelSize.width) / 2
        
        titleLabelOrigin.y = (self.bounds.height - (titleLabelSize.height + directionLabelSize.height)) / 2
        arrowIconViewOrigin.y = titleLabelOrigin.y + ((titleLabelSize.height - arrowIconViewSize.height) / 2) + arrowIconOffset.y
        directionLabelOrigin.y = titleLabelOrigin.y + titleLabelSize.height
        
        self.titleLabel.frame = CGRect(origin: titleLabelOrigin, size: titleLabelSize)
        self.arrowIconView.frame = CGRect(origin: arrowIconViewOrigin, size: arrowIconViewSize)
        self.directionLabel.frame = CGRect(origin: directionLabelOrigin, size: directionLabelSize)
    }
    
}
