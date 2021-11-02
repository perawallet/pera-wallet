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
//  Transaction.swift

import Magpie

protocol TransactionItem {}

class Transaction: Model, TransactionItem {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closeRewards = try container.decodeIfPresent(UInt64.self, forKey: .closeRewards)
        closeAmount = try container.decodeIfPresent(UInt64.self, forKey: .closeAmount)
        confirmedRound = try container.decodeIfPresent(UInt64.self, forKey: .confirmedRound)
        fee = try container.decodeIfPresent(UInt64.self, forKey: .fee)
        firstRound = try container.decodeIfPresent(UInt64.self, forKey: .firstRound)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        lastRound = try container.decodeIfPresent(UInt64.self, forKey: .lastRound)
        note = try container.decodeIfPresent(Data.self, forKey: .note)
        payment = try container.decodeIfPresent(Payment.self, forKey: .payment)
        receiverRewards = try container.decodeIfPresent(UInt64.self, forKey: .receiverRewards)
        sender = try container.decodeIfPresent(String.self, forKey: .sender)
        senderRewards = try container.decodeIfPresent(UInt64.self, forKey: .senderRewards)
        type = try container.decodeIfPresent(TransferType.self, forKey: .type)
        createdAssetId = try container.decodeIfPresent(Int64.self, forKey: .createdAssetId)
        assetFreeze = try container.decodeIfPresent(AssetFreezeTransaction.self, forKey: .assetFreeze)
        assetConfig = try container.decodeIfPresent(AssetConfigTransaction.self, forKey: .assetConfig)
        assetTransfer = try container.decodeIfPresent(AssetTransferTransaction.self, forKey: .assetTransfer)
        transactionSignature = try container.decodeIfPresent(TransactionSignature.self, forKey: .transactionSignature)
        
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .date) {
            date = Date(timeIntervalSince1970: timestamp)
        } else {
            date = nil
        }
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
    
    func isAssetAdditionTransaction(for address: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        
        return assetTransfer.receiverAddress == address && assetTransfer.amount == 0 && type == .assetTransfer
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
}

extension Transaction {
    enum CodingKeys: String, CodingKey {
        case closeRewards = "close-rewards"
        case closeAmount = "closing-amount"
        case confirmedRound = "confirmed-round"
        case fee = "fee"
        case firstRound = "first-valid"
        case id = "id"
        case lastRound = "last-valid"
        case note = "note"
        case payment = "payment-transaction"
        case receiverRewards = "receiver-rewards"
        case sender = "sender"
        case senderRewards = "sender-rewards"
        case type = "tx-type"
        case createdAssetId = "created-asset-index"
        case assetFreeze = "asset-freeze-transaction"
        case assetConfig = "asset-config-transaction"
        case assetTransfer = "asset-transfer-transaction"
        case date = "round-time"
        case transactionSignature = "signature"
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
    enum TransferType: String, Model {
        case payment = "pay"
        case keyreg = "keyreg"
        case assetConfig = "acfg"
        case assetTransfer = "axfer"
        case assetFreeze = "afrz"
        case applicationCall = "appl"
    }
}

extension Transaction {
    enum Constant {
        static let minimumFee: UInt64 = 1000
    }
}

extension Transaction {
    func isAssetCreationTransaction(for account: String) -> Bool {
        guard let assetTransfer = assetTransfer else {
            return false
        }
        return assetTransfer.receiverAddress == account && assetTransfer.amount == 0
    }
}
