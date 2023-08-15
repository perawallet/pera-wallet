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
//  LedgerTransactionSigner.swift

import Foundation

class LedgerTransactionSigner: TransactionSigner {

    private var account: Account

    init(account: Account) {
        self.account = account
        super.init()
    }

    override func sign(_ data: Data?, with privateData: Data?) -> Data? {
        return signTransaction(data, with: privateData)
    }
}

extension LedgerTransactionSigner {
    private func signTransaction(_ data: Data?, with privateData: Data?) -> Data? {
        var transactionError: NSError?

        guard let transactionData = data,
              let privateData = privateData else {
                  delegate?.transactionSigner(self, didFailedSigning: .inapp(.sdkError(error: transactionError)))
            return nil
        }

        if account.hasAuthAccount() {
            return signRekeyedAccountTransaction(transactionData, with: privateData, transactionError: &transactionError)
        } else {
            return signLedgerAccountTransaction(transactionData, with: privateData, transactionError: &transactionError)
        }
    }

    private func signRekeyedAccountTransaction(_ transactionData: Data, with privateData: Data, transactionError: inout NSError?) -> Data? {
        guard let signedTransactionData = algorandSDK.getSignedTransaction(
            with: account.authAddress,
            transaction: transactionData,
            from: privateData,
            error: &transactionError
        ) else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return signedTransactionData
    }

    private func signLedgerAccountTransaction(_ transactionData: Data, with privateData: Data, transactionError: inout NSError?) -> Data? {
        guard let signedTransactionData = algorandSDK.getSignedTransaction(
            transactionData,
            from: privateData,
            error: &transactionError
        ) else {
            delegate?.transactionSigner(self, didFailedSigning: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return signedTransactionData
    }
}
