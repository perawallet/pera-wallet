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

//   WCArbitraryDataViewModel.swift

import UIKit

final class WCArbitraryDataViewModel {
    private(set) var fromInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var toInformationViewModel: TransactionTextInformationViewModel?
    private(set) var balanceViewModel: TransactionAmountInformationViewModel?
    private(set) var amountViewModel: TransactionAmountInformationViewModel?
    private(set) var feeViewModel: TransactionAmountInformationViewModel?
    private(set) var dataInformationViewModel: TransactionTextInformationViewModel?

    init(
        wcSession: WCSessionDraft,
        data: WCArbitraryData,
        senderAccount: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setFromInformationViewModel(
            from: senderAccount,
            and: data
        )
        setToInformationViewModel(wcSession: wcSession)
        setBalanceInformationViewModel(
            from: senderAccount,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setAmountInformationViewModel(
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeInformationViewModel(
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setDataInformationViewModel(from: data)
    }

    private func setFromInformationViewModel(
        from senderAccount: Account?,
        and data: WCArbitraryData
    ) {
        guard let senderAddress = data.signer else {
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

    private func setToInformationViewModel(
        wcSession: WCSessionDraft
    ) {
        let dAppName =
            wcSession.wcV1Session?.peerMeta.name ??
            wcSession.wcV2Session?.peer.name
        guard let dAppName else {
            self.toInformationViewModel = nil
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-to".localized,
            detail: dAppName
        )
        self.toInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setBalanceInformationViewModel(
        from senderAccount: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let senderAccount else { return }

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

    private func setAmountInformationViewModel(
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: 0,
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
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        let feeViewModel = TransactionAmountViewModel(
            .normal(
                amount: 0,
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

    private func setDataInformationViewModel(from data: WCArbitraryData) {
        guard let message = data.message,
              !message.isEmptyOrBlank else {
            self.dataInformationViewModel = nil
            return
        }

        let titledInformation = TitledInformation(
            title: "title-data".localized,
            detail: message
        )
        self.dataInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }
}
