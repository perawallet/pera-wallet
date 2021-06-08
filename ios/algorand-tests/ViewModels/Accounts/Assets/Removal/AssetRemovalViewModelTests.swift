// Copyright 2019 Algorand, Inc.

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
//  AssetRemovalViewModelTests.swift

import XCTest

@testable import algorand_staging

class AssetRemovalViewModelTests: XCTestCase {

    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")

    func testActionColor() {
        let viewModel = AssetRemovalViewModel(assetDetail: assetDetail)
        XCTAssertEqual(viewModel.actionColor, Colors.General.error)
    }

    func testActionText() {
        let viewModel = AssetRemovalViewModel(assetDetail: assetDetail)
        XCTAssertEqual(viewModel.actionText, "title-remove".localized)
    }
}
