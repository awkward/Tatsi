//
//  AssetTypeIconView.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 09/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AssetTypeIconView: UIView {
    
    enum Icon {
        
        case favorite
        case selfPortrait
        case panorama
        case video
        case highFrameRate
        case timeLapse
        
        init?(subtype: PHAssetMediaSubtype) {
            switch subtype {
            case PHAssetMediaSubtype.photoPanorama:
                self = .panorama
            case PHAssetMediaSubtype.videoTimelapse:
                self = .timeLapse
            case PHAssetMediaSubtype.videoHighFrameRate:
                self = .highFrameRate
            default:
                return nil
            }
        }
        
    }
    
    var color: UIColor = .white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var icon: Icon = .favorite {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    init(icon: Icon = .favorite) {
        super.init(frame: CGRect())
        
        self.icon = icon
        
        self.isOpaque = false
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        switch self.icon {
        case .favorite:
            TypeIcons.drawFavoriteIcon(with: self.color, in: rect)
        case .selfPortrait:
            TypeIcons.drawSelfPortraitIcon(with: self.color, in: rect)
        case .panorama:
            TypeIcons.drawPanoramaIcon(with: self.color, in: rect)
        case .video:
            TypeIcons.drawVideoIcon(with: self.color, in: rect)
        case .highFrameRate:
            TypeIcons.drawHighFrameRateIcon(with: self.color, in: rect)
        case .timeLapse:
            TypeIcons.drawTimeLapseIcon(with: self.color, in: rect)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 16, height: 16)
    }
 
}
