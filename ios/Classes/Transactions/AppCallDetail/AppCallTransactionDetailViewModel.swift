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

//   AppCallTransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit

final class AppCallTransactionDetailViewModel: ViewModel {
    private(set) var sender: String?
    private(set) var applicationID: String?
    private(set) var onCompletion: String?
    private(set) var transactionAssetInformationViewModel: AppCallTransactionAssetInformationViewModel?
    private(set) var fee: TransactionAmountView.Mode?
    private(set) var transactionIDTitle: String?
    private(set) var transactionID: String?
    private(set) var note: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var innerTransactionsViewModel: TransactionAmountInformationViewModel?

    init(
        transaction: Transaction,
        account: Account,
        assets: [Asset]?
    ) {
        bindSender(
            transaction: transaction,
            account: account
        )
        bindApplicationID(transaction)
        bindAssets(assets)
        bindOnCompletion(transaction)
        bindFee(transaction)
        bindInnerTransactionsViewModel(transaction)
        bindTransactionIDTitle(transaction)
        bindTransactionID(transaction)
        bindNote(transaction)
    }
}

extension AppCallTransactionDetailViewModel {
    private func bindSender(
        transaction: Transaction,
        account: Account
    ) {
        let senderAddress = transaction.sender
        let accountAddress = account.address

        if senderAddress == accountAddress {
            sender = account.primaryDisplayName
            return
        }

        sender = senderAddress
    }

    private func bindApplicationID(
        _ transaction: Transaction
    ) {
        if let appID = transaction.applicationCall?.appID {
            applicationID  = "#\(appID)"
        }
    }

    private func bindAssets(
        _ assets: [Asset]?
    ) {
        if let assets = assets,
           !assets.isEmpty {
            transactionAssetInformationViewModel = AppCallTransactionAssetInformationViewModel(
                assets: assets
            )
        }
    }

    private func bindOnCompletion(
        _ transaction: Transaction
    ) {
        onCompletion = transaction.applicationCall?.onCompletion?.uiRepresentation
    }

    private func bindFee(
        _ transaction: Transaction
    ) {
        if let fee = transaction.fee {
            self.fee = .normal(amount: fee.toAlgos)
        }
    }

    private func bindTransactionIDTitle(
        _ transaction: Transaction
    ) {
        if transaction.isInner {
            transactionIDTitle = "transaction-detail-parent-id".localized
            return
        }

        transactionIDTitle = "transaction-detail-id".localized
    }

    private func bindTransactionID(
        _ transaction: Transaction
    ) {
        transactionID = transaction.id ?? transaction.parentID
    }

    private func bindNote(
        _ transaction: Transaction
    ) {
        if let note = transaction.noteRepresentation() {
            self.note = note
            return
        }

        noteViewIsHidden = true
    }

    private func bindInnerTransactionsViewModel(
        _ transaction: Transaction
    ) {
        guard let innerTransactions = transaction.innerTransactions,
              !innerTransactions.isEmpty else {
            return
        }
        
        let amountViewModel = TransactionAmountViewModel(
            innerTransactionCount: transaction.allInnerTransactionsCount,
            showInList: false
        )
        
        innerTransactionsViewModel = TransactionAmountInformationViewModel(
            transactionViewModel: amountViewModel
        )
    }
}
