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

//   AppCallTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AppCallTransactionItemViewModel:
    TransactionListItemViewModel,
    Hashable {
    var id: String?
    var title: EditText?
    var subtitle: EditText?
    var transactionAmountViewModel: TransactionAmountViewModel?

    init(
        _ draft: TransactionViewModelDraft
    ) {
        bindID(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindInnerTransactions(draft)
    }

    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        if let transaction = draft.transaction as? Transaction {
            id = transaction.id
        }
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        bindTitle("title-app-call".localized)
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let transaction = draft.transaction as? Transaction,
              let applicationCall = transaction.applicationCall else {
            return
        }

        if let appID = applicationCall.appID {
            let appId = "transaction-item-app-id-title".localized(params: appID)
            bindSubtitle(appId)
        }
    }

    private mutating func bindInnerTransactions(
        _ draft: TransactionViewModelDraft
    ) {
        guard
            let transaction = draft.transaction as? Transaction,
            let innerTransactions = transaction.innerTransactions,
            !innerTransactions.isEmpty
        else {
            return
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            innerTransactionCount: transaction.allInnerTransactionsCount
        )
    }
}
