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
//   WCAssetDeletionTransactionViewModel.swift

import UIKit

class WCAssetDeletionTransactionViewModel {
    private(set) var fromInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: WCAssetInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var assetWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var feeViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?

    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var peraExplorerInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        senderAccount: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: asset)
        setAssetWarningViewModel()
        setCloseWarningViewModel(from: transaction, and: asset)
        setRekeyWarningViewModel(from: senderAccount, and: transaction)
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

    private func setSenderInformationViewModel(
        from senderAccount: Account?,
        and transaction: WCTransaction
    ) {
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
            title: "transaction-detail-sender".localized,
            account: account,
            hasImage: account == senderAccount
        )

        self.fromInformationViewModel = viewModel
    }

    private func setAssetInformationViewModel(from asset: Asset?) {
        guard let asset = asset else {
            return
        }

        assetInformationViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            asset: asset
        )
    }

    private func setAssetWarningViewModel() {
        assetWarningInformationViewModel = WCTransactionWarningViewModel(warning: .assetDelete)
    }
    
    private func setCloseWarningViewModel(
        from transaction: WCTransaction,
        and asset: Asset?
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let closeAddress = transactionDetail.closeAddress,
              let asset = asset else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-close-asset-title".localized,
            detail: closeAddress
        )

        self.closeInformationViewModel = TransactionTextInformationViewModel(titledInformation)
        self.closeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .closeAsset(asset: asset))
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

    private func setFeeWarningViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              transactionDetail.hasHighFee else {
            return
        }

        self.feeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .fee)
    }

    private func setNoteInformationViewModel(from transaction: WCTransaction) {
        guard let note = transaction.transactionDetail?.noteRepresentation(),
              !note.isEmptyOrBlank else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-note".localized,
            detail: note
        )

        noteInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setRawTransactionInformationViewModel(from transaction: WCTransaction) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: false)
    }

    private func setPeraExplorerInformationViewModel(from transaction: WCTransaction) {
        peraExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .peraExplorer, isLastElement: true)
    }
}
