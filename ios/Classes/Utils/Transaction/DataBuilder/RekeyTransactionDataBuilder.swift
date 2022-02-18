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
//  RekeyTransactionDataBuilder.swift

import Foundation

class RekeyTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeRekeyTransactionData()
    }

    private func composeRekeyTransactionData() -> Data? {
        guard let params = params,
              let rekeyTransactionSendDraft = draft as? RekeyTransactionSendDraft,
              let rekeyedAccount = rekeyTransactionSendDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.draft(draft: draft)))
            return nil
        }

        var transactionError: NSError?
        let rekeyTransactionDraft = RekeyTransactionDraft(
            from: rekeyTransactionSendDraft.from,
            rekeyedAccount: rekeyedAccount.address,
            transactionParams: params
        )

        guard let transactionData = algorandSDK.rekeyAccount(with: rekeyTransactionDraft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
