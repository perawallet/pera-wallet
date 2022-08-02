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

//   AssetTransactionItemDraftComposer.swift

import Foundation

struct AssetTransactionItemDraftComposer: TransactionListItemDraftComposer {
    let draft: TransactionListing
    private let sharedDataController: SharedDataController
    private let contacts: [Contact]

    init(
        draft: TransactionListing,
        sharedDataController: SharedDataController,
        contacts: [Contact]
    ) {
        self.draft = draft
        self.sharedDataController = sharedDataController
        self.contacts = contacts
    }

    func composeTransactionItemPresentationDraft(
        from transaction: TransactionItem
    ) -> TransactionViewModelDraft? {
        guard let transaction = transaction as? Transaction,
              let assetTransfer = transaction.assetTransfer else {
            return nil
        }

        var asset: AssetDecoration?
        if let assetID = transaction.assetTransfer?.assetId,
           let anAsset = sharedDataController.assetDetailCollection[assetID] {
            asset = anAsset
        }

        let address = assetTransfer.receiverAddress == draft.accountHandle.value.address ? transaction.sender : assetTransfer.receiverAddress

        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transaction.contact = contact

            let draft = TransactionViewModelDraft(
                account: draft.accountHandle.value,
                asset: asset,
                transaction: transaction,
                contact: contact,
                localAccounts: sharedDataController.sortedAccounts().map { $0.value },
                localAssets: sharedDataController.assetDetailCollection
            )

            return draft
        }

        let draft = TransactionViewModelDraft(
            account: draft.accountHandle.value,
            asset: asset,
            transaction: transaction,
            localAccounts: sharedDataController.sortedAccounts().map { $0.value },
            localAssets: sharedDataController.assetDetailCollection
        )

        return draft
    }
}
