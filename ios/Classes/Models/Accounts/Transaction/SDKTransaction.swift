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

//   SDKTransaction.swift

import Foundation

final class SDKTransaction: Codable {
    let fee: UInt64?
    let firstValidRound: UInt64?
    let lastValidRound: UInt64?
    let genesisHashData: Data?
    let genesisId: String?
    let note: Data?

    private(set) var sender: String?
    let type: TransactionType?

    private let algosAmount: UInt64?
    private let assetAmount: UInt64?
    var amount: UInt64 {
        return assetAmount ?? algosAmount ?? 0
    }

    private var assetReceiver: String?
    private var algosReceiver: String?
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }

    let assetId: Int64?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fee = try container.decodeIfPresent(UInt64.self, forKey: .fee)
        firstValidRound = try container.decodeIfPresent(UInt64.self, forKey: .firstValidRound)
        lastValidRound = try container.decodeIfPresent(UInt64.self, forKey: .lastValidRound)
        if let genesisHashBase64String = try container.decodeIfPresent(String.self, forKey: .genesisHash) {
            genesisHashData = Data(base64Encoded: genesisHashBase64String)
        } else {
            genesisHashData = nil
        }
        genesisId = try container.decodeIfPresent(String.self, forKey: .genesisId)
        note = try container.decodeIfPresent(Data.self, forKey: .note)
        type = try container.decodeIfPresent(TransactionType.self, forKey: .type)
        assetAmount = try container.decodeIfPresent(UInt64.self, forKey: .assetAmount)
        algosAmount = try container.decodeIfPresent(UInt64.self, forKey: .algosAmount)
        assetId = try container.decodeIfPresent(Int64.self, forKey: .assetId)

        if let senderMsgpack = try container.decodeIfPresent(Data.self, forKey: .sender) {
            sender = senderMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let assetReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetReceiver) {
            assetReceiver = assetReceiverMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let algosReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosReceiver) {
            algosReceiver = algosReceiverMsgpack.getAlgorandAddressFromPublicKey()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fee, forKey: .fee)
        try container.encodeIfPresent(firstValidRound, forKey: .firstValidRound)
        try container.encodeIfPresent(lastValidRound, forKey: .lastValidRound)
        try container.encodeIfPresent(genesisHashData, forKey: .genesisHash)
        try container.encodeIfPresent(genesisId, forKey: .genesisId)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(assetAmount, forKey: .assetAmount)
        try container.encodeIfPresent(algosAmount, forKey: .algosAmount)
        try container.encodeIfPresent(assetReceiver, forKey: .assetReceiver)
        try container.encodeIfPresent(algosReceiver, forKey: .algosReceiver)
        try container.encodeIfPresent(assetId, forKey: .assetId)
    }
}

extension SDKTransaction {
    private enum CodingKeys: String, CodingKey {
        case fee = "fee"
        case firstValidRound = "fv"
        case lastValidRound = "lv"
        case genesisId = "gen"
        case genesisHash = "gh"
        case note = "note"
        case sender = "snd"
        case type = "type"
        case assetAmount = "amt"
        case algosAmount = "aamt"
        case assetReceiver = "arcv"
        case algosReceiver = "rcv"
        case rekeyAddress = "rekey"
        case assetId = "xaid"
    }
}

extension SDKTransaction: Equatable {
    static func == (lhs: SDKTransaction, rhs: SDKTransaction) -> Bool {
        return lhs.firstValidRound == rhs.firstValidRound &&
            lhs.lastValidRound == rhs.lastValidRound &&
            lhs.sender == rhs.sender &&
            lhs.receiver == rhs.receiver &&
            lhs.amount == rhs.amount &&
            lhs.genesisHashData == rhs.genesisHashData &&
            lhs.type == rhs.type
    }
}
