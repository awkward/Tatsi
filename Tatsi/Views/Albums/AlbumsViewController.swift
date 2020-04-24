//
//  AlbumsViewController.swift
//  AWKImagePickerController
//
//  Created by Rens Verhoeven on 27-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

internal protocol AlbumsViewControllerDelegate: class {
    
    /// Called when an album is selected in the album list.
    ///
    /// - Parameters:
    ///   - albumsViewController: The AlbumsViewController in which the album was selected.
    ///   - album: The selected album.
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection)
    
}

final internal class AlbumsViewController: UITableViewController, PickerViewController {
    
    /// A category in which a album lives. These categories are displayed as sections in the table view.
    internal struct AlbumCategory {
        
        /// The title that should be displayed in the header above the albums.
        var headerTitle: String?
        
        /// The albums that should be displayed for the category.
        let albums: [PHAssetCollection]
    }
    
    // MARK: - Public Properties
    
    /// Set the delegate in order to recieve a callback when the user selects an album.
    weak var delegate: AlbumsViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.config?.preferredStatusBarStyle ?? .default
    }
    
    // MARK: - Private Properties
    
    /// The categories of albums to display in the album list. These translate to the sections in the table view.
    fileprivate var categories: [AlbumCategory] = []
    
    lazy fileprivate var smartAlbumSortingOrder: [PHAssetCollectionSubtype] = {
        var smartAlbumSortingOrder = [
            PHAssetCollectionSubtype.smartAlbumUserLibrary,
            PHAssetCollectionSubtype.smartAlbumFavorites,
            PHAssetCollectionSubtype.smartAlbumRecentlyAdded,
            PHAssetCollectionSubtype.smartAlbumVideos,
            PHAssetCollectionSubtype.smartAlbumSelfPortraits,
            PHAssetCollectionSubtype.smartAlbumPanoramas,
            PHAssetCollectionSubtype.smartAlbumTimelapses,
            PHAssetCollectionSubtype.smartAlbumSlomoVideos,
            PHAssetCollectionSubtype.smartAlbumBursts,
            PHAssetCollectionSubtype.smartAlbumScreenshots,
            PHAssetCollectionSubtype.smartAlbumAllHidden
        ]
        if #available(iOS 10.3, *), let index = smartAlbumSortingOrder.firstIndex(of: .smartAlbumPanoramas) {
            smartAlbumSortingOrder.insert(.smartAlbumLivePhotos, at: index)
        }
        if #available(iOS 10.2, *), let index = smartAlbumSortingOrder.firstIndex(of: .smartAlbumBursts) {
            smartAlbumSortingOrder.insert(.smartAlbumDepthEffect, at: index)
        }
        if #available(iOS 11, *), let index = smartAlbumSortingOrder.firstIndex(of: .smartAlbumAllHidden) {
            smartAlbumSortingOrder.insert(.smartAlbumAnimated, at: index)
        }
        return smartAlbumSortingOrder
    }()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButtonItem = self.pickerViewController?.customCancelButtonItem() ?? UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(AlbumsViewController.cancel(_:)))
        cancelButtonItem.target = self
        cancelButtonItem.action = #selector(cancel(_:))
        cancelButtonItem.accessibilityIdentifier = "tatsi.button.cancel"
        cancelButtonItem.tintColor = self.config?.colors.link ?? TatsiConfig.default.colors.link
        self.navigationItem.rightBarButtonItem = cancelButtonItem

        self.navigationItem.backBarButtonItem?.accessibilityIdentifier = "tatsi.button.albums"

        self.title = LocalizableStrings.albumsViewTitle
        
        self.tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.reuseIdentifier)
        self.tableView.register(AlbumsTableHeaderView.self, forHeaderFooterViewReuseIdentifier: AlbumsTableHeaderView.reuseIdentifier)
        self.tableView.rowHeight = 90
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = self.config?.colors.background ?? TatsiConfig.default.colors.background
        
        self.tableView.accessibilityIdentifier = "tatsi.tableView.albums"
        
        self.startLoadingAlbums()
    }
    
    // MARK: - Accessibility
    
    public override func accessibilityPerformEscape() -> Bool {
        if self.config?.singleViewMode == true {
            return false
        } else {
            self.cancelPicking()
            if self.pickerViewController?.pickerDelegate == nil {
                self.dismiss(animated: true, completion: nil)
            }
            return true
        }
    }
    
    // MARK: - Fetching
    
    fileprivate func startLoadingAlbums() {
        var newCategories = [AlbumCategory]()
        let smartAlbums = self.fetchSmartAlbums()
        if !smartAlbums.isEmpty {
            newCategories.append(AlbumCategory(headerTitle: nil, albums: smartAlbums))
        }
        
        let userAlbums = self.fetchUserAlbums()
        if !userAlbums.isEmpty {
            newCategories.append(AlbumCategory(headerTitle: LocalizableStrings.albumsViewMyAlbumsHeader, albums: userAlbums))
        }
        
        if self.config?.showSharedAlbums == true {
            let sharedAlbums = self.fetchSharedAlbums()
            if !sharedAlbums.isEmpty {
                newCategories.append(AlbumCategory(headerTitle: LocalizableStrings.albumsViewSharedAlbumsHeader, albums: sharedAlbums))
            }
        }
        self.categories = newCategories
    }
    
    fileprivate func fetchSmartAlbums() -> [PHAssetCollection] {
        let collectionResults = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        var collections = [PHAssetCollection]()
        collectionResults.enumerateObjects({ (collection, _, _) in
            guard self.config?.isCollectionAllowed(collection) == true else {
                return
            }
            collections.append(collection)
        })
        collections.sort { (collection1, collection2) -> Bool in
            guard let index1 = self.smartAlbumSortingOrder.firstIndex(of: collection1.assetCollectionSubtype), let index2 = self.smartAlbumSortingOrder.firstIndex(of: collection2.assetCollectionSubtype) else {
                return true
            }
            return index1 < index2
        }
        return collections
    }
    
    fileprivate func fetchUserAlbums() -> [PHAssetCollection] {
        let collectionResults = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        var collections = [PHAssetCollection]()
        collectionResults.enumerateObjects({ (collection, _, _) in
            guard let assetCollection = collection as? PHAssetCollection, self.config?.isCollectionAllowed(collection) == true else {
                return
            }
            collections.append(assetCollection)
        })
        collections.sort { (collection1, collection2) -> Bool in
            guard let title1 = collection1.localizedTitle, let title2 = collection2.localizedTitle else {
                return false
            }
            return title1.compare(title2) == .orderedDescending
        }
        return collections
    }
    
    fileprivate func fetchSharedAlbums() -> [PHAssetCollection] {
        let collectionResults = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil)
        var collections = [PHAssetCollection]()
        collectionResults.enumerateObjects({ (collection, _, _) in
            collections.append(collection)
        })
        collections.sort { (collection1, collection2) -> Bool in
            guard let title1 = collection1.localizedTitle, let title2 = collection2.localizedTitle else {
                return false
            }
            return title1.compare(title2) == .orderedDescending
        }
        return collections
    }
    
    // MARK: - Actions
    
    @objc fileprivate func cancel(_ sender: AnyObject) {
        self.cancelPicking()
    }
    
    // MARK: - Helpers
    
    fileprivate func category(for section: Int) -> AlbumCategory? {
        guard section < self.categories.count else {
            return nil
        }
        return self.categories[section]
    }
    
    fileprivate func album(for indexPath: IndexPath) -> PHAssetCollection? {
        guard let category = self.category(for: indexPath.section), indexPath.row < category.albums.count else {
            return nil
        }
        return category.albums[indexPath.row]
    }
    
}

// MARK: - UITableViewDataSource

extension AlbumsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.category(for: section)?.albums.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.reuseIdentifier, for: indexPath) as? AlbumTableViewCell else {
            fatalError("AlbumTableViewCell probably not registered")
        }
        cell.album = self.album(for: indexPath)
        cell.reloadContents(with: self.config?.assetFetchOptions())
        cell.accessoryType = (self.config?.singleViewMode ?? false) ? .none : .disclosureIndicator
        cell.colors = self.config?.colors
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension AlbumsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = self.album(for: indexPath) else {
            return
        }
        if let delegate = self.delegate {
            delegate.albumsViewController(self, didSelectAlbum: album)
        } else {
            let gridViewController = AssetsGridViewController(album: album)
            self.navigationController?.pushViewController(gridViewController, animated: true)
        }
        self.didSelectCollection(album)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = self.category(for: section) else {
            return nil
        }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AlbumsTableHeaderView.reuseIdentifier) as? AlbumsTableHeaderView else {
            fatalError("AlbumsTableHeaderView probably not registered")
        }
        headerView.title = category.headerTitle
        headerView.colors = self.config?.colors
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.category(for: section)?.headerTitle != nil else {
            return 0
        }
        return AlbumsTableHeaderView.height
    }
    
}
