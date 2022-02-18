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
//  LedgerTransactionErrorLog.swift

import Foundation

struct LedgerTransactionErrorLog: AnalyticsLog {
    var name: AnalyticsLogName = .ledgerTransactionError
    var params: AnalyticsParameters
    
    init(account: Account, transactionData: TransactionData) {
        params = [
            .sender: account.address,
            .unsignedTransaction: transactionData.unsignedTransaction?.base64EncodedString() ?? "",
            .signedTransaction: transactionData.signedTransaction?.base64EncodedString() ?? ""
        ]
    }
}
