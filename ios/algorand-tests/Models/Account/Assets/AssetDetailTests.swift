// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AssetDetailTests.swift

import XCTest

@testable import pera_staging

class AssetDetailTests: XCTestCase {
    
    private let assetDetail = Bundle.main.decode(response: AssetDetail.self, from: "HipoCoinAsset.json")

//    func testGetDisplayNames() {
//        let displayNames = assetDetail.getDisplayNames()
//        XCTAssertEqual(displayNames.0, ("HipoCoin"))
//        XCTAssertEqual(displayNames.1, ("HIPO"))
//    }
//
//    func testHasOnlyAssetName() {
//        XCTAssertFalse(assetDetail.hasOnlyAssetName())
//    }

    func testHasNoDisplayName() {
        XCTAssertFalse(assetDetail.hasNoDisplayName())
    }

    func testGetAssetName() {
        let assetName = assetDetail.getAssetName()
        XCTAssertEqual(assetName, ("HipoCoin"))
    }
}
