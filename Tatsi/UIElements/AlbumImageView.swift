//
//  AlbumView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 29-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

final internal class AlbumImageView: UIView {
  
  var linesColor = UIColor.black {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var placeholderColor = UIColor(red: 226 / 255, green: 225 / 255, blue: 230 / 255, alpha: 1) {
    didSet {
      imageView.backgroundColor = placeholderColor
    }
  }
  
  var image: UIImage? {
    set {
      imageView.image = newValue
    }
    get {
      return imageView.image
    }
  }
  
  var preferredImageSize: CGSize {
    return CGSize(width: 70, height: 70)
  }
  
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.isOpaque = true
    imageView.backgroundColor = placeholderColor
    imageView.contentMode = UIView.ContentMode.scaleAspectFill
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  func setupView() {
    addSubview(self.imageView)
  }
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    // Drawing code
    let firstLinePath = UIBezierPath(rect: CGRect(x: 7, y: 0, width: rect.width - ( 7 * 2 ), height: 1 / UIScreen.main.scale))
    linesColor.withAlphaComponent(0.4).setFill()
    firstLinePath.fill()
    
    let secondLinePath = UIBezierPath(rect: CGRect(x: 4, y: 2, width: rect.width - ( 4 * 2 ), height: 1 / UIScreen.main.scale))
    linesColor.withAlphaComponent(0.6).setFill()
    secondLinePath.fill()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 70, height: 74)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.frame = CGRect(x: 0, y: 4, width: bounds.width, height: bounds.height - 4)
  }
  
}
