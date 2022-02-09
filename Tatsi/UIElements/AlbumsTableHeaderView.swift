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
      label.textColor = colors?.label ?? TatsiConfig.default.colors.label
      backgroundView?.backgroundColor = colors?.background ?? TatsiConfig.default.colors.background
    }
  }
  
  internal var title: String? {
    didSet {
      label.text = title
      accessibilityLabel = title
    }
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    contentView.addSubview(label)
    backgroundView = UIView()
    backgroundView?.backgroundColor = TatsiConfig.default.colors.background
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
      layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
}
