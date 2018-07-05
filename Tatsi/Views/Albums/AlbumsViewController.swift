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
    
    // MARK: - Public Properties
    
    /// Set the delegate in order to recieve a callback when the user selects an album.
    weak var delegate: AlbumsViewControllerDelegate?
    
    // MARK: - Private Properties
    
    fileprivate var smartAlbums: [PHAssetCollection] = []
    
    fileprivate var userAlbums: [PHAssetCollection] = []
    
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
        if #available(iOS 10.3, *), let index = smartAlbumSortingOrder.index(of: .smartAlbumPanoramas) {
            smartAlbumSortingOrder.insert(.smartAlbumLivePhotos, at: index)
        }
        if #available(iOS 10.2, *), let index = smartAlbumSortingOrder.index(of: .smartAlbumBursts) {
            smartAlbumSortingOrder.insert(.smartAlbumDepthEffect, at: index)
        }
        if #available(iOS 11, *), let index = smartAlbumSortingOrder.index(of: .smartAlbumAllHidden) {
            smartAlbumSortingOrder.insert(.smartAlbumAnimated, at: index)
        }
        return smartAlbumSortingOrder
    }()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let cancelButtonItem = self.pickerViewController?.customCancelButtonItem() ?? UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(AlbumsViewController.cancel(_:)))
        cancelButtonItem.target = self
        cancelButtonItem.action = #selector(cancel(_:))
        cancelButtonItem.accessibilityIdentifier = "tatsi.button.cancel"
        self.navigationItem.rightBarButtonItem = cancelButtonItem
        
        let backButtonItem = UIBarButtonItem(title: LocalizableStrings.albumsViewBackButton, style: .plain, target: nil, action: nil)
        backButtonItem.accessibilityIdentifier = "tatsi.button.albums"
        self.navigationItem.backBarButtonItem = backButtonItem
        
        self.title = LocalizableStrings.albumsViewTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.reuseIdentifier)
        self.tableView.register(AlbumsTableHeaderView.self, forHeaderFooterViewReuseIdentifier: AlbumsTableHeaderView.reuseIdentifier)
        self.tableView.rowHeight = 90
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.tableView.separatorStyle = .none
        
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
        var smartAlbums = [PHAssetCollection]()
        
        let smartAlbumResults = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        smartAlbumResults.enumerateObjects({ (collection, _, _) in
            guard self.config?.isCollectionAllowed(collection) == true else {
                return
            }
            smartAlbums.append(collection)
        })
        smartAlbums.sort { (collection1, collection2) -> Bool in
            guard let index1 = self.smartAlbumSortingOrder.index(of: collection1.assetCollectionSubtype), let index2 = self.smartAlbumSortingOrder.index(of: collection2.assetCollectionSubtype) else {
                return true
            }
            return index1 < index2
        }
        self.smartAlbums = smartAlbums

        var albums = [PHAssetCollection]()
        let albumResults = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        albumResults.enumerateObjects({ (collection, _, _) in
            guard let assetCollection = collection as? PHAssetCollection, self.config?.isCollectionAllowed(collection) == true else {
                return
            }
            albums.append(assetCollection)
        })
        albums.sort { (collection1, collection2) -> Bool in
            guard let startDate1 = collection1.localizedTitle, let startDate2 = collection2.localizedTitle else {
                return false
            }
            return startDate1.compare(startDate2) == .orderedDescending
        }
        self.userAlbums = albums
    }
    
    // MARK: - Actions
    
    @objc fileprivate func cancel(_ sender: AnyObject) {
        self.cancelPicking()
    }
    
    // MARK: - Helpers
    
    fileprivate func album(for indexPath: IndexPath) -> PHAssetCollection? {
        switch indexPath.section {
        case 0:
            return self.smartAlbums[indexPath.row]
        case 1:
            return self.userAlbums[indexPath.row]
        default:
            return nil
        }
    }
    
}

// MARK: - UITableViewDataSource

extension AlbumsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.smartAlbums.count
        case 1:
            return self.userAlbums.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.reuseIdentifier, for: indexPath) as? AlbumTableViewCell else {
            fatalError("AlbumTableViewCell probably not registered")
        }
        cell.album = self.album(for: indexPath)
        cell.reloadContents(with: self.config?.assetFetchOptions())
        cell.accessoryType = (self.config?.singleViewMode ?? false) ? .none : .disclosureIndicator
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
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else {
            return nil
        }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AlbumsTableHeaderView.reuseIdentifier) as? AlbumsTableHeaderView else {
            fatalError("AlbumsTableHeaderView probably not registered")
        }
        headerView.title = LocalizableStrings.albumsViewMyAlbumsHeader
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 1 else {
            return 0
        }
        return AlbumsTableHeaderView.height
    }
    
}
