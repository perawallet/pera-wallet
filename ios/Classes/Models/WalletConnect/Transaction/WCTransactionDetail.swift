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
//   WCTransactionDetail.swift

import Foundation

final class WCTransactionDetail: Codable {
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
    let appGlobalSchema: WCTransactionAppSchema?
    let appLocalSchema: WCTransactionAppSchema?
    let appExtraPages: Int?
    let approvalHash: Data?
    let stateHash: Data?
    let assetIdBeingConfigured: Int64?
    let assetConfigParams: WCAssetConfigParameters?
    let transactionGroupId: String?

    /// <mark> KeyReg txn
    let votePublicKey: String?
    let selectionPublicKey: String?
    let stateProofPublicKey: String?
    let voteFirstValidRound: UInt64?
    let voteLastValidRound: UInt64?
    let voteKeyDilution: UInt64?
    let nonParticipation: Bool

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
        appCallArguments = try container.decodeIfPresent([String].self, forKey: .appCallArguments)
        appCallOnComplete = try container.decodeIfPresent(AppCallOnComplete.self, forKey: .appCallOnComplete) ?? .noOp
        appCallId = try container.decodeIfPresent(Int64.self, forKey: .appCallId) ?? 0
        approvalHash = try container.decodeIfPresent(Data.self, forKey: .approvalHash)
        stateHash = try container.decodeIfPresent(Data.self, forKey: .stateHash)
        transactionGroupId = try container.decodeIfPresent(String.self, forKey: .transactionGroupId)

        if type == .applicationCall {
            let defaultAppSchema = WCTransactionAppSchema()
            appGlobalSchema = try container.decodeIfPresent(WCTransactionAppSchema.self, forKey: .appGlobalSchema) ?? defaultAppSchema
            appLocalSchema = try container.decodeIfPresent(WCTransactionAppSchema.self, forKey: .appLocalSchema) ?? defaultAppSchema
            appExtraPages = try container.decodeIfPresent(Int.self, forKey: .appExtraPages) ?? 0
        } else {
            appGlobalSchema = nil
            appLocalSchema = nil
            appExtraPages = nil
        }

        assetIdBeingConfigured = try container.decodeIfPresent(Int64.self, forKey: .assetIdBeingConfigured)
        assetConfigParams = try container.decodeIfPresent(WCAssetConfigParameters.self, forKey: .assetConfigParams)

        if let senderMsgpack = try container.decodeIfPresent(Data.self, forKey: .sender) {
            sender = senderMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let assetReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetReceiver) {
            assetReceiver = assetReceiverMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let algosReceiverMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosReceiver) {
            algosReceiver = algosReceiverMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let assetCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .assetCloseAddress) {
            assetCloseAddress = assetCloseAddressMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let algosCloseAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .algosCloseAddress) {
            algosCloseAddress = algosCloseAddressMsgpack.getAlgorandAddressFromPublicKey()
        }

