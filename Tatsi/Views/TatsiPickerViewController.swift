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
    
    // MARK: - Initializers
    
    public init(config: TatsiConfig = TatsiConfig.default) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        
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
            switch self.config.firstView {
            case .userLibrary:
                 album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject
            case .album(let collection):
                album = collection
            default:
                break
            }
            self.showAlbumViewController(with: album)
        case .denied, .notDetermined, .restricted:
            // Not authorized, show the view to give access
            self.viewControllers = [AuthorizationViewController()]
        }
    }
    
    private func showAlbumViewController(with collection: PHAssetCollection?) {
        if let collection = collection {
            self.viewControllers = [AlbumsViewController(), AssetsGridViewController(album: collection)]
        } else {
            self.viewControllers = [AlbumsViewController()]
        }
    }

}
