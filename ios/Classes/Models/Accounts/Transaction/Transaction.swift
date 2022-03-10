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
//  Transaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

protocol TransactionItem {
    var date: Date? { get }
}

extension TransactionItem {
    var date: Date? {
        return nil
    }
}

final class Transaction:
    ALGEntityModel,
    TransactionItem {
    let closeRewards: UInt64?
    let closeAmount: UInt64?
    let confirmedRound: UInt64?
    let fee: UInt64?
    let firstRound: UInt64?
    let id: String?
    let lastRound: UInt64?
    let note: Data?
    let payment: Payment?
    let receiverRewards: UInt64?
    let sender: String?
    let senderRewards: UInt64?
    let type: TransferType?
    let createdAssetId: Int64?
    let assetFreeze: AssetFreezeTransaction?
    let assetConfig: AssetConfigTransaction?
    let assetTransfer: AssetTransferTransaction?
    let date: Date?
    let transactionSignature: TransactionSignature?
    
    var status: Status?
    var contact: Contact?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.closeRewards = apiModel.closeRewards
        self.closeAmount = apiModel.closeAmount
        self.confirmedRound = apiModel.confirmedRound
        self.fee = apiModel.fee
        self.firstRound = apiModel.firstValid
        self.id = apiModel.id
        self.lastRound = apiModel.lastValid
        self.note = apiModel.note
        self.payment = apiModel.paymentTransaction.unwrap(Payment.init)
        self.receiverRewards = apiModel.receiverRewards
        self.sender = apiModel.sender
        self.senderRewards = apiModel.senderRewards
        self.type = apiModel.txType
        self.createdAssetId = apiModel.createdAssetIndex
        self.assetFreeze = apiModel.assetFreezeTransaction
        self.assetConfig = apiModel.assetConfigTransaction
        self.assetTransfer = apiModel.assetTransferTransaction.unwrap(AssetTransferTransaction.init)
        self.date = apiModel.roundTime.unwrap { Date(timeIntervalSince1970: $0) }
        self.transactionSignature = apiModel.signature
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.closeRewards = closeRewards
        apiModel.closeAmount = closeAmount
        apiModel.fee = fee
        apiModel.firstValid = firstRound
        apiModel.id = id
        apiModel.lastValid = lastRound
        apiModel.note = note
        apiModel.paymentTransaction = payment?.encode()
        apiModel.receiverRewards = receiverRewards
        apiModel.sender = sender
        apiModel.senderRewards = senderRewards
        apiModel.txType = type
        apiModel.createdAssetIndex = createdAssetId
        apiModel.assetFreezeTransaction = assetFreeze
        apiModel.assetConfigTransaction = assetConfig
        apiModel.assetTransferTransaction = assetTransfer?.encode()
        apiModel.roundTime = date?.timeIntervalSince1970
        apiModel.signature = transactionSignature
        return apiModel
    }
}

extension Transaction {
    func isPending() -> Bool {
        if let status = status {
            return status == .pending
        }
        return confirmedRound == nil || confirmedRound == 0
    }

    func isSelfTransaction() -> Bool {
        return sender == getReceiver()
    }
    
    ///TODO: Code duplication should be handled
    func isAssetAdditionTransaction(for address: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        
        return assetTransfer.receiverAddress == address &&
        sender == address &&
        assetTransfer.amount == 0 &&
        type == .assetTransfer
    }
    
    func getAmount() -> UInt64? {
        return payment?.amount ?? assetTransfer?.amount
    }

    func getRewards(for account: String) -> UInt64? {
        return account == sender ? senderRewards : (account == getReceiver() ? receiverRewards : nil)
    }
    
    func getReceiver() -> String? {
        return payment?.receiver ?? assetTransfer?.receiverAddress
    }
    
    func getCloseAmount() -> UInt64? {
        return payment?.closeAmount ?? assetTransfer?.closeAmount
    }
    
    func getCloseAddress() -> String? {
        return payment?.closeAddress ?? assetTransfer?.closeToAddress
    }
    
    func noteRepresentation() -> String? {
        guard let noteData = note, !noteData.isEmpty else {
            return nil
        }
        
        return String(data: noteData, encoding: .utf8) ?? noteData.base64EncodedString()
    }

    func isAssetCreationTransaction(for account: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        return assetTransfer.receiverAddress == account &&
        assetTransfer.amount == 0 &&
        sender == account
    }
}

extension Transaction {
    enum Status: String {
        case pending = "PENDING"
        case completed = "COMPLETED"
        case failed = "FAILED"
    }
}

extension Transaction {
    enum TransferType: String, ALGAPIModel {
        case payment = "pay"
        case keyreg = "keyreg"
        case assetConfig = "acfg"
        case assetTransfer = "axfer"
        case assetFreeze = "afrz"
        case applicationCall = "appl"

        init() {
            self = .payment
        }
    }
}

extension Transaction {
    enum Constant {
        static let minimumFee: UInt64 = 1000
    }
}

extension Transaction {
    struct APIModel: ALGAPIModel {
        var closeRewards: UInt64?
        var closeAmount: UInt64?
        var confirmedRound: UInt64?
        var fee: UInt64?
        var firstValid: UInt64?
        var id: String?
        var lastValid: UInt64?
        var note: Data?
        var paymentTransaction: Payment.APIModel?
        var receiverRewards: UInt64?
        var sender: String?
        var senderRewards: UInt64?
        var txType: TransferType?
        var createdAssetIndex: Int64?
        var assetFreezeTransaction: AssetFreezeTransaction?
        var assetConfigTransaction: AssetConfigTransaction?
        var assetTransferTransaction: AssetTransferTransaction.APIModel?
        var roundTime: Double?
        var signature: TransactionSignature?

        init() {
            self.closeRewards = nil
            self.closeAmount = nil
            self.confirmedRound = nil
            self.fee = nil
            self.firstValid = nil
            self.id = nil
            self.lastValid = nil
            self.note = nil
            self.paymentTransaction = nil
            self.receiverRewards = nil
            self.sender = nil
            self.senderRewards = nil
            self.txType = nil
            self.createdAssetIndex = nil
            self.assetFreezeTransaction = nil
            self.assetConfigTransaction = nil
            self.assetTransferTransaction = nil
            self.roundTime = nil
            self.signature = nil
        }

        private enum CodingKeys: String, CodingKey {
            case closeRewards = "close-rewards"
            case closeAmount = "closing-amount"
            case confirmedRound = "confirmed-round"
            case fee
            case firstValid = "first-valid"
            case id
            case lastValid = "last-valid"
            case note
            case paymentTransaction = "payment-transaction"
            case receiverRewards = "receiver-rewards"
            case sender
            case senderRewards = "sender-rewards"
            case txType = "tx-type"
            case createdAssetIndex = "created-asset-index"
            case assetFreezeTransaction = "asset-freeze-transaction"
            case assetConfigTransaction = "asset-config-transaction"
            case assetTransferTransaction = "asset-transfer-transaction"
            case roundTime = "round-time"
            case signature
        }
    }
}
