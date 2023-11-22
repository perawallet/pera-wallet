// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   KeyRegTransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit

final class KeyRegTransactionDetailViewModel: ViewModel {
    private(set) var transactionStatus: Transaction.Status?
    private(set) var userViewTitle: String?
    private(set) var userViewDetail: String?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var date: String?
    private(set) var roundViewIsHidden: Bool = false
    private(set) var roundViewDetail: String?
    private(set) var noteViewDetail: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var rewardViewIsHidden: Bool = false
    private(set) var transactionIDTitle: String?
    private(set) var transactionID: String?
    private(set) var rewardViewMode: TransactionAmountView.Mode?
    private(set) var voteKeyViewModel: TransactionTextInformationViewModel?
    private(set) var selectionKeyViewModel: TransactionTextInformationViewModel?
    private(set) var stateProofKeyViewModel: TransactionTextInformationViewModel?
    private(set) var voteFirstValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteLastValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteKeyDilutionViewModel: TransactionTextInformationViewModel?
    private(set) var participationStatusViewModel: TransactionTextInformationViewModel?

    init(
        transaction: Transaction,
        account: Account
    ) {
        bindTransaction(
            with: transaction,
            for: account
        )
    }
}

extension KeyRegTransactionDetailViewModel {
    private func bindTransaction(
        with transaction: Transaction,
        for account: Account
    ) {
        transactionStatus = transaction.status

        bindReward(for: transaction)

        userViewTitle = "transaction-detail-from".localized

        let senderAddress = transaction.sender

        if senderAddress == account.address {
            userViewDetail = account.primaryDisplayName
        } else {
            userViewDetail = senderAddress
        }

        if let fee = transaction.fee {
            feeViewMode = .normal(amount: fee.toAlgos)
        }

        bindDate(for: transaction)
        bindRound(for: transaction)
        bindTransactionIDTitle(for: transaction)
        transactionID = transaction.id ?? transaction.parentID
        bindNote(for: transaction)
        bindVoteKeyViewModel(from: transaction)
        bindSelectionKeyViewModel(from: transaction)
        bindStateProofKeyViewModel(from: transaction)
        bindVoteFirstValidRoundViewModel(from: transaction)
        bindVoteLastValidRoundViewModel(from: transaction)
        bindVoteKeyDiluationViewModel(from: transaction)
        bindParticipationStatusViewModel(from: transaction)
    }
}

extension KeyRegTransactionDetailViewModel {
    private func bindDate(for transaction: Transaction) {
        if transaction.isPending() {
            date = Date().toFormat("MMMM dd, yyyy - HH:mm")
        } else {
            date = transaction.date?.toFormat("MMMM dd, yyyy - HH:mm")
        }
    }

    private func bindRound(for transaction: Transaction) {
        if transaction.isPending() {
            roundViewIsHidden = true
        } else {
            if let round = transaction.confirmedRound {
                roundViewDetail = "\(round)"
            }
        }
    }

    private func bindTransactionIDTitle(for transaction: Transaction) {
        if transaction.isInner {
            transactionIDTitle = "transaction-detail-parent-id".localized
            return
        }

        transactionIDTitle = "transaction-detail-id".localized
    }

    private func bindNote(for transaction: Transaction) {
        if let note = transaction.noteRepresentation() {
            noteViewDetail = note
        } else {
            noteViewIsHidden = true
        }
    }

    private func bindReward(for transaction: Transaction) {
        if let rewards = transaction.senderRewards,
           rewards > 0 {
            rewardViewMode = .normal(amount: rewards.toAlgos)
        } else {
            rewardViewIsHidden = true
        }
    }

    private func bindVoteKeyViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteKey = keyRegTransaction.voteParticipationKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "vote-key-title".localized,
            detail: voteKey
        )
        self.voteKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindSelectionKeyViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let selectionKey = keyRegTransaction.selectionParticipationKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "selection-key-title".localized,
            detail: selectionKey
        )
        self.selectionKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindStateProofKeyViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let stateProofKey = keyRegTransaction.stateProofKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "state-proof-key-title".localized,
            detail: stateProofKey
        )
        self.stateProofKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindVoteFirstValidRoundViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteFirstValidRound = keyRegTransaction.voteFirstValid
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteFirstValidRound = formatter.string(from: NSNumber(value: voteFirstValidRound))
        let titledInformation = TitledInformation(
            title: "valid-first-round-title".localized,
            detail: formattedVoteFirstValidRound
        )
        voteFirstValidRoundViewModel = .init(titledInformation)
    }

    private func bindVoteLastValidRoundViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteLastValidRound = keyRegTransaction.voteLastValid
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteLastValidRound = formatter.string(from: NSNumber(value: voteLastValidRound))
        let titledInformation = TitledInformation(
            title: "valid-last-round-title".localized,
            detail: formattedVoteLastValidRound
        )
        voteLastValidRoundViewModel = .init(titledInformation)
    }

    private func bindVoteKeyDiluationViewModel(from transaction: Transaction) {
        guard
            let keyRegTransaction = transaction.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteKeyDilution = keyRegTransaction.voteKeyDilution
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteKeyDilution = formatter.string(from: NSNumber(value: voteKeyDilution))
        let titledInformation = TitledInformation(
            title: "vote-key-dilution-title".localized,
            detail: formattedVoteKeyDilution
        )
        voteKeyDilutionViewModel = .init(titledInformation)
    }

    private func bindParticipationStatusViewModel(from transaction: Transaction) {
        guard let transactionDetail = transaction.keyRegTransaction,
              !transactionDetail.isOnlineKeyRegTransaction else {
            return
        }

        let nonParticipation = transactionDetail.nonParticipation
        let participationStatusTitle =
            nonParticipation
            ? "not-participating-title".localized
            : "participating-title".localized
        let titledInformation = TitledInformation(
            title: "participation-status-title".localized,
            detail: participationStatusTitle
        )
        participationStatusViewModel = .init(titledInformation)
    }
}
