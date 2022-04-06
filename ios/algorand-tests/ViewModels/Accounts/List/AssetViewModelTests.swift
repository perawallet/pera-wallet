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
//  AssetViewModelTests.swift

import XCTest

@testable import pera_staging

class AssetViewModelTests: XCTestCase {

    private let assetDetail = Bundle.main.decode(response: AssetDetail.self, from: "HipoCoinAsset.json")
//    private let asset = Bundle.main.decode(response: Asset.self, from: "Asset.json")

//    func testAmount() {
//        let viewModel = AssetViewModel(assetDetail: assetDetail, asset: asset)
//        XCTAssertEqual(viewModel.amount, "2,759.49")
//    }
}
