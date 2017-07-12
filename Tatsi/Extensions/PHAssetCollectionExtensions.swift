//
//  PHAssetCollectionExtensions.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import Foundation
import Photos
import ObjectiveC

extension PHAssetCollection {
    
    private struct AssociatedKeys {
        static var numberOfItems = "PHAssetCollection.numberOfItems"
    }
    
    internal func loadPreviewImage(_ targetSize: CGSize, fetchOptions: PHFetchOptions = PHFetchOptions(), completionHandler: @escaping ((_ image: UIImage?, _ asset: PHAsset?) -> Void)) {
        DispatchQueue.global(qos: .default).async {
            var asset: PHAsset?
            
            if let assetFetchOptions = fetchOptions.copy() as? PHFetchOptions {
                assetFetchOptions.fetchLimit = 1
                assetFetchOptions.sortDescriptors = nil
                let result = PHAsset.fetchKeyAssets(in: self, options: assetFetchOptions)
                if let resultAsset = result?.firstObject {
                    asset = resultAsset
                }
            }
            
            if let asset = asset {
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                PHImageManager.default().requestImage(for: asset, targetSize: targetSize.scaled(with: UIScreen.main.scale), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    DispatchQueue.main.async {
                        completionHandler(image, asset)
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil)
                }
            }
        }
    }
    
    private var numberOfItems: Int? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.numberOfItems) as? Int
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.numberOfItems, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func fetchNumberOfItems(_ fetchOptions: PHFetchOptions) -> Int {
        guard let numberOfItems = self.numberOfItems else {
            let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
            self.numberOfItems = result.count
            return result.count
        }
        return numberOfItems
    }
    
    internal var isRecentlyDeletedCollection: Bool {
        // The recently deleted collection can only be a smart album.
        guard self.assetCollectionType == .smartAlbum else {
            return false
        }
        
        /// Currently there is no app store passable or reliable way to check if the album is the "recently deleted" album. That's why we simply check the title.
        guard let title = self.localizedTitle?.lowercased() else {
            return false
        }
        let collectionNames = [
            "recently deleted",
            "eliminado",
            "zuletzt gelöscht",
            "supprimés récemment",
            "onlangs verwijderd" ,
            "eliminati di recente"
        ]
        return collectionNames.contains(title)
    }
    
    internal var isUserLibrary: Bool {
        return self.assetCollectionType == .smartAlbum && self.assetCollectionSubtype == .smartAlbumUserLibrary
    }
    
}
