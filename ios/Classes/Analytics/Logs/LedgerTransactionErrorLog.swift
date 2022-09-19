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

//  LedgerTransactionErrorLog.swift

import Foundation
import MacaroonVendors

/// <note>: NonAcceptanceLedgerTransactionErrorLog description below
/// When transaction uploaded to blockchain, blockchain returns transaction id.
/// If it's not available, transaction must be rejected by blockchain
/// To figure this out, we are logging the unsigned and signed transaction and compare them.
struct NonAcceptanceLedgerTransactionErrorLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        account: Account,
        transactionData: TransactionData
    ) {
        let transactionValue = transactionData.signedTransaction?.base64EncodedString() ?? ""
        let uTransactionValue = transactionData.unsignedTransaction?.base64EncodedString() ?? ""

        self.name = .ledgerTransactionError
        self.metadata = [
            .senderAccountAddress: account.address,
            .signedTransaction: transactionValue,
            .unsignedTransaction: uTransactionValue
        ]
    }
}

extension ALGAnalyticsLog where Self == NonAcceptanceLedgerTransactionErrorLog {
    static func nonAcceptanceLedgerTransaction(
        account: Account,
        transactionData: TransactionData
    ) -> Self {
        return NonAcceptanceLedgerTransactionErrorLog(
            account: account,
            transactionData: transactionData
        )
    }
}
