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

//   AlgoTransactionItemDraftComposer.swift

import Foundation

struct AlgoTransactionItemDraftComposer: TransactionListItemDraftComposer {
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
              let payment = transaction.payment else {
            return nil
        }

        let address = payment.receiver == draft.accountHandle.value.address ? transaction.sender : transaction.payment?.receiver

        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transaction.contact = contact

            let draft = TransactionViewModelDraft(
                account: draft.accountHandle.value,
                asset: nil,
                transaction: transaction,
                contact: contact,
                localAccounts: sharedDataController.sortedAccounts().map { $0.value },
                localAssets: nil
            )

            return draft
        }

        let draft = TransactionViewModelDraft(
            account: draft.accountHandle.value,
            asset: nil,
            transaction: transaction,
            localAccounts: sharedDataController.sortedAccounts().map { $0.value },
            localAssets: nil
        )

        return draft
    }
}
