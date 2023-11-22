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
//   WCAlgosTransactionViewModel.swift

import UIKit

final class WCAlgosTransactionViewModel {
    private(set) var fromInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var toInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var balanceViewModel: TransactionAmountInformationViewModel?
    private(set) var assetInformationViewModel: WCAssetInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var amountViewModel: TransactionAmountInformationViewModel?
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
        setFromInformationViewModel(from: senderAccount, and: transaction)
        setToInformationViewModel(from: senderAccount, and: transaction)
        setBalanceInformationViewModel(
            from: senderAccount,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setAssetInformationViewModel(from: senderAccount)
        setCloseWarningViewModel(from: transaction)
        setRekeyWarningViewModel(from: senderAccount, and: transaction)

        setAmountInformationViewModel(
            from: transaction,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeInformationViewModel(
            from: transaction,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeWarningInformationViewModel(from: transaction)

        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
    }

    private func setFromInformationViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
        guard let senderAddress = transaction.transactionDetail?.sender else {
            return
        }

        let account: Account

        if let senderAccount = senderAccount, senderAddress == senderAccount.address {
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

    private func setToInformationViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
        guard let toAddress = transaction.transactionDetail?.receiver else {
            return
        }

        let account: Account

        if let senderAccount = senderAccount, senderAccount.address == toAddress {
            account = senderAccount
        } else {
            account = Account(address: toAddress)
        }

        let viewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-to".localized,
            account: account,
            hasImage: account == senderAccount
        )

        self.toInformationViewModel = viewModel
    }

    private func setBalanceInformationViewModel(
        from senderAccount: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let senderAccount = senderAccount else {
            return
        }

        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: senderAccount.algo.amount.toAlgos,
                isAlgos: true,
                fraction: algosFraction,
                assetSymbol: "ALGO"
            ),
            currency: currency,
            currencyFormatter: currencyFormatter
        )

        let balanceViewModel = TransactionAmountInformationViewModel(transactionViewModel: amountViewModel)
        balanceViewModel.setTitle("title-account-balance".localized)
        self.balanceViewModel = balanceViewModel
    }

    private func setAssetInformationViewModel(from senderAccount: Account?) {
        assetInformationViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            asset: nil
        )
    }

    private func setCloseWarningViewModel(from transaction: WCTransaction) {
        guard
            let transactionDetail = transaction.transactionDetail,
            let closeAddress = transactionDetail.closeAddress else {
                return
            }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-close-asset-title".localized,
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

    private func setAmountInformationViewModel(
        from transaction: WCTransaction,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let amount = transaction.transactionDetail?.amount else {
            return
        }

        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: amount.toAlgos,
                isAlgos: true,
                fraction: algosFraction,
                assetSymbol: "ALGO"
            ),
            currency: currency,
            currencyFormatter: currencyFormatter
        )

        let amountInformationViewModel = TransactionAmountInformationViewModel(transactionViewModel: amountViewModel)
        amountInformationViewModel.setTitle("transaction-detail-amount".localized)
        self.amountViewModel = amountInformationViewModel
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
        guard let transactionDetail = transaction.transactionDetail,
              transactionDetail.hasHighFee else {
                  return
        }

        self.feeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .fee)
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
        self.rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: true)
    }
}
