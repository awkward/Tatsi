//
//  ChangeAlbumArrowView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/12/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import UIKit

/// The arrow that is displayed in AlbumTitleView next to the title.
internal class ChangeAlbumArrowView: UIView {
    
    var arrowColor = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(arrowColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.arrowColor = arrowColor
    }
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: 5, y: 0))
        bezierPath.addLine(to: CGPoint(x: 2.5, y: 3.5))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        self.arrowColor.setFill()
        bezierPath.fill()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 5, height: 4)
    }
    
}
