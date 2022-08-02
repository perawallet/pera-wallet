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

//   AssetConfigTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetConfigTransactionItemViewModel:
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
        bindTitle("wallet-connect-transaction-title-asset-config".localized)
    }
}
