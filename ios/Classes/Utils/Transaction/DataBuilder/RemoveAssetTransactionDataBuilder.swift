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
//  RemoveAssetTransactionDataBuilder.swift

import Foundation

class RemoveAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetRemovalData()
    }

    private func composeAssetRemovalData() -> Data? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex,
              let amountDecimalValue = assetTransactionDraft.amount,
              let toAccount = assetTransactionDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }
        
        if assetTransactionDraft.assetCreator == assetTransactionDraft.from.address {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.optOutFromCreator))
            return nil
        }

        if !isValidAddress(toAccount.address.trimmed()) {
            return nil
        }

        var transactionError: NSError?
        let draft = AssetRemovalDraft(
            from: assetTransactionDraft.from,
            transactionParams: params,
            amount: amountDecimalValue.uint64Value,
            assetCreatorAddress: assetTransactionDraft.assetCreator,
            assetIndex: assetIndex
        )

        guard let transactionData = algorandSDK.removeAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
