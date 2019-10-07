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
import UIKit

extension PHAssetCollection {
    
    internal func loadPreviewImage(_ targetSize: CGSize, fetchOptions: PHFetchOptions? = nil, completionHandler: @escaping ((_ image: UIImage?, _ asset: PHAsset?) -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async {
            var asset: PHAsset?
            
            var assetFetchOptions: PHFetchOptions?
            if let fetchOptions = fetchOptions?.copy() as? PHFetchOptions {
                fetchOptions.fetchLimit = 1
                assetFetchOptions = fetchOptions
            }
            let result = PHAsset.fetchKeyAssets(in: self, options: assetFetchOptions)
            if let resultAsset = result?.firstObject {
                asset = resultAsset
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
    
    internal func fetchNumberOfItems(for fetchOptions: PHFetchOptions? = nil, completionHandler: @escaping ((_ count: Int, _ collection: PHAssetCollection) -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let result = PHAsset.fetchAssets(in: strongSelf, options: fetchOptions)
            DispatchQueue.main.async {
                completionHandler(result.count, strongSelf)
            }
        }
    }
    
    internal func isEmpty(for fetchOptions: PHFetchOptions? = nil) -> Bool {
        guard self.estimatedAssetCount > 0 || self.estimatedAssetCount == NSNotFound else {
           return true
        }
        if let fetchOptions = fetchOptions?.copy() as? PHFetchOptions {
            fetchOptions.fetchLimit = 1
            return PHAsset.fetchAssets(in: self, options: fetchOptions).count == 0
        } else {
            return false
        }
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