        if let rekeyAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .rekeyAddress) {
            rekeyAddress = rekeyAddressMsgpack.getAlgorandAddressFromPublicKey()
        }

        votePublicKey = try container.decodeIfPresent(String.self, forKey: .votePublicKey)
        selectionPublicKey = try container.decodeIfPresent(String.self, forKey: .selectionPublicKey)
        stateProofPublicKey = try container.decodeIfPresent(String.self, forKey: .stateProofPublicKey)
        voteFirstValidRound = try container.decodeIfPresent(UInt64.self, forKey: .voteFirstValidRound)
        voteLastValidRound = try container.decodeIfPresent(UInt64.self, forKey: .voteLastValidRound)
        voteKeyDilution = try container.decodeIfPresent(UInt64.self, forKey: .voteKeyDilution)
        nonParticipation = (try container.decodeIfPresent(Bool.self, forKey: .nonParticipation)) ?? Self.nonParticipationDefaultValue
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
        try container.encodeIfPresent(appGlobalSchema, forKey: .appGlobalSchema)
        try container.encodeIfPresent(appLocalSchema, forKey: .appLocalSchema)
        try container.encodeIfPresent(appExtraPages, forKey: .appExtraPages)
        try container.encodeIfPresent(approvalHash, forKey: .approvalHash)
        try container.encodeIfPresent(stateHash, forKey: .stateHash)
        try container.encodeIfPresent(assetIdBeingConfigured, forKey: .assetIdBeingConfigured)
        try container.encodeIfPresent(assetConfigParams, forKey: .assetConfigParams)
        try container.encodeIfPresent(transactionGroupId, forKey: .transactionGroupId)
        try container.encodeIfPresent(votePublicKey, forKey: .votePublicKey)
        try container.encodeIfPresent(selectionPublicKey, forKey: .selectionPublicKey)
        try container.encodeIfPresent(stateProofPublicKey, forKey: .stateProofPublicKey)
        try container.encodeIfPresent(voteFirstValidRound, forKey: .voteFirstValidRound)
        try container.encodeIfPresent(voteLastValidRound, forKey: .voteLastValidRound)
        try container.encodeIfPresent(voteKeyDilution, forKey: .voteKeyDilution)
        try container.encodeIfPresent(nonParticipation, forKey: .nonParticipation)
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

        if isAssetConfigTransaction {
            if isAssetCreationTransaction {
                return .assetConfig(type: .create)
            }

            if isAssetReconfigurationTransaction {
                return .assetConfig(type: .reconfig)
            }

            if isAssetDeletionTransaction {
                return .assetConfig(type: .delete)
            }
        }

        if isKeyregTransaction {
            return .keyReg
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
        return type == .assetTransfer && amount == 0 && sender == assetReceiver
    }

    var isAppCallTransaction: Bool {
        return type == .applicationCall
    }

    var isAssetConfigTransaction: Bool {
        return type == .assetConfig
    }

    var isAssetCreationTransaction: Bool {
        return type == .assetConfig && (assetIdBeingConfigured == 0 || assetIdBeingConfigured == nil)
     }

    var isAssetReconfigurationTransaction: Bool {
         return type == .assetConfig && assetConfigParams != nil && assetIdBeingConfigured != 0
     }

     var isAssetDeletionTransaction: Bool {
         return type == .assetConfig && assetConfigParams == nil && assetIdBeingConfigured != 0
     }

    var isKeyregTransaction: Bool {
        return type == .keyReg
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

    var isAppCreateTransaction: Bool {
        return isAppCallTransaction && appCallId == 0
    }

    var validationAddresses: [String?] {
        return [
            sender,
            receiver,
            closeAddress,
            rekeyAddress,
            assetConfigParams?.managerAddress,
            assetConfigParams?.reserveAddress,
            assetConfigParams?.frozenAddress,
            assetConfigParams?.clawbackAddress
        ]
    }

    var hasHighFee: Bool {
        guard let fee = fee else {
            return false
        }

         return fee > Transaction.Constant.minimumFee
    }

    var currentAssetId: Int64? {
        return assetId ?? assetIdBeingConfigured
    }

    var warningCount: Int {
        var count = 0

        if hasHighFee {
            count += 1
        }

        if rekeyAddress != nil {
            count += 1
        }

        if closeAddress != nil {
            count += 1
        }
        
        return count
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
                return "Update"
            case .delete:
                return "Delete"
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
        case appGlobalSchema = "apgs"
        case appLocalSchema = "apls"
        case appExtraPages = "apep"
        case approvalHash = "apap"
        case stateHash = "apsu"
        case assetIdBeingConfigured = "caid"
        case assetConfigParams = "apar"
        case transactionGroupId = "grp"
        case votePublicKey = "votekey"
        case selectionPublicKey = "selkey"
        case stateProofPublicKey = "sprfkey"
        case voteFirstValidRound = "votefst"
        case voteLastValidRound = "votelst"
        case voteKeyDilution = "votekd"
        case nonParticipation = "nonpart"
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

final class WCTransactionAppSchema: Codable {
    let numberOfBytes: Int?
    let numberofInts: Int?

    init() {
        numberOfBytes = 0
        numberofInts = 0
    }

    var representation: String {
        let numberOfBytes = numberOfBytes ?? 0
        let numberOfInts = numberofInts ?? 0
        return "\(numberOfBytes) Bytes / \(numberOfInts) Uint"
    }
}

extension WCTransactionAppSchema {
    private enum CodingKeys: String, CodingKey {
        case numberOfBytes = "nbs"
        case numberofInts = "nui"
    }
}

/// <note>
/// Key Registration Transaction
extension WCTransactionDetail {
    var isOnlineKeyRegTransaction: Bool {
        guard
            let votePublicKey,
            let selectionPublicKey,
            voteKeyDilution != nil,
            voteFirstValidRound != nil,
            voteLastValidRound != nil
        else {
            return false
        }

        return !votePublicKey.isEmptyOrBlank && !selectionPublicKey.isEmptyOrBlank
    }

    /// <note>
    /// All new Algorand accounts are participating by default.
    /// https://developer.algorand.org/docs/get-details/transactions/transactions/?from_query=key%20registration#key-registration-transaction
    private static let nonParticipationDefaultValue = false
}
