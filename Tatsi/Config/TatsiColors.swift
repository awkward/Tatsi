//
//  TatsiColors.swift
//  Tatsi
//
//  Created by Antoine van der Lee on 25/10/2019.
//  Copyright © 2019 awkward. All rights reserved.
//

import Foundation

/// Defines colors that will be applied to the Tatsi elements.
public protocol TatsiColors {
    var background: UIColor { get }
    var secondaryBackground: UIColor { get }
    var tint: UIColor { get }
    var label: UIColor { get }
    var secondaryLabel: UIColor { get }
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

    public var secondaryBackground: UIColor = {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return .white
        }
    }()

    public var tint: UIColor = {
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
