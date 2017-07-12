//
//  TatsiPickerViewControllerDelegate.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 27-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

public protocol TatsiPickerViewControllerDelegate: class {

    func pickerViewController(_ pickerViewController: TatsiPickerViewController, didPickAssets assets: [PHAsset])
    
    func pickerViewControllerDidCancel(_ pickerViewController: TatsiPickerViewController)
}

extension TatsiPickerViewControllerDelegate {
    
    public func pickerViewControllerDidCancel(_ pickerViewController: TatsiPickerViewController) {
        pickerViewController.dismiss(animated: true, completion: nil)
    }
    
}
