//
//  TatsiConfig.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import Foundation
import Photos
import UIKit

/// A struct that defines all the customizable properties on a picker
public struct TatsiConfig {
    
    // MARK: - Public properties
    
    /// The default configuration of the picker
    public static let `default`: TatsiConfig = {
        return TatsiConfig()
    }()
    
    /// The view that is displayed to the user when the picker is displayed.
    public enum StartView {
        
        /// A view representing the users camera roll, or all photos in the case of the use of iCloud photo library.
        case userLibrary
        
        /// A view containing a list of albums, this includes smart albums and the user library options.
        case albums
        
        /// A view that shows the photos of a specific album.
        case album(PHAssetCollection)
    }

    /// The colors to apply to the interface elements.
    public var colors: TatsiColors = TatsiDefaultColors()

    /// All media types that the picker displays. Defaults to images and videos.
    public var supportedMediaTypes: Set<PHAssetMediaType> = [PHAssetMediaType.image, PHAssetMediaType.video]
    
    /// Can be used to filter out certain photo or video types. Such as Panoramas, slomo videos, screenshots or live photos. Defaults to no filtering
    public var supportedMediaSubTypes: [PHAssetMediaSubtype]?
    
    /// If the picker should show an option to open the camera in the user library (all photos/camera roll). Defaults to false.
    public var showCameraOption = false
    
    /// Allows for setting a max number of images that can be selected. Defaults to unlimited. Setting the value to 1 will stop the showing of a done button.
    public var maxNumberOfSelections: Int?
    
    /// If the picker should show the recently deleted album. Defaults to false.
    public var showRecentlyDeletedAlbum = false
    
    /// If the picker should show the hidden album in the list of albums. The hidden album contains photos the user has hidden. Defaults to true.
    public var showHiddenAlbum = true
    
    /// If the picker should show the pre-iOS 8 "Recently Added" album. Defaults to false
    public var showRecentlyAddedAlbum = false
    
    /// If the picker should show empty albums. Defaults to false.
    public var showEmptyAlbums = false
    
    /// If the picker should display shared (iCloud) albums. Defaults to true.
    public var showSharedAlbums = true
    
    /// If the picker should be a single view. This means the picker will open on the user library or a specific album. Switching can be done by tapping the on the header.
    public var singleViewMode = false
    
    /// The first view the picker should show to the user. Defaults to the user library.
    public var firstView = StartView.userLibrary
    
    /// The number of columns of images to show. If nil the system default will be used (4 on iPhone, 7 in landscape)
    public var numberOfColumns: Int?
    
    /// If the order of photos in the user library (all photos/camera roll) should be inverted.
    public var invertUserLibraryOrder = false

    /// If the delegate should finish immediately when maxNumberOfSelections is set to 1 and the user selects a photo
    public var finishImmediatelyWithMaximumOfOne = true

    /// The statusbar style to be used on the screens
    public var preferredStatusBarStyle: UIStatusBarStyle = .default
    
    /// Set a table name to load the localizable strings used in Tatsi from a specified localizable strings file.
    public var localizableStringsTableName: String? {
        didSet {
            LocalizableStrings.tableName = localizableStringsTableName
        }
    }

    // MARK: - Internal features
    
    /// All the PHAssetCollectionSubtypes that should not be shown to the user. Based on the current config
    private var bannedAlbumSubtypes: [PHAssetCollectionSubtype] {
        var bannedAlbumSubtypes: [PHAssetCollectionSubtype] = []
        
        if self.showRecentlyAddedAlbum == false {
            bannedAlbumSubtypes.append(.smartAlbumRecentlyAdded)
        }
        
        if self.showHiddenAlbum == false {
            bannedAlbumSubtypes.append(.smartAlbumAllHidden)
        }
        
        if self.supportedMediaTypes.contains(PHAssetMediaType.video) == false {
            bannedAlbumSubtypes.append(.smartAlbumVideos)
            bannedAlbumSubtypes.append(.smartAlbumTimelapses)
            bannedAlbumSubtypes.append(.smartAlbumSlomoVideos)
        }
        
        if self.supportedMediaTypes.contains(PHAssetMediaType.image) == false {
            bannedAlbumSubtypes.append(.smartAlbumPanoramas)
            bannedAlbumSubtypes.append(.smartAlbumBursts)
            bannedAlbumSubtypes.append(.smartAlbumSelfPortraits)
            bannedAlbumSubtypes.append(.smartAlbumScreenshots)
            if #available(iOS 10.2, *) {
                bannedAlbumSubtypes.append(.smartAlbumDepthEffect)
            }
            if #available(iOS 10.3, *) {
                bannedAlbumSubtypes.append(.smartAlbumLivePhotos)
            }
            if #available(iOS 11, *) {
                bannedAlbumSubtypes.append(.smartAlbumAnimated)
            }
        }
        
        return bannedAlbumSubtypes
    }
    
    /// Creates and returns the fetch options to use for fetching assets based on the config. Nil if the fetchOptions are not needed.
    internal func assetFetchOptions() -> PHFetchOptions? {
        let fetchOptions = PHFetchOptions()
        
        var predicates = [NSPredicate]()
        
        let mediaTypePredicates = self.supportedMediaTypes.compactMap({ (mediaType) -> NSPredicate? in
            return NSPredicate(format: "(mediaType == %ld)", mediaType.rawValue)
        })
        predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: mediaTypePredicates))
        
        if let mediaSubtypes = self.supportedMediaSubTypes {
            let mediaSubtypePredicates = mediaSubtypes.compactMap({ (mediaSubtype) -> NSPredicate? in
                return NSPredicate(format: "mediaSubtype == %d", mediaSubtype.rawValue)
            })
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: mediaSubtypePredicates))
        }
        
        fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return fetchOptions
    }
    
    /// Checks if a collection is allowed to be displayed in a album list based on the configuration
    ///
    /// - Parameter collection: The collection to check.
    /// - Returns: If the collection is allowed to be shown.
    internal func isCollectionAllowed(_ collection: PHCollection) -> Bool {
        guard let assetCollection = collection as? PHAssetCollection else {
            // Basic collections are always allowed.
            return true
        }
        
        guard !assetCollection.isUserLibrary else {
            //The user library is always allowed, even when empty.
            return true
        }
        
        if self.showEmptyAlbums == false {
            // If we don't allow empty albums, we hide the albums that have less than 1 asset.
            guard !assetCollection.isEmpty(for: self.assetFetchOptions()) else {
                return false
            }
        }
        
        guard assetCollection.assetCollectionType == .smartAlbum else {
            // We only need to check smart albums
            return true
        }
        
        /// We can only check the recently deleted collection based on its name at the moment.
        if self.showRecentlyDeletedAlbum == false && assetCollection.isRecentlyDeletedCollection {
            return false
        }
        
        return !self.bannedAlbumSubtypes.contains(assetCollection.assetCollectionSubtype)
    }
    
}
