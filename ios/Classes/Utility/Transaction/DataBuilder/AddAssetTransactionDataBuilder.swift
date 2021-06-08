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
//  AddAssetTransactionDataBuilder.swift

import Foundation

class AddAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetAdditionData()
    }

    private func composeAssetAdditionData() -> Data? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.draft(draft: draft)))
            return nil
        }

        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: assetTransactionDraft.from, transactionParams: params, assetIndex: assetIndex)

        guard let transactionData = algorandSDK.addAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
