// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tatsi",    
    platforms: [
      .iOS(.v10)
    ],
    products: [        
        .library(name: "Tatsi", targets: ["Tatsi"]),
    ],
    targets: [     
        .target(name: "Tatsi", path: "Tatsi"),
    ]
)
