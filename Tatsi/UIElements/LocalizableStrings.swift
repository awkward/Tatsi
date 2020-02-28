//
//  LocalizableStrings.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 10/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import Foundation
import UIKit

final internal class LocalizableStrings {
    
    static var bundle: Bundle {
        return Bundle.main
    }
    
    /// The table name to fetch the localized strings from. Defaults to nil, which will not check a specific table.
    static var tableName: String?
    
    /// The title at the top of the albums view
    static var albumsViewTitle: String {
        return NSLocalizedString("tatsi-picker.view.albums.title", tableName: self.tableName, bundle: self.bundle, value: "Photos", comment: "The title at the top of the albums view")
    }
    
    /// The title of the back button leading to the albums view
    static var albumsViewBackButton: String {
        return NSLocalizedString("tatsi-picker.view.albums.back-button", tableName: self.tableName, bundle: self.bundle, value: "Albums", comment: "The title of the back button leading to the albums view")
    }
    
    /// The title of the hint label below the albums's name
    static var tapToChangeAlbumTitle: String {
        return NSLocalizedString("tasti.button.change-album", tableName: self.tableName, bundle: self.bundle, value: "Tap here to change", comment: "The label that is shown below the album's name to direct the user to tap the title to change the album")
    }
    
    /// The title of the user albums header on the albums view
    static var albumsViewMyAlbumsHeader: String {
        return NSLocalizedString("tatsi-picker.view.albums.my-albums.header", tableName: self.tableName, bundle: self.bundle, value: "My Albums", comment: "The title of the user albums header on the albums view")
    }
    
    /// The title of the (iCloud) shared albums header on the albums view
    static var albumsViewSharedAlbumsHeader: String {
        return NSLocalizedString("tatsi-picker.view.albums.shared-albums.header", tableName: self.tableName, bundle: self.bundle, value: "Shared Albums", comment: "The title of the (iCloud) shared albums header on the albums view")
    }
    
    /// The title for the message when the picker has no access to photos
    static var authorizationViewNoAccessTitle: String {
        return NSLocalizedString("tatsi-picker.view.authorization.no-access.title", tableName: self.tableName, bundle: self.bundle, value: "Access Denied", comment: "The title for the message when the picker has no access to photos")
    }
    
    /// The message when the picker has no access to photo
    static var authorizationViewNoAccessMessage: String {
        return NSLocalizedString("tatsi-picker.view.authorization.no-access.message", tableName: self.tableName, bundle: self.bundle, value: "Please allow access to photos in the Settings app", comment: "The message when the picker has no access to photos")
    }
    
    /// The button on the no access view that leads to the settings in the Settings.app
    static var authorizationViewSettingsButton: String {
        return NSLocalizedString("tatsi-picker.view.authorization.button.settings", tableName: self.tableName, bundle: self.bundle, value: "Open Settings", comment: "The button on the no access view that leads to the settings in the Settings.app")
    }
    
    /// The title for the message when the picker is requesting access to photos
    static var authorizationViewRequestingAccessTitle: String {
        return NSLocalizedString("tatsi-picker.view.authorization.requesting-access.title", tableName: self.tableName, bundle: self.bundle, value: "Requesting Access", comment: "The title for the message when the picker is requesting access to photos")
    }
    
    /// The message when the picker is requesting access to photos
    static var authorizationViewRequestingAccessMessage: String {
        return NSLocalizedString("tatsi-picker.view.authorization.requesting-access.message", tableName: self.tableName, bundle: self.bundle, value: "Tap allow to give access to your photos library", comment: "The message when the picker is requesting access to photos")
    }
    
    /// The title of the empty state when an album is empty
    static var emptyAlbumTitle: String {
        return NSLocalizedString("tatsi-picker.view.album.empty.title", tableName: self.tableName, bundle: self.bundle, value: "No Photos or Videos", comment: "The title of the empty state when an album is empty")
    }
    
    /// The message of the empty state when an album is empty
    static var emptyAlbumMessage: String {
        return NSLocalizedString("tatsi-picker.view.album.empty.message", tableName: self.tableName, bundle: self.bundle, value: "Save some photos or videos to your device", comment: "The message of the empty state when an album is empty")
    }
    
    /// The title of the empty state when the album is loading it's assets
    static var albumLoading: String {
        return NSLocalizedString("tatsi-picker.view.album.loading.title", tableName: self.tableName, bundle: self.bundle, value: "Loading...", comment: "The title of the empty state when the album is loading it's assets.")
    }
    
    /// The title of the camera button
    static var cameraButtonTitle: String {
        return NSLocalizedString("tatsi-picker.button.camera.title", tableName: self.tableName, bundle: self.bundle, value: "Camera", comment: "The title of the camera button")
    }
    
    /// The message that the user is alerted of when the selection limit has been reached
    static var accessibilityAlertSelectionLimitReached: String {
        return NSLocalizedString("tatsi-picker.accessibility.selection-limit-reached", tableName: self.tableName, bundle: self.bundle, value: "The max number of assets has been selected", comment: "The message that the user is alerted of when the selection limit has been reached")
    }
    
    /// The image count in an album, for accessibility users
    static var accessibilityAlbumImagesCount: String {
        return NSLocalizedString("tatsi-picker.accessibility.images-count", tableName: self.tableName, bundle: self.bundle, value: "%d Images", comment: "The image count in an album, for accessibility users")
    }
    
    /// The accessibility hint the user gets on the album switcher to close/hide the album list
    static var accessibilityActivateToHideAlbumList: String {
        return NSLocalizedString("tatsi-picker.accessibility.activate-to-hide-album-list", tableName: self.tableName, bundle: self.bundle, value: "Activate to hide album list", comment: "The accessibility hint the user gets on the album switcher")
    }
    
    /// The accessibility hint the user gets on the album switcher to show/open the album list
    static var accessibilityActivateToShowAlbumList: String {
        return NSLocalizedString("tatsi-picker.accessibility.activate-to-show-album-list", tableName: self.tableName, bundle: self.bundle, value: "Activate to show album list", comment: "The accessibility hint the user gets on the album switcher")
    }
    
}
