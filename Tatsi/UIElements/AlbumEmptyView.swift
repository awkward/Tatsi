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
    let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 14
    return stackView
  }()
  
  public var colors: TatsiColors? {
    didSet {
      guard let colors = colors else { return }
      
      titleLabel.textColor = colors.label
      messageLabel.textColor = colors.secondaryLabel
    }
  }
  
  init(state: EmptyState = .noAssets) {
    self.state = state
    
    super.init(frame: CGRect())
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(stackView)
    
    titleLabel.text = state.title
    messageLabel.text = state.message
    messageLabel.isHidden = messageLabel.text == nil
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
      stackView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
      trailingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
      stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
}
