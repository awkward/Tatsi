//
//  TatsiTestCase.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import XCTest
@testable import Tatsi
import Photos

class TatsiTestCase: XCTestCase {
  
  var rootViewController: UIViewController {
    return UIApplication.shared.windows.first!.rootViewController!
  }
  
  var userLibrary: PHAssetCollection {
    guard let userLibrary = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else {
      XCTFail("There should be a user library")
      fatalError("There should be a user library")
    }
    return userLibrary
  }
  
  private var addedAssetIdentifiers = [String]()
  
  override func setUp() {
    super.setUp()
    
    self.addedAssetIdentifiers = [String]()
    
    // Whenever photo acces is requested, accept it.
    self.addUIInterruptionMonitor(withDescription: "Photos Access Alert") { (alert) -> Bool in
      if alert.buttons["OK"].exists {
        alert.buttons["OK"].tap()
      } else if alert.buttons["Add"].exists {
        alert.buttons["Add"].tap()
      } else if alert.buttons["Allow"].exists {
        alert.buttons["Allow"].tap()
      }  else if alert.buttons["Delete"].exists {
        alert.buttons["Delete"].tap()
      }
      return true
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    let expectation = self.expectation(description: "Wait for the dismiss")
    self.rootViewController.dismiss(animated: false, completion: nil)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      expectation.fulfill()
    }
    
    self.wait(for: [expectation], timeout: 5)
    
    super.tearDown()
  }
  
  let bundle = Bundle(for: TatsiTestCase.self)
  
  @discardableResult func presentPicker(with config: TatsiConfig) -> TatsiPickerViewController {
    let expectation = self.expectation(description: "The picker should be displayed")
    let pickerViewController = TatsiPickerViewController(config: config)
    self.rootViewController.present(pickerViewController, animated: true) { 
      expectation.fulfill()
    }
    
    self.wait(for: [expectation], timeout: 5)
    return pickerViewController
  }
  
  @discardableResult func addImages(_ images: [UIImage], collection: PHAssetCollection? = nil) -> [PHAsset]? {
    do {
      var assetIdentifiers = [String]()
      try PHPhotoLibrary.shared().performChangesAndWait {
        images.forEach({ (image) in
          let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
          guard let identifier = request.placeholderForCreatedAsset?.localIdentifier else {
            return
          }
          assetIdentifiers.append(identifier)
        })
      }
      self.addedAssetIdentifiers.append(contentsOf: assetIdentifiers)
      let result = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
      var assets = [PHAsset]()
      result.enumerateObjects({ (asset, _, _) in
        assets.append(asset)
      })
      if let collection = collection {
        try PHPhotoLibrary.shared().performChangesAndWait {
          PHAssetCollectionChangeRequest(for: collection)?.addAssets(result)
        }
      }
      return assets
    } catch {
      XCTFail("Failed to add images")
      return nil
    }
  }
  
  @discardableResult func createCollection(name: String) -> PHAssetCollection? {
    do {
      var collectionIdentifier: String?
      try PHPhotoLibrary.shared().performChangesAndWait {
        let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        collectionIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
      }
      guard let localIdentifier = collectionIdentifier else {
        return nil
      }
      var collection: PHAssetCollection?
      let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
      result.enumerateObjects({ (assetCollection, _, _) in
        collection = assetCollection
      })
      return collection
    } catch {
      XCTFail("Failed to create collection")
      return nil
    }
  }
  
  private func removeAddedAssets() {
    guard !self.addedAssetIdentifiers.isEmpty else {
      return
    }
    let result = PHAsset.fetchAssets(withLocalIdentifiers: self.addedAssetIdentifiers, options: nil)
    try? PHPhotoLibrary.shared().performChangesAndWait {
      PHAssetChangeRequest.deleteAssets(result)
    }
    self.addedAssetIdentifiers = [String]()
  }
  
}
