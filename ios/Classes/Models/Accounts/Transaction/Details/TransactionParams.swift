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
//  TransactionParams.swift

import Magpie

class TransactionParams: Model {
    let fee: Int64
    let minFee: Int64
    let lastRound: Int64
    let genesisHashData: Data?
    let genesisId: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fee = try container.decode(Int64.self, forKey: .fee)
        minFee = try container.decode(Int64.self, forKey: .minFee)
        lastRound = try container.decode(Int64.self, forKey: .lastRound)
        if let genesisHashBase64String = try container.decodeIfPresent(String.self, forKey: .genesisHash) {
            genesisHashData = Data(base64Encoded: genesisHashBase64String)
        } else {
            genesisHashData = nil
        }
        genesisId = try container.decode(String.self, forKey: .genesisId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fee, forKey: .fee)
        try container.encode(minFee, forKey: .minFee)
        try container.encode(lastRound, forKey: .lastRound)
        try container.encodeIfPresent(genesisHashData, forKey: .genesisHash)
        try container.encodeIfPresent(genesisId, forKey: .genesisId)
    }
    
    func getProjectedTransactionFee(from dataSize: Int? = nil) -> Int64 {
        if let dataSize = dataSize {
            return max(Int64(dataSize) * fee, Transaction.Constant.minimumFee)
        }
        return max(dataSizeForMaxTransaction * fee, Transaction.Constant.minimumFee)
    }
}

extension TransactionParams {
    private enum CodingKeys: String, CodingKey {
        case lastRound = "last-round"
        case fee = "fee"
        case minFee = "min-fee"
        case genesisHash = "genesis-hash"
        case genesisId = "genesis-id"
    }
}
