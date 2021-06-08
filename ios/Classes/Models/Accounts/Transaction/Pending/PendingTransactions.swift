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
//  PendingTransactions.swift

import Magpie

class PendingTransaction: Model, TransactionItem {
    let signature: String?
    private let algosAmount: Int64?
    private let assetAmount: Int64?
    let fee: Int64?
    let fv: Int64?
    let gh: String?
    let lv: Int64?
    private let assetReceiver: String?
    private let algosReceiver: String?
    let sender: String?
    let type: Transaction.TransferType?
    
    var amount: Int64 {
        return assetAmount ?? algosAmount ?? 0
    }
    
    var receiver: String? {
        return assetReceiver ?? algosReceiver
    }
    
    var contact: Contact?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
        let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        
        algosAmount = try transactionContainer.decodeIfPresent(Int64.self, forKey: .algosAmount)
        assetAmount = try transactionContainer.decodeIfPresent(Int64.self, forKey: .assetAmount)
        fee = try transactionContainer.decodeIfPresent(Int64.self, forKey: .fee)
        fv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .fv)
        gh = try transactionContainer.decodeIfPresent(String.self, forKey: .gh)
        lv = try transactionContainer.decodeIfPresent(Int64.self, forKey: .lv)
        algosReceiver = try transactionContainer.decodeIfPresent(String.self, forKey: .algosReceiver)
        assetReceiver = try transactionContainer.decodeIfPresent(String.self, forKey: .assetReceiver)
        sender = try transactionContainer.decodeIfPresent(String.self, forKey: .sender)
        type = try transactionContainer.decodeIfPresent(Transaction.TransferType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(signature, forKey: .signature)
        
        var transactionContainer = container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
        try transactionContainer.encodeIfPresent(algosAmount, forKey: .algosAmount)
        try transactionContainer.encodeIfPresent(assetAmount, forKey: .assetAmount)
        try transactionContainer.encodeIfPresent(fee, forKey: .fee)
        try transactionContainer.encodeIfPresent(fv, forKey: .fv)
        try transactionContainer.encodeIfPresent(gh, forKey: .gh)
        try transactionContainer.encodeIfPresent(lv, forKey: .lv)
        try transactionContainer.encodeIfPresent(algosReceiver, forKey: .algosReceiver)
        try transactionContainer.encodeIfPresent(assetReceiver, forKey: .assetReceiver)
        try transactionContainer.encodeIfPresent(sender, forKey: .sender)
        try transactionContainer.encodeIfPresent(type, forKey: .type)
    }
}

extension PendingTransaction {
    private enum CodingKeys: String, CodingKey {
        case signature = "sig"
        case transaction = "txn"
    }
    
    private enum TransactionCodingKeys: String, CodingKey {
        case assetAmount = "amt"
        case algosAmount = "aamt"
        case fee = "fee"
        case fv = "fv"
        case gh = "gh"
        case lv = "lv"
        case algosReceiver = "rcv"
        case assetReceiver = "arcv"
        case sender = "snd"
        case type = "type"
    }
}
