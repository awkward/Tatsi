//
//  SelectionIconView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 29-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

final internal class SelectionIconView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isOpaque = false
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.drawIcon()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 24, height: 24)
    }
    
    private func drawIcon() {
        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        //// Color Declarations
        let shadowTint = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.25)
        let outline = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //// Background Drawing
        let backgroundPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 24, height: 24))
        context.saveGState()
        context.setShadow(offset: CGSize(), blur: 5, color: shadowTint.cgColor)
        outline.setFill()
        backgroundPath.fill()
        context.restoreGState()
        
        //// Fill Drawing
        let fillPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: 22, height: 22))
        self.tintColor.setFill()
        fillPath.fill()
        
        //// Checkmark Drawing
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: 9.53, y: 17.03))
        checkmarkPath.addLine(to: CGPoint(x: 5.37, y: 12.87))
        checkmarkPath.addLine(to: CGPoint(x: 6.37, y: 11.87))
        checkmarkPath.addLine(to: CGPoint(x: 9.5, y: 15))
        checkmarkPath.addLine(to: CGPoint(x: 17.16, y: 7.34))
        checkmarkPath.addLine(to: CGPoint(x: 18.19, y: 8.37))
        checkmarkPath.addLine(to: CGPoint(x: 9.53, y: 17.03))
        checkmarkPath.close()
        checkmarkPath.usesEvenOddFillRule = true
        
        outline.setFill()
        checkmarkPath.fill()
    }

}
