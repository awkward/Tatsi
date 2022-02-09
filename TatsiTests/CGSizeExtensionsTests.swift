//
//  CGSizeExtensionsTests.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 11/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import XCTest
@testable import Tatsi

/// Test the extensions on CGSize.
final class CGSizeExtensionsTests: XCTestCase {
  
  /// Scaling down a CGSize should give the correct size.
  func testScalingDown() {
    let size = CGSize(width: 100, height: 200)
    XCTAssert(size.scaled(with: 0.8) == CGSize(width: 80, height: 160), "The size should be scaled down properly")
  }
  
  /// Scaling a CGSize with a scale of 1 should give the original size.
  func testScalingSame() {
    let size = CGSize(width: 100, height: 200)
    XCTAssert(size.scaled(with: 1) == size, "The size should be the same")
  }
  
  /// Scaling up a CGSize should give the correct size.
  func testScalingUp() {
    let size = CGSize(width: 200, height: 100)
    XCTAssert(size.scaled(with: 1.2) == CGSize(width: 240, height: 120), "The size should be scaled up properly")
  }
  
  /// Scaling a CGSize with a negative value should return a negative result.
  func testScalingNegative() {
    let size = CGSize(width: 200, height: 100)
    XCTAssert(size.scaled(with: -1.2) == CGSize(width: -240, height: -120), "The size should be scaled down properly")
  }
  
  
}
