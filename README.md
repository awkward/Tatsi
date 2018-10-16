<h1 align="center">
  <img src="Docs/icon.png" width="136" alt="icon"><br>
  Tatsi<br>
  <p align="center">
  <a href="https://travis-ci.org/awkward/Tatsi">
    <img src="https://travis-ci.org/awkward/Tatsi.svg?branch=master" alt="Build Status">
  </a>
  <a href="https://twitter.com/madeawkward">
    <img src="https://img.shields.io/badge/contact-madeawkward-blue.svg?style=flat" alt="Contact">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  </a>
</p>
</h1>

A drop-in replacement for UIImagePickerController with more options and the ability to select multiple images and/or videos.

## Screenshots

![Albums list](Docs/Screenshots/albums.png?raw=true)
![Camera Roll](Docs/Screenshots/camera-roll.png?raw=true)
![Selection](Docs/Screenshots/camera-roll-selected.png?raw=true)

## Introduction

Hi, we're <a href="https://awkward.co/" target="_blank">Awkward</a>. We created a customizable image picker for our iOS reddit client called <a href="https://beamreddit.com/" target="_blank">Beam</a>. UIImagePickerController only supports selecting 1 image at a time, but we needed more images in Beam. Tatsi has built in support for selecting multiple images. On top of that, we integrated a camera button directly into the picker. We welcome you to use Tatsi for your own projects.

## Features

- Multi selection of photos/videos using the photos library
- Ability to reverse the display order of images/videos
- Option to show a camera button inside the picker
- Assigning a max limit for the number of photos and videos
- Choosing the first view the user sees

## Installation

### Submodules/Embedded frameworks (preferred)

1. Add Tatsi as a submodule to your repository.
2. Drag `Tatsi.xcodeproj` into your Xcode project
3. Go to your Project Settings -> General and add Tatsi under Embedded Frameworks
4. Add `NSPhotoLibraryUsageDescription` to your Info.plist with a proper description.
5. (Optional) if you want to use the camera option. You will also need to add `NSCameraUsageDescription` to your Info.plist

### Manual

1. Remove Tatsi.h and Info.plist from the Tatsi folder.
2. Add the contents of the Tatsi folder to your projects
3. Add `NSPhotoLibraryUsageDescription` to your Info.plist with a proper description.
4. (Optional) if you want to use the camera option. You will also need to add `NSCameraUsageDescription` to your Info.plist

### Carthage

1. Add `github "awkward/Tatsi"` to your `Cartfile`
2. Run `carthage update Tatsi`
3. Add Tatsi to your project's Embedded Binaries and to the Carthage build phase
4. Add `NSPhotoLibraryUsageDescription` to your Info.plist with a proper description.
5. (Optional) if you want to use the camera option. You will also need to add `NSCameraUsageDescription` to your Info.plist

## Usage

1. Add `Import Tatsi` and `Import Photos` to your Swift file. You can skip this step if you used manual installation.
2. (Optional) Create an instance of `TatsiConfig` and configure the settings.
3. Create an instance of `TatsiPickerViewController`. `TatsiPickerViewController(config:)` allows you to use the config from the previous step
4. Implement `TatsiPickerViewControllerDelegate`
5. Set the `pickerDelegate` on `TatsiPickerViewController`
6. Present the `TatsiPickerViewController`

### Localization

Tatsi comes localized to English only but you can provide localization for other languages in your project. Just add the following localized strings for the language you want Tatsi to support

| Key        | English |
| ------------- |-------------|
|tatsi-picker.view.albums.title | Photos | 
|tatsi-picker.view.albums.back-button | Albums | 
|tatsi-picker.view.albums.my-albums.header | My albums | 
|tatsi-picker.view.authorization.no-access.title | Access denied | 
|tatsi-picker.view.authorization.no-access.message | Please allow access to photos in the Settings app | 
|tatsi-picker.view.authorization.button.settings | Open Settings | 
|tatsi-picker.view.authorization.requesting-access.title | Requesting Access | 
|tatsi-picker.view.authorization.requesting-access.message | Tap allow to give access to your photos library | 
|tatsi-picker.view.album.empty.title | No Photos or Videos | 
|tatsi-picker.view.album.empty.message | Save some photos or videos to your device|
|tatsi-picker.view.album.loading.title | Loading...|
|tatsi-picker.button.camera.title | Camera|
|tatsi-picker.accessibility.selection-limit-reached | The max number of assets has been selected|
|tatsi-picker.accessibility.images-count | %d Images|
|tatsi-picker.accessibility.activate-to-hide-album-list | Activate to hide album list|
|tatsi-picker.accessibility.activate-to-show-album-list | Activate to show album list|
|tasti.button.change-album | Tap here to change | 

## Misc

### Origin of name
Tatsi = Photos in Planco, the language spoken in the game Planet Coaster. [Source](https://twitter.com/JamesStant/status/882582597460799489)

### Missing parts

- [ ] The ability to color some elements
- [ ] Icons for the hidden and recently deleted albums
- [ ] Proper `init?(coder aDecoder: NSCoder)` support
- [ ] UI Tests
- [ ] Running Unit Tests on Travis

## Documentation

> We're trying to keep our documentation as updated as possible. Here you can find more information on Tatsi.

## License

> Tatsi is available under the MIT license. See the LICENSE file for more info.

## Links

  - <a href="https://awkward.co/" target="_blank">Awkward</a>
  - <a href="https://beamreddit.com/" target="_blank">Beam</a>
