//
//  LocalizableStrings.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 10/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import Foundation

final internal class LocalizableStrings {
    
    static var bundle: Bundle {
        return Bundle.main
    }
    
    /// The title at the top of the albums view
    static var albumsViewTitle: String {
        return NSLocalizedString("tatsi-picker.view.albums.title", tableName: nil, bundle: self.bundle, value: "Photos", comment: "The title at the top of the albums view")
    }
    
    /// The title of the back button leading to the albums view
    static var albumsViewBackButton: String {
        return NSLocalizedString("tatsi-picker.view.albums.back-button", tableName: nil, bundle: self.bundle, value: "Albums", comment: "The title of the back button leading to the albums view")
    }
    
    /// The title of the header on the albums view
    static var albumsViewMyAlbumsHeader: String {
        return NSLocalizedString("tatsi-picker.view.albums.my-albums.header", tableName: nil, bundle: self.bundle, value: "My Albums", comment: "The title of the header on the albums view")
    }
    
    /// The title for the message when the picker has no access to photos
    static var authorizationViewNoAccessTitle: String {
        return NSLocalizedString("tatsi-picker.view.authorization.no-access.title", tableName: nil, bundle: self.bundle, value: "Access Denied", comment: "The title for the message when the picker has no access to photos")
    }
    
    /// The message when the picker has no access to photo
    static var authorizationViewNoAccessMessage: String {
        return NSLocalizedString("tatsi-picker.view.authorization.no-access.message", tableName: nil, bundle: self.bundle, value: "Please allow access to photos in the Settings app", comment: "The message when the picker has no access to photos")
    }
    
    /// The button on the no access view that leads to the settings in the Settings.app
    static var authorizationViewSettingsButton: String {
        return NSLocalizedString("tatsi-picker.view.authorization.button.settings", tableName: nil, bundle: self.bundle, value: "Open Settings", comment: "The button on the no access view that leads to the settings in the Settings.app")
    }
    
    /// The title for the message when the picker is requesting access to photos
    static var authorizationViewRequestingAccessTitle: String {
        return NSLocalizedString("tatsi-picker.view.authorization.requesting-access.title", tableName: nil, bundle: self.bundle, value: "Requesting Access", comment: "The title for the message when the picker is requesting access to photos")
    }
    
    /// The message when the picker is requesting access to photos
    static var authorizationViewRequestingAccessMessage: String {
        return NSLocalizedString("tatsi-picker.view.authorization.requesting-access.message", tableName: nil, bundle: self.bundle, value: "Tap allow to give access to your photos library", comment: "The message when the picker is requesting access to photos")
    }
    
    /// The title of the empty state when an album is empty
    static var emptyAlbumTitle: String {
        return NSLocalizedString("tatsi-picker.view.album.empty.title", tableName: nil, bundle: self.bundle, value: "No Photos or Videos", comment: "The title of the empty state when an album is empty")
    }
    
    /// The message of the empty state when an album is empty
    static var emptyAlbumMessage: String {
        return NSLocalizedString("tatsi-picker.view.album.empty.message", tableName: nil, bundle: self.bundle, value: "Save some photos or videos to your device", comment: "The message of the empty state when an album is empty")
    }
    
    /// The title of the empty state when the album is loading it's assets
    static var albumLoading: String {
        return NSLocalizedString("tatsi-picker.view.album.loading.title", tableName: nil, bundle: self.bundle, value: "Loading...", comment: "The title of the empty state when the album is loading it's assets.")
    }
    
}
