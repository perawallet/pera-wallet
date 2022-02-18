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
//   AssetCreator.swift

import Foundation
import MagpieCore

final class AssetCreator: ALGEntityModel {
    let id: Int64
    let address: String
    let isVerifiedAssetCreator: Bool

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id
        self.address = apiModel.address
        self.isVerifiedAssetCreator = apiModel.isVerifiedAssetCreator
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.address = address
        apiModel.isVerifiedAssetCreator = isVerifiedAssetCreator
        return apiModel
    }
}

extension AssetCreator {
    struct APIModel: ALGAPIModel {
        var id: Int64
        var address: String
        var isVerifiedAssetCreator: Bool

        init() {
            self.id = 0
            self.address = ""
            self.isVerifiedAssetCreator = false
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case address
            case isVerifiedAssetCreator = "is_verified_asset_creator"
        }
    }
}
