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
//  TransactionParams.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class TransactionParams: ALGEntityModel {
    let fee: UInt64
    let minFee: UInt64
    let lastRound: UInt64
    let genesisHashData: Data?
    let genesisId: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.fee = apiModel.fee ?? 0
        self.minFee = apiModel.minFee ?? 0
        self.lastRound = apiModel.lastRound ?? 0
        self.genesisHashData = apiModel.genesisHash.unwrap { Data(base64Encoded: $0) }
        self.genesisId = apiModel.genesisId
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.fee = fee
        apiModel.minFee = minFee
        apiModel.lastRound = lastRound
        apiModel.genesisHash = genesisHashData?.base64EncodedString()
        apiModel.genesisId = genesisId
        return apiModel
    }
}

extension TransactionParams {
    func getProjectedTransactionFee(from dataSize: Int? = nil) -> UInt64 {
        if let dataSize = dataSize {
            return max(UInt64(dataSize) * fee, Transaction.Constant.minimumFee)
        }
        return max(dataSizeForMaxTransaction * fee, Transaction.Constant.minimumFee)
    }
}

extension TransactionParams {
    struct APIModel: ALGAPIModel {
        var lastRound: UInt64?
        var fee: UInt64?
        var minFee: UInt64?
        var genesisHash: String?
        var genesisId: String?

        init() {
            self.lastRound = nil
            self.fee = nil
            self.minFee = nil
            self.genesisHash = nil
            self.genesisId = nil
        }

        private enum CodingKeys: String, CodingKey {
            case lastRound = "last-round"
            case fee = "fee"
            case minFee = "min-fee"
            case genesisHash = "genesis-hash"
            case genesisId = "genesis-id"
        }
    }
}
