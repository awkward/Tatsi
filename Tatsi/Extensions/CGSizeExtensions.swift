//
//  CGSizeExtensions.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit

extension CGSize {
    
    internal func scaled(with scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
