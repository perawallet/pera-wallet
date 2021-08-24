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
//   WCTransactionDetail.swift

import Magpie

class WCTransactionDetail: Model {
    let fee: Int64?
    let firstValidRound: Int64?
    let lastValidRound: Int64?
    let genesisHashData: Data?
    let genesisId: String?
    let note: Data?

    private(set) var sender: String?
    let type: Transaction.TransferType?

    private let algosAmount: Int64?
    private let assetAmount: Int64?
    var amount: Int64 {
        return assetAmount ?? algosAmount ?? 0
    }

    private var assetReceiver: String?
    private var algosReceiver: String?
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }

    private var assetCloseAddress: String?
    private var algosCloseAddress: String?
    var closeAddress: String? {
        return assetCloseAddress ?? algosCloseAddress
    }

    private(set) var rekeyAddress: String?
    let assetId: Int64?

    let appCallArguments: [String]?
    let appCallOnComplete: AppCallOnComplete?
    let appCallId: Int64?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fee = try container.decodeIfPresent(Int64.self, forKey: .fee)
        firstValidRound = try container.decodeIfPresent(Int64.self, forKey: .firstValidRound)
        lastValidRound = try container.decodeIfPresent(Int64.self, forKey: .lastValidRound)
        if let genesisHashBase64String = try container.decodeIfPresent(String.self, forKey: .genesisHash) {
            genesisHashData = Data(base64Encoded: genesisHashBase64String)
        } else {
            genesisHashData = nil
        }
        genesisId = try container.decodeIfPresent(String.self, forKey: .genesisId)
        note = try container.decodeIfPresent(Data.self, forKey: .note)
        type = try container.decodeIfPresent(Transaction.TransferType.self, forKey: .type)
        assetAmount = try container.decodeIfPresent(Int64.self, forKey: .assetAmount)
        algosAmount = try container.decodeIfPresent(Int64.self, forKey: .algosAmount)
        assetId = try container.decodeIfPresent(Int64.self, forKey: .assetId)
        appCallArguments = try container.decodeIfPresent([String].self, forKey: .appCallArguments)
        appCallOnComplete = try container.decodeIfPresent(AppCallOnComplete.self, forKey: .appCallOnComplete) ?? .noOp
        appCallId = try container.decodeIfPresent(Int64.self, forKey: .appCallId) ?? 0

        if let senderMsgpack = try container.decodeIfPresent(Data.self, forKey: .sender) {
            sender = parseAddress(from: senderMsgpack)
        }

        if let assetReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetReceiver) {
            assetReceiver = parseAddress(from: assetReceiverMsgpack)
        } else

        if let algosReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosReceiver) {
            algosReceiver = parseAddress(from: algosReceiverMsgpack)
        }

        if let assetCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetCloseAddress) {
            assetCloseAddress = parseAddress(from: assetCloseAddressMsgpack)
        }

        if let algosCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosCloseAddress) {
            algosCloseAddress = parseAddress(from: algosCloseAddressMsgpack)
        }

        if let rekeyAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .rekeyAddress) {
            rekeyAddress = parseAddress(from: rekeyAddressMsgpack)
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
        try container.encodeIfPresent(assetCloseAddress, forKey: .assetCloseAddress)
        try container.encodeIfPresent(algosCloseAddress, forKey: .algosCloseAddress)
        try container.encodeIfPresent(rekeyAddress, forKey: .rekeyAddress)
        try container.encodeIfPresent(assetId, forKey: .assetId)
        try container.encodeIfPresent(appCallArguments, forKey: .appCallArguments)
        try container.encodeIfPresent(appCallOnComplete, forKey: .appCallOnComplete)
        try container.encodeIfPresent(appCallId, forKey: .appCallId)
    }
}

extension WCTransactionDetail {
    func transactionType(for account: Account?) -> WCTransactionType? {
        if isAppCallTransaction {
            return .appCall
        }

        if let account = account,
           isAssetAdditionTransaction(for: account) {
            return .assetAddition
        }

        if isAssetAdditionTransaction() {
            return .possibleAssetAddition
        }

        if isAssetTransaction {
            return .asset
        }

        if isAlgosTransaction {
            return .algos
        }

        return nil
    }

    var isAlgosTransaction: Bool {
        return type == .payment
    }

    var isAssetTransaction: Bool {
        return type == .assetTransfer
    }

    func isAssetAdditionTransaction(for account: Account) -> Bool {
        guard let assetId = assetId else {
            return false
        }

        return isAssetAdditionTransaction() && !account.containsAsset(assetId)
    }

    func isAssetAdditionTransaction() -> Bool {
        return type == .assetTransfer &&
            (assetAmount == nil || assetAmount == 0) &&
            sender == assetReceiver
    }

    var isAppCallTransaction: Bool {
        return type == .applicationCall
    }

    var hasRekeyOrCloseAddress: Bool {
        return isRekeyTransaction || isCloseTransaction
    }

    var isRekeyTransaction: Bool {
        return rekeyAddress != nil
    }

    var isCloseTransaction: Bool {
        return closeAddress != nil
    }

    func noteRepresentation() -> String? {
        guard let noteData = note, !noteData.isEmpty else {
            return nil
        }

        return String(data: noteData, encoding: .utf8) ?? noteData.base64EncodedString()
    }

    var isSupportedAppCallTransaction: Bool {
        guard let appCallOnComplete = appCallOnComplete else {
            return false
        }

        return appCallId != 0 && (
            appCallOnComplete == .noOp ||
                appCallOnComplete == .optIn ||
                appCallOnComplete == .close ||
                appCallOnComplete == .clearState
        )
    }

    var validationAddresses: [String?] {
        return [sender, receiver, closeAddress, rekeyAddress]
    }

    var hasHighFee: Bool {
        guard let fee = fee else {
            return false
        }

         return fee > Transaction.Constant.minimumFee
    }
}

extension WCTransactionDetail {
    private func parseAddress(from msgpack: Data) -> String? {
        var error: NSError?
        let addressString = AlgorandSDK().addressFromPublicKey(msgpack, error: &error)
        return error == nil ? addressString : nil
    }
}

extension WCTransactionDetail {
    enum AppCallOnComplete: Int, Codable {
        case noOp = 0
        case optIn = 1
        case close = 2
        case clearState = 3
        case update = 4
        case delete = 5

        var representation: String {
            switch self {
            case .noOp:
                return "NoOp"
            case .optIn:
                return "OptIn"
            case .close:
                return "CloseOut"
            case .clearState:
                return "ClearState"
            case .update:
                return "UpdateApplication"
            case .delete:
                return "DeleteApplication"
            }
        }
    }
}

extension WCTransactionDetail {
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
        case assetCloseAddress = "aclose"
        case algosCloseAddress = "close"
        case rekeyAddress = "rekey"
        case assetId = "xaid"
        case appCallArguments = "apaa"
        case appCallOnComplete = "apan"
        case appCallId = "apid"
    }
}

extension WCTransactionDetail: Equatable {
    static func == (lhs: WCTransactionDetail, rhs: WCTransactionDetail) -> Bool {
        return lhs.firstValidRound == rhs.firstValidRound &&
            lhs.lastValidRound == rhs.lastValidRound &&
            lhs.sender == rhs.sender &&
            lhs.receiver == rhs.receiver &&
            lhs.amount == rhs.amount &&
            lhs.genesisHashData == rhs.genesisHashData &&
            lhs.type == rhs.type
    }
}
