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

//   WCKeyRegTransactionViewModel.swift

import UIKit

final class WCKeyRegTransactionViewModel {
    private(set) var fromInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var voteKeyViewModel: TransactionTextInformationViewModel?
    private(set) var selectionKeyViewModel: TransactionTextInformationViewModel?
    private(set) var stateProofKeyViewModel: TransactionTextInformationViewModel?
    private(set) var voteFirstValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteLastValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteKeyDilutionViewModel: TransactionTextInformationViewModel?
    private(set) var participationStatusViewModel: TransactionTextInformationViewModel?
    private(set) var feeViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        senderAccount: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setFromInformationViewModel(
            from: senderAccount,
            and: transaction
        )
        setRekeyWarningViewModel(
            from: senderAccount,
            and: transaction
        )
        setVoteKeyViewModel(from: transaction)
        setSelectionKeyViewModel(from: transaction)
        setStateProofKeyViewModel(from: transaction)
        setVoteFirstValidRoundViewModel(from: transaction)
        setVoteLastValidRoundViewModel(from: transaction)
        setVoteKeyDiluationViewModel(from: transaction)
        setParticipationStatusViewModel(from: transaction)
        setFeeInformationViewModel(
            from: transaction,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeWarningInformationViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
    }
}

extension WCKeyRegTransactionViewModel {
    private func setFromInformationViewModel(
        from senderAccount: Account?,
        and transaction: WCTransaction
    ) {
        guard let senderAddress = transaction.transactionDetail?.sender else {
            return
        }

        let account: Account

        if let senderAccount = senderAccount,
            senderAddress == senderAccount.address {
            account = senderAccount
        } else {
            account = Account(address: senderAddress)
        }

        let viewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from".localized,
            account: account,
            hasImage: account == senderAccount
        )

        self.fromInformationViewModel = viewModel
    }

    private func setRekeyWarningViewModel(
        from senderAccount: Account?,
        and transaction: WCTransaction
    ) {
        guard let rekeyAddress = transaction.transactionDetail?.rekeyAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-rekey-title".localized,
            detail: rekeyAddress
        )

        self.rekeyInformationViewModel = TransactionTextInformationViewModel(titledInformation)

        guard senderAccount != nil else {
            return
        }

        self.rekeyWarningInformationViewModel = WCTransactionWarningViewModel(warning: .rekeyed)
    }

    private func setVoteKeyViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let voteKey = transaction.transactionDetail?.votePublicKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "vote-key-title".localized,
            detail: voteKey
        )
        self.voteKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setSelectionKeyViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let selectionKey = transactionDetail.selectionPublicKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "selection-key-title".localized,
            detail: selectionKey
        )
        self.selectionKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setStateProofKeyViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let stateProofKey = transactionDetail.stateProofPublicKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "state-proof-key-title".localized,
            detail: stateProofKey
        )
        self.stateProofKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setVoteFirstValidRoundViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let voteFirstValidRound = transactionDetail.voteFirstValidRound else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteFirstValidRound = formatter.string(from: NSNumber(value: voteFirstValidRound))
        let titledInfromation = TitledInformation(
            title: "valid-first-round-title".localized,
            detail: formattedVoteFirstValidRound
        )
        voteFirstValidRoundViewModel = .init(titledInfromation)
    }

    private func setVoteLastValidRoundViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let voteLastValidRound = transactionDetail.voteLastValidRound else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteLastValidRound = formatter.string(from: NSNumber(value: voteLastValidRound))
        let titledInfromation = TitledInformation(
            title: "valid-last-round-title".localized,
            detail: formattedVoteLastValidRound
        )
        voteLastValidRoundViewModel = .init(titledInfromation)
    }

    private func setVoteKeyDiluationViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.isOnlineKeyRegTransaction,
            let voteKeyDilution = transactionDetail.voteKeyDilution else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteKeyDilution = formatter.string(from: NSNumber(value: voteKeyDilution))
        let titledInfromation = TitledInformation(
            title: "vote-key-dilution-title".localized,
            detail: formattedVoteKeyDilution
        )
        voteKeyDilutionViewModel = .init(titledInfromation)
    }

    private func setParticipationStatusViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              !transactionDetail.isOnlineKeyRegTransaction else {
            return
        }

        let nonParticipation = transactionDetail.nonParticipation
        let participationStatusTitle =
        nonParticipation
        ? "not-participating-title".localized
        : "participating-title".localized
        let titledInfromation = TitledInformation(
            title: "participation-status-title".localized,
            detail: participationStatusTitle
        )
        participationStatusViewModel = .init(titledInfromation)
    }

    private func setFeeInformationViewModel(
        from transaction: WCTransaction,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee,
              fee != 0 else {
            return
        }

        let feeViewModel = TransactionAmountViewModel(
            .normal(
                amount: fee.toAlgos,
                isAlgos: true,
                fraction: algosFraction
            ),
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let feeInformationViewModel = TransactionAmountInformationViewModel(transactionViewModel: feeViewModel)
        feeInformationViewModel.setTitle("transaction-detail-fee".localized)
        self.feeViewModel = feeInformationViewModel
    }

    private func setFeeWarningInformationViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            transactionDetail.hasHighFee
        else {
            return
        }

        self.feeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .fee)
    }

    private func setNoteInformationViewModel(from transaction: WCTransaction) {
        guard
            let note = transaction.transactionDetail?.noteRepresentation(),
            !note.isEmptyOrBlank
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-note".localized,
            detail: note
        )
        self.noteInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setRawTransactionInformationViewModel(from transaction: WCTransaction) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(
            information: .rawTransaction,
            isLastElement: true
        )
    }
}
