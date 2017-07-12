# Tatsi
A drop-in replacement for UIImagePickerController with more options and the ability to select multiple images and/or videos

## Screenshots 

![Albums list](Screenshots/albums.png?raw=true)
![Camera Roll](Screenshots/camera-roll.png?raw=true)
![Selection](Screenshots/camera-roll-selected.png?raw=true)

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

## Usage

1. Add `Import Tatsi` and `Import Photos` to your Swift file. You can skip this step if you used manual installation.
2. (Optional) Create an instance of `TatsiConfig` and configure the settings.
3. Create an instance of `TatsiPickerViewController`. `TatsiPickerViewController(config:)` allows you to use the config from the previous step
4. Implement `TatsiPickerViewControllerDelegate`
5. Set the `pickerDelegate` on `TatsiPickerViewController`
6. Present the `TatsiPickerViewController`

## Misc

### Origin of name
Tatsi = Photos in Planco, the language spoken in the game Planet Coaster. [Source](https://twitter.com/JamesStant/status/882582597460799489)

### Missing parts

- [ ] The ability to color some elements
- [ ] Icons for the hidden and recently deleted albums
- [ ] Proper `init?(coder aDecoder: NSCoder)` support
- [ ] UI Tests