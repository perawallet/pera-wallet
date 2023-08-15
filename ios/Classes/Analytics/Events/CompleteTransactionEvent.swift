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
//  CompleteTransactionEvent.swift

import Foundation
import MacaroonVendors

struct CompleteTransactionEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        accountType: AccountAuthorization,
        assetId: String?,
        isMaxTransaction: Bool,
        amount: UInt64?,
        transactionId: String
    ) {
        self.name = .completeTransaction
        self.metadata = [
            .accountType: accountType.rawValue,
            .assetID: assetId ?? "algos",
            .isMax: isMaxTransaction,
            .amount: amount ?? 0,
            .transactionID: transactionId
        ]
    }
}

extension AnalyticsEvent where Self == CompleteTransactionEvent {
    static func completeStandardTransaction(
        draft: TransactionSendDraft,
        transactionId: TransactionID
    ) -> Self {
        if let algoDraft = draft as? AlgosTransactionSendDraft, let amount = algoDraft.amount {
            return CompleteTransactionEvent(
                accountType: algoDraft.from.authorization,
                assetId: nil,
                isMaxTransaction: algoDraft.isMaxTransaction,
                amount: amount.toMicroAlgos,
                transactionId: transactionId.identifier
             )
        } else if let assetDraft = draft as? AssetTransactionSendDraft,
                  let assetId = assetDraft.assetIndex,
                  let amount = assetDraft.amount {
            return CompleteTransactionEvent(
                accountType: assetDraft.from.authorization,
                assetId: String(assetId),
                isMaxTransaction: assetDraft.isMaxTransaction,
                amount: amount.toFraction(of: assetDraft.assetDecimalFraction),
                transactionId: transactionId.identifier
            )
        }

        /// <note>: We are sending default event if we can't decide the type of transaction above
        return CompleteTransactionEvent(
            accountType: .standard,
            assetId: nil,
            isMaxTransaction: false,
            amount: 0,
            transactionId: transactionId.identifier
        )
    }

    static func completeCollectibleTransaction(
        draft: SendCollectibleDraft,
        transactionId: TransactionID
    ) -> Self {
        return CompleteTransactionEvent(
            accountType: draft.fromAccount.authorization,
            assetId: String(draft.collectibleAsset.id),
            isMaxTransaction: false,
            amount: draft.collectibleAsset.amount,
            transactionId: transactionId.identifier
        )
    }
}
