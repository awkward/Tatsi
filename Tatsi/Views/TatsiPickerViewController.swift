//
//  TatsiPickerViewController.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final public class TatsiPickerViewController: UINavigationController {
    
    // MARK: - Public properties

    public let config: TatsiConfig
    
    public weak var pickerDelegate: TatsiPickerViewControllerDelegate?

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return self.config.preferredStatusBarStyle
    }
    
    // MARK: - Initializers
    
    public init(config: TatsiConfig = TatsiConfig.default) {
        self.config = config
        super.init(nibName: nil, bundle: nil)

        navigationBar.barTintColor = config.colors.background
        navigationBar.tintColor = config.colors.link

        self.setIntialViewController()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    internal func setIntialViewController() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            //Authorized, show the album view or the album detail view.
            var album: PHAssetCollection?
            let userLibrary = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject
            switch self.config.firstView {
            case .userLibrary:
                 album = userLibrary
            case .album(let collection):
                album = collection
            default:
                break
            }
            if let initialAlbum = album ?? userLibrary, self.config.singleViewMode {
                self.viewControllers = [AssetsGridViewController(album: initialAlbum)]
            } else {
                self.showAlbumViewController(with: album)
            }
            
        case .denied, .notDetermined, .restricted:
            // Not authorized, show the view to give access
            self.viewControllers = [AuthorizationViewController()]
        @unknown default:
          assertionFailure("Unknown authorization status detected.")
      }
    }
    
    private func showAlbumViewController(with collection: PHAssetCollection?) {
        if let collection = collection {
            self.viewControllers = [AlbumsViewController(), AssetsGridViewController(album: collection)]
        } else {
            self.viewControllers = [AlbumsViewController()]
        }
    }
    
    internal func customCancelButtonItem() -> UIBarButtonItem? {
        return self.pickerDelegate?.cancelBarButtonItem(for: self)
    }
    
    internal func customDoneButtonItem() -> UIBarButtonItem? {
        return self.pickerDelegate?.doneBarButtonItem(for: self)
    }

}
