//
//  PHAssetCollectionExtensionsTests.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import XCTest
@testable import Tatsi
import Photos

/// Test the extensions on PHAssetCollection.
final class PHAssetCollectionExtensionsTests: TatsiTestCase {
    
    override func setUp() {
        super.setUp()
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            XCTFail("This test requires access to the Photos Library")
            return
        }
    }

    /// Tests to make sure the isRecentlyDeletedCollection works.
    func testContainsRecentlyDeleted() {
        var foundRecentlyDeleted = false
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        collections.enumerateObjects({ (assetCollection, _, _) in
            if assetCollection.isRecentlyDeletedCollection {
                foundRecentlyDeleted = true
            }
        })
        XCTAssert(foundRecentlyDeleted, "Fetching smart albums should have a recently deleted collection")
        
    }
    
    /// Tests to make sure the isUserLibrary works.
    func testContainsUserLibrary() {
        var foundUserLibrary = false
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        collections.enumerateObjects({ (assetCollection, _, _) in
            if assetCollection.isUserLibrary {
                foundUserLibrary = true
            }
        })
        XCTAssert(foundUserLibrary, "Fetching smart albums should have a user library collection")
    }
    
    /// Tests the method to fetch the actual number of items in a collection.
    func testNumberOfItems() {
        var config = TatsiConfig()
        config.supportedMediaTypes = [.image]
        
        let images = [UIImage(contentsOfFile: self.bundle.path(forResource: "test-image-1", ofType: "png")!)!, UIImage(contentsOfFile: self.bundle.path(forResource: "test-image-2", ofType: "jpg")!)!]
        
        let collectionName = "Test Collection \(Int(arc4random_uniform(10000) + 1))"
        let collection = self.createCollection(name: collectionName)!
        
        self.addImages(images, collection: collection)
        
        self.addImages(images)
        
        let expectation = self.expectation(description: "The count of the collection should equal the number of images added")
        collection.fetchNumberOfItems { (count, countedCollection) in
            XCTAssert(count == images.count, "The count of the collection should equal the number of images added")
            XCTAssert(collection == countedCollection, "The collection from the handler should match the original collection")
            XCTAssert(Thread.isMainThread, "The completion handler should be called on the main thread")
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    /// Tests the fetching a preview image for the collection.
    func testPreviewImage() {
        var config = TatsiConfig()
        config.supportedMediaTypes = [.image]
        
        let images = [UIImage(contentsOfFile: self.bundle.path(forResource: "test-image-1", ofType: "png")!)!, UIImage(contentsOfFile: self.bundle.path(forResource: "test-image-2", ofType: "jpg")!)!]
        
        
        let collectionName = "Test Collection \(Int(arc4random_uniform(10000) + 1))"
        let collection = self.createCollection(name: collectionName)!
        
        self.addImages(images, collection: collection)
        
        let expectation = self.expectation(description: "The user library with at least 2 images should have a preview image")
        expectation.assertForOverFulfill = false
        
        self.userLibrary.loadPreviewImage(CGSize(width: 200, height: 200), fetchOptions: config.assetFetchOptions()) { (image, _) in
            if let image = image {
                XCTAssert(Thread.isMainThread, "The closure should respond on the main thread")
                XCTAssert(image.size != CGSize(), "The image should have a size")
            } else {
                XCTFail("An collection with at least 2 images should have a preview image")
            }
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5)
        
    }
    
}
