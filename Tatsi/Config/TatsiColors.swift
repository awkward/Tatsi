//
//  TatsiColors.swift
//  Tatsi
//
//  Created by Antoine van der Lee on 25/10/2019.
//  Copyright © 2019 awkward. All rights reserved.
//

import UIKit

/// Defines colors that will be applied to the Tatsi elements.
public protocol TatsiColors {
    /// Used as the background color for all the pages.
    var background: UIColor { get }

    /// This is the primary action color used for tinting buttons like the Cancel and Done buttons.
    var link: UIColor { get }

    /// The main color for text labels.
    var label: UIColor { get }

    /// The color for secondary labels like descriptions.
    var secondaryLabel: UIColor { get }
    
    /// The color for the checkmark when selecting an image
    var checkMark: UIColor? { get }
}

extension TatsiColors {
    
    public var checkMark: UIColor? {
        // Supply a default option to keep compatibility.
        return nil
    }
    
}

/// Defines the default colors for Tatsi.
public struct TatsiDefaultColors: TatsiColors {
    
    public var background: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }()

    public var link: UIColor = {
        if #available(iOS 13.0, *) {
            return .link
        } else {
            return UIColor(red: 0.33, green: 0.63, blue: 0.97, alpha: 1.00)
        }
    }()

    public let label: UIColor = {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }()

    public let secondaryLabel: UIColor = {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .gray
        }
    }()
    
}
