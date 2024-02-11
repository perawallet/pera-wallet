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
//   WCAssetAdditionTransactionViewModel.swift

import UIKit

final class WCAssetAdditionTransactionViewModel {
    private(set) var fromInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var toInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: WCAssetInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var feeViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?

    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var peraExplorerInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var urlInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var metadataInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        senderAccount: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setFromInformationViewModel(from: senderAccount, and: transaction)
        setToInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: senderAccount, and: asset)
        setCloseWarningViewModel(from: transaction, and: asset)
        setRekeyWarningViewModel(from: senderAccount, and: transaction)

        setFeeInformationViewModel(
            from: transaction,
            and: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeWarningInformationViewModel(from: transaction)

        setNoteInformationViewModel(from: transaction)

        setRawTransactionInformationViewModel(from: transaction, and: asset)
        setPeraExplorerInformationViewModel(from: asset)
        setUrlInformationViewModel(from: asset)
        setMetadataInformationViewModel(from: asset)
    }

    private func setFromInformationViewModel(
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

    private func setToInformationViewModel(
        from senderAccount: Account?,
        and transaction: WCTransaction
    ) {
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

    private func setAssetInformationViewModel(
        from senderAccount: Account?,
        and asset: Asset?
    ) {
        assetInformationViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            asset: asset
        )
    }

    private func setCloseWarningViewModel(from transaction: WCTransaction, and asset: Asset?) {
        guard
            let transactionDetail = transaction.transactionDetail,
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
        and asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee,
              fee != 0 else {
            return
        }

        let mode = TransactionAmountView.Mode.normal(
            amount: fee.toAlgos,
            isAlgos: true,
            fraction: algosFraction
        )
        let feeViewModel = TransactionAmountViewModel(
            mode,
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
    
    private func setRawTransactionInformationViewModel(
        from transaction: WCTransaction,
        and asset: Asset?
    ) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(
            information: .rawTransaction,
            isLastElement: asset == nil
        )
    }

    private func setPeraExplorerInformationViewModel(from asset: Asset?) {
        if asset == nil {
            return
        }

        peraExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .peraExplorer, isLastElement: false)
    }

    private func setUrlInformationViewModel(from asset: Asset?) {
        guard let asset = asset,
              asset.url != nil else {
            return
        }

        urlInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: false)
    }

    private func setMetadataInformationViewModel(from asset: Asset?) {
        if asset == nil {
            return
        }

        metadataInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetMetadata, isLastElement: true)
    }
}
