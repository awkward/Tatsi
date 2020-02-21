//
//  AlbumEmptyView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

final internal class AlbumEmptyView: UIView {
    
    enum EmptyState {
        case loading
        case noAssets
        
        var title: String {
            switch self {
            case .noAssets:
                return LocalizableStrings.emptyAlbumTitle
            case .loading:
                return LocalizableStrings.albumLoading
            }
        }
        
        var message: String? {
            switch self {
            case .noAssets:
                return LocalizableStrings.emptyAlbumMessage
            default:
                return nil
            }
        }
    }
    
    private let state: EmptyState

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .title2).withSize(26)
        label.textColor = TatsiConfig.default.colors.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = TatsiConfig.default.colors.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.messageLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 14
        return stackView
    }()

    public var colors: TatsiColors? {
        didSet {
            guard let colors = colors else { return }

            self.titleLabel.textColor = colors.label
            self.messageLabel.textColor = colors.secondaryLabel
        }
    }
    
    init(state: EmptyState = .noAssets) {
        self.state = state
        
        super.init(frame: CGRect())
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self.stackView)
        
        self.titleLabel.text = self.state.title
        self.messageLabel.text = self.state.message
        self.messageLabel.isHidden = self.messageLabel.text == nil
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.leadingAnchor),
            self.trailingAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.trailingAnchor),
            self.stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
