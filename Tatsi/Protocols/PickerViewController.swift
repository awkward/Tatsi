//
//  AssetsPickerViewController.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import Foundation
import Photos
import UIKit

protocol PickerViewController {
    
    var pickerViewController: TatsiPickerViewController? { get }
    
    var config: TatsiConfig? { get }
    
    func finishPicking(with assets: [PHAsset])
    
    func cancelPicking()
    
}

extension PickerViewController where Self: UIViewController {
    
    var pickerViewController: TatsiPickerViewController? {
        return self.navigationController as? TatsiPickerViewController
    }
    
    var config: TatsiConfig? {
        return self.pickerViewController?.config
    }
    
    var delegate: TatsiPickerViewControllerDelegate? {
        return self.pickerViewController?.pickerDelegate
    }
    
    func didSelectCollection(_ collection: PHAssetCollection) {
        guard let viewController = self.pickerViewController else {
            return
        }
        self.delegate?.pickerViewController(viewController, didSelectCollection: collection)
    }
    
    func finishPicking(with assets: [PHAsset]) {
        guard let viewController = self.pickerViewController else {
            return
        }
        self.delegate?.pickerViewController(viewController, didPickAssets: assets)
    }
    
    func cancelPicking() {
        guard let viewController = self.pickerViewController else {
            return
        }
        self.delegate?.pickerViewControllerDidCancel(viewController)
    }
    
}
