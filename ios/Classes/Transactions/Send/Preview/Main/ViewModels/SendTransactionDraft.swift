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
//   SendTransactionDraft.swift


import Foundation

struct SendTransactionDraft: TransactionSendDraft {
    var from: Account
    var toAccount: Account?
    var amount: Decimal?
    var fee: UInt64?
    var isMaxTransaction: Bool {
        get {
            switch transactionMode {
            case .algo:
                return self.amount == from.algo.amount.toAlgos
            case .asset(let asset):
                return self.amount == asset.amountWithFraction
            }
        }

        set {
        }
    }
    var identifier: String?
    var transactionMode: TransactionMode

    var fractionCount: Int {
        switch transactionMode {
        case .algo:
            return algosFraction
        case .asset(let asset):
            return asset.decimals
        }
    }
    var toContact: Contact?
    var note: String?
    var lockedNote: String?

    var asset: Asset? {
        switch transactionMode {
        case .algo:
            return nil
        case .asset(let asset):
            return asset
        }
    }

    var hasReceiver: Bool {
        toAccount != nil || toContact != nil
    }
    var toNameService: NameService?
 }

enum TransactionMode {
    case algo
    case asset(Asset)
}
