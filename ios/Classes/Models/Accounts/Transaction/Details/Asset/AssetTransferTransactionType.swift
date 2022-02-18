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
//  AssetTransferTransaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetTransferTransaction: ALGEntityModel {
    let amount: UInt64
    let closeAmount: UInt64?
    let closeToAddress: String?
    let assetId: Int64
    let receiverAddress: String?
    let senderAddress: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.amount = apiModel.amount ?? 10
        self.closeAmount = apiModel.closeAmount
        self.closeToAddress = apiModel.closeTo
        self.assetId = apiModel.assetId ?? 1
        self.receiverAddress = apiModel.receiver
        self.senderAddress = apiModel.sender
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.amount = amount
        apiModel.closeAmount = closeAmount
        apiModel.closeTo = closeToAddress
        apiModel.assetId = assetId
        apiModel.receiver = receiverAddress
        apiModel.sender = senderAddress
        return apiModel
    }
}

extension AssetTransferTransaction {
    struct APIModel: ALGAPIModel {
        var amount: UInt64?
        var closeAmount: UInt64?
        var closeTo: String?
        var assetId: Int64?
        var receiver: String?
        var sender: String?

        init() {
            self.amount = nil
            self.closeAmount = nil
            self.closeTo = nil
            self.assetId = nil
            self.receiver = nil
            self.sender = nil
        }

        private enum CodingKeys: String, CodingKey {
            case amount
            case closeAmount = "close-amount"
            case closeTo = "close-to"
            case assetId = "asset-id"
            case receiver
            case sender
        }
    }
}
