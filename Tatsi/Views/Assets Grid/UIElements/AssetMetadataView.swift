//
//  AssetMetadataView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 09/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AssetMetadataView: UIView {
  
  lazy private var iconView: AssetTypeIconView = {
    let view = AssetTypeIconView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy private var timeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  /// If the duration should be shown when the asset contains a duration.
  var showDuration = true
  
  /// The asset the meta data should be displayed for.
  var asset: PHAsset? {
    didSet {
      guard let asset = asset else {
        isHidden = true
        return
      }
      timeLabel.isHidden = asset.duration <= 0 || !showDuration
      timeLabel.text = string(from: asset.duration)
      
      iconView.isHidden = !asset.isFavorite
      iconView.icon = .favorite
      
      isHidden = timeLabel.isHidden && iconView.isHidden
    }
  }
  
  init() {
    super.init(frame: CGRect())
    
    isOpaque = false
    backgroundColor = .clear
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(iconView)
    addSubview(timeLabel)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
      iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
      
      timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: iconView.trailingAnchor, constant: 8),
      trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 6)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
  override func draw(_ rect: CGRect) {
    //// Color Declarations
    let gradientColor = UIColor.black
    
    //// Gradient Declarations
    let colors = [gradientColor.withAlphaComponent(0).cgColor, gradientColor.cgColor] as CFArray
    
    //// General Declarations
    guard let context = UIGraphicsGetCurrentContext(), let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else {
      return
    }
    
    //// Rectangle Drawing
    let rectangleRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
    let rectanglePath = UIBezierPath(rect: rectangleRect)
    context.saveGState()
    rectanglePath.addClip()
    context.drawLinearGradient(gradient, start: CGPoint(x: rectangleRect.midX, y: rectangleRect.minY), end: CGPoint(x: rectangleRect.midX, y: rectangleRect.maxY), options: [])
    context.restoreGState()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 25)
  }
  
  private func string(from interval: TimeInterval) -> String? {
    guard interval > 0 else {
      return nil
    }
    let ti = NSInteger(interval)
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    if hours > 0 {
      return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    } else {
      return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
  }
  
}
