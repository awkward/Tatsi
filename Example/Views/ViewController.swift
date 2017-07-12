//
//  ViewController.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 05/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Tatsi
import Photos

final class ViewController: UIViewController {
    
    @IBAction private func showUIImagePicker(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func showPicker(_ sender: Any) {
        var config = TatsiConfig.default
        config.showCameraOption = true
        config.supportedMediaTypes = [.video, .image]
        config.firstView = .userLibrary
        config.maxNumberOfSelections = 2
        
        let pickerViewController = TatsiPickerViewController(config: config)
        pickerViewController.pickerDelegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: TatsiPickerViewControllerDelegate {
    
    func pickerViewController(_ pickerViewController: TatsiPickerViewController, didPickAssets assets: [PHAsset]) {
        pickerViewController.dismiss(animated: true, completion: nil)
        print("Assets \(assets)")
    }
    
}
