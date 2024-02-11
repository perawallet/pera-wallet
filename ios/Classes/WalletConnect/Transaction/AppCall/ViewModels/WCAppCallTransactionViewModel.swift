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
//   WCAppCallTransactionViewModel.swift

import Foundation

final class WCAppCallTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var idInformationViewModel: TransactionTextInformationViewModel?
    private(set) var onCompletionInformationViewModel: TransactionTextInformationViewModel?
    private(set) var appGlobalSchemaInformationViewModel: TransactionTextInformationViewModel?
    private(set) var appLocalSchemaInformationViewModel: TransactionTextInformationViewModel?
    private(set) var appExtraPagesInformationViewModel: TransactionTextInformationViewModel?
    private(set) var approvalHashInformationViewModel: TransactionTextInformationViewModel?
    private(set) var clearStateHashInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var feeInformationViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?

    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var peraExplorerInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        account: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setSenderInformationViewModel(from: account, and: transaction)
        setIdInformationViewModel(from: transaction)
        setOnCompletionInformationViewModel(from: transaction)
        setAppGlobalSchemaInformationViewModel(from: transaction)
        setAppLocalSchemaInformationViewModel(from: transaction)
        setAppExtraPagesInformationViewModel(from: transaction)
        setApprovalHashInformationViewModel(from: transaction)
        setClearStateHashInformationViewModel(from: transaction)
        setCloseWarningViewModel(from: transaction)
        setRekeyWarningViewModel(from: account, and: transaction)
        setFeeInformationViewModel(
            from: transaction,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeWarningViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
        setPeraExplorerInformationViewModel(from: transaction)
    }

    private func setSenderInformationViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
        let account: Account

        if let senderAccount = senderAccount {
            account = senderAccount
        } else {
            guard let senderAddress = transaction.transactionDetail?.sender else {
                return
            }

            account = Account(address: senderAddress)
        }

        let viewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from".localized,
            account: account,
            hasImage: account == senderAccount
        )

        self.senderInformationViewModel = viewModel
    }

    private func setIdInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let id = transactionDetail.appCallId,
              !transactionDetail.isAppCreateTransaction else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-id".localized,
            detail: "#\(id)"
        )

        self.idInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setOnCompletionInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let appCallOnComplete = transactionDetail.appCallOnComplete else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-on-complete".localized,
            detail: "\(appCallOnComplete.representation)"
        )

        self.onCompletionInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setAppGlobalSchemaInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let globalSchema = transactionDetail.appGlobalSchema,
              transactionDetail.isAppCreateTransaction else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-global-schema".localized,
            detail: globalSchema.representation
        )

        self.appGlobalSchemaInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setAppLocalSchemaInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let localSchema = transactionDetail.appLocalSchema,
              transactionDetail.isAppCreateTransaction else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-local-schema".localized,
            detail: localSchema.representation
        )

        self.appLocalSchemaInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setAppExtraPagesInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let extraPages = transactionDetail.appExtraPages,
              transactionDetail.isAppCreateTransaction else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-extra-pages".localized,
            detail: "\(extraPages)"
        )

        self.appExtraPagesInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setApprovalHashInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let approvalHash = transactionDetail.approvalHash,
              shouldDisplayAppHash(for: transactionDetail) else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-approval-hash".localized,
            detail: AlgorandSDK().getAddressfromProgram(approvalHash)
        )

        self.approvalHashInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setClearStateHashInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let stateHash = transactionDetail.stateHash,
              shouldDisplayAppHash(for: transactionDetail) else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-app-call-clear-hash".localized,
            detail: AlgorandSDK().getAddressfromProgram(stateHash)
        )

        self.clearStateHashInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }



    private func setCloseWarningViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let closeAddress = transactionDetail.closeAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-close-to".localized,
            detail: closeAddress
        )

        self.closeInformationViewModel = TransactionTextInformationViewModel(titledInformation)
        self.closeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .closeAlgos)
    }

    private func setRekeyWarningViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
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
        self.feeInformationViewModel = feeInformationViewModel
    }

    private func setFeeWarningViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              transactionDetail.hasHighFee else {
            return
        }

        self.feeWarningViewModel = WCTransactionWarningViewModel(warning: .fee)
    }

    private func setNoteInformationViewModel(from transaction: WCTransaction) {
        guard let note = transaction.transactionDetail?.noteRepresentation(), !note.isEmptyOrBlank else {
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
            isLastElement: transaction.transactionDetail?.isAppCreateTransaction ?? false
        )
    }

    private func setPeraExplorerInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              !transactionDetail.isAppCreateTransaction else {
            return
        }

        peraExplorerInformationViewModel = WCTransactionActionableInformationViewModel(
            information: .peraExplorer,
            isLastElement: true)
    }
}

extension WCAppCallTransactionViewModel {
    private func shouldDisplayAppHash(for transaction: WCTransactionDetail) -> Bool {
        guard let onComplete = transaction.appCallOnComplete else {
            return false
        }

        return transaction.isAppCreateTransaction || onComplete == .update
    }
}
