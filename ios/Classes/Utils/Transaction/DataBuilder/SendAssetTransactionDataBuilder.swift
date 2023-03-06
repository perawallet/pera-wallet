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
//  SendAssetTransactionDataBuilder.swift

import Foundation

class SendAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetTransactionData()
    }

    private func composeAssetTransactionData() -> Data? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex,
              let amountDecimalValue = assetTransactionDraft.amount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }


        let address: String

        if let account = assetTransactionDraft.toAccount {
            address = account.address.trimmed()
        } else if let contact = assetTransactionDraft.toContact, let contactAddress = contact.address {
            address = contactAddress.trimmed()
        } else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }

        if !isValidAddress(address) {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: address)))
            return nil
        }

        var transactionError: NSError?
        
        let note = assetTransactionDraft.lockedNote ?? assetTransactionDraft.note
        
        let draft = AssetTransactionDraft(
            from: assetTransactionDraft.from,
            toAccount: address,
            transactionParams: params,
            amount: amountDecimalValue.toFraction(of: assetTransactionDraft.assetDecimalFraction),
            assetIndex: assetIndex,
            note: note?.data(using: .utf8),
            closeTo: assetTransactionDraft.assetCreator
        )

        guard let transactionData = algorandSDK.sendAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
