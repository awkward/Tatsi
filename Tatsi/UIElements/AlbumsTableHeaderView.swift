//
//  AlbumsTableHeaderView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 07/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

final internal class AlbumsTableHeaderView: UITableViewHeaderFooterView {
    
    class internal var reuseIdentifier: String {
        return "albums-header"
    }

    class private var font: UIFont {
        return UIFont.preferredFont(forTextStyle: .title3)
    }
    
    static internal var height: CGFloat {
        return AlbumsTableHeaderView.font.pointSize + 22
    }
    
    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = AlbumsTableHeaderView.font
        label.textColor = TatsiConfig.default.colors.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    internal var colors: TatsiColors? {
        didSet {
            self.label.textColor = self.colors?.label ?? TatsiConfig.default.colors.label
            self.backgroundView?.backgroundColor = self.colors?.background ?? TatsiConfig.default.colors.background
        }
    }

    internal var title: String? {
        didSet {
            self.label.text = self.title
            self.accessibilityLabel = self.title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(self.label)
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = TatsiConfig.default.colors.background

        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.bottomAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 4),
            self.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.label.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
