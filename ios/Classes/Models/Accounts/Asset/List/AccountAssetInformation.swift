// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountAssetInformation.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AccountAssetInformation: ALGEntityModel {
    let id: Int64
    let amount: UInt64

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.assetHolding?.id ?? -1
        self.amount = apiModel.assetHolding?.amount ?? .zero
    }

  func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetHolding?.id = id
        apiModel.assetHolding?.amount = amount
        return apiModel
    }
}

extension AccountAssetInformation {
    struct APIModel: ALGAPIModel {
        var assetHolding: AssetHolding?

        init() {
            self.assetHolding = nil
        }

        private enum CodingKeys: 
            String,
            CodingKey {
            case assetHolding = "asset-holding"
        }
    }

    struct AssetHolding: ALGAPIModel {
        var id: Int64?
        var amount: UInt64?

        init() {
            self.id = nil
            self.amount = nil
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case id = "asset-id"
            case amount
        }
    }
}
