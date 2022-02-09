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
  
  @IBOutlet private var rememberCollectionSwitch: UISwitch!
  
  // The last collection the user has selected. Set from the picker's delegate method.
  // It is not recommended to PHAssetCollection in persitant storage. If you do, check if the album is still available before showing the picker.
  private var lastSelectedCollection: PHAssetCollection?
  
  // If the rememberCollectioSwitch is turned on we return the last known collection, if available.
  private var firstView: TatsiConfig.StartView {
    if self.rememberCollectionSwitch.isOn, let lastCollection = self.lastSelectedCollection {
      return .album(lastCollection)
    } else {
      return .userLibrary
    }
  }
  
  // Colors picked from iOS 13 Dark Mode
  struct DarkModeColors: TatsiColors {
    var background: UIColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 255/255)
    var link: UIColor = UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 255/255)
    var label: UIColor = UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 255/255)
    var secondaryLabel: UIColor = UIColor(red: 152/255, green: 151/255, blue: 159/255, alpha: 255/255)
    var checkMark: UIColor? = .red
  }
  
  
  // Shows the iOS built-in UIImagePickerController.
  @IBAction private func showUIKitPicker(_ sender: Any) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  // Shows the Tatsi picker controller with a look similar to UIImagePickerController.
  @IBAction private func showTatsiPicker(_ sender: Any) {
    var config = TatsiConfig.default
    config.showCameraOption = true
    config.supportedMediaTypes = [.video, .image]
    config.firstView = self.firstView
    config.maxNumberOfSelections = 5
    
    let pickerViewController = TatsiPickerViewController(config: config)
    pickerViewController.pickerDelegate = self
    self.present(pickerViewController, animated: true, completion: nil)
  }
  
  // Shows the Tatsi picker controller, but with the album being selectable from the top, instead of from the previous screen.
  @IBAction private func showSingleViewTatsiPicker(_ sender: Any) {
    var config = TatsiConfig.default
    config.singleViewMode = true
    config.showCameraOption = true
    config.supportedMediaTypes = [.video, .image]
    config.firstView = self.firstView
    let pickerViewController = TatsiPickerViewController(config: config)
    pickerViewController.pickerDelegate = self
    self.present(pickerViewController, animated: true, completion: nil)
  }
  
  // Shows the Tatsi picker controller with custom colors.
  @IBAction private func showTatsiPickerWithCustomColors(_ sender: Any) {
    var config = TatsiConfig.default
    config.singleViewMode = true
    config.showCameraOption = true
    config.supportedMediaTypes = [.video, .image]
    config.firstView = self.firstView
    config.maxNumberOfSelections = 2
    config.colors = DarkModeColors()
    config.preferredStatusBarStyle = .lightContent
    
    let pickerViewController = TatsiPickerViewController(config: config)
    pickerViewController.pickerDelegate = self
    pickerViewController.modalPresentationStyle = .fullScreen
    self.present(pickerViewController, animated: true, completion: nil)
  }
  
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
  }
  
}

extension ViewController: TatsiPickerViewControllerDelegate {
  
  func pickerViewController(_ pickerViewController: TatsiPickerViewController, didSelectCollection collection: PHAssetCollection) {
    self.lastSelectedCollection = collection
    print("User selected collection: \(collection)")
  }
  
  func pickerViewController(_ pickerViewController: TatsiPickerViewController, didPickAssets assets: [PHAsset]) {
    pickerViewController.dismiss(animated: true, completion: nil)
    print("Picked assets: \(assets)")
  }
  
}
