//
//  PresentationTests.swift
//  TatsiTests
//
//  Created by Rens Verhoeven on 11/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import XCTest
@testable import Tatsi
import Photos

/// Tests the presentation of the TatsiPickerViewController.
final class PresentationTests: TatsiTestCase {
    
    override func setUp() {
        super.setUp()
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            XCTFail("This test requires access to the Photos Library")
            return
        }
    }
    
    /// Tests the presentation of the TatsiPickerViewController with the first view set to the user library.
    func testUserLibraryPresentation() {
        var config = TatsiConfig.default
        config.firstView = .userLibrary
        
        let picker = self.presentPicker(with: config)
        
        guard let assetsViewController = picker.topViewController as? AssetsGridViewController else {
            XCTFail("The top view controller should be the asset grid, because we have the library visible")
            return
        }
        XCTAssert(assetsViewController.album.assetCollectionSubtype == .smartAlbumUserLibrary && assetsViewController.album.assetCollectionType == .smartAlbum, "The album of the assets grid should be of sub type userLibrary")
    }
    
    /// Tests the presentation of the TatsiPickerViewController with the first view set to the albums list.
    func testAlbumsPresentation() {
        var config = TatsiConfig.default
        config.firstView = .albums
        
        let picker = self.presentPicker(with: config)
        
        guard let albumsView = picker.topViewController as? AlbumsViewController else {
            XCTFail("The top view controller should be the albums view")
            return
        }
        XCTAssert(albumsView.tableView.numberOfRows(inSection: 0) > 0, "The albums list needs to display at least 1 album. The user library")
    }
    
    /// Tests the presentation of the TatsiPickerViewController with the first view with a specific album.
    func testCustomAlbumPresentation() {
        let collectionName = "Custom Album \(Int(arc4random_uniform(10000) + 1))"
        let collection = self.createCollection(name: collectionName)!
        
        
        var config = TatsiConfig.default
        config.firstView = .album(collection)
        
        let picker = self.presentPicker(with: config)
        
        guard let assetsViewController = picker.topViewController as? AssetsGridViewController else {
            XCTFail("The top view controller should be the asset grid, because we use a custom album")
            return
        }
        XCTAssert(assetsViewController.album == collection, "The album of the assets grid should be the custom collection")
        XCTAssert(assetsViewController.title == collectionName, "The title should match the album name")
    }
    
}
