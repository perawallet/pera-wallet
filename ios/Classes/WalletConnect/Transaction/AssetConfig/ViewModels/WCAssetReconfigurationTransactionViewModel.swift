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
//   WCAssetReconfigurationTransactionViewModel.swift

import UIKit

class WCAssetReconfigurationTransactionViewModel {

    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetNameViewModel: WCAssetInformationViewModel?
    private(set) var unitNameViewModel: TransactionTextInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionWarningViewModel?
    private(set) var amountInformationViewModel: TransactionAmountInformationViewModel?
    private(set) var feeInformationViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var managerAccountViewModel: TransactionTextInformationViewModel?
    private(set) var reserveAccountViewModel: TransactionTextInformationViewModel?
    private(set) var freezeAccountViewModel: TransactionTextInformationViewModel?
    private(set) var clawbackAccountViewModel: TransactionTextInformationViewModel?
    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?
    private(set) var metadataInformationViewModel: TransactionTextInformationViewModel?

    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var assetURLInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var peraExplorerInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        senderAccount: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: transaction, and: asset)
        setCloseWarningViewModel(from: transaction, and: asset)
        setRekeyWarningViewModel(from: senderAccount, and: transaction)
        setFeeInformationViewModel(
            from: transaction,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setFeeWarningViewModel(from: transaction)
        setManagerAccountViewModel(from: transaction)
        setReserveAccountViewModel(from: transaction)
        setFreezeAccountViewModel(from: transaction)
        setClawbackAccountViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
        setAssetURLInformationViewModel(from: asset)
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

        self.senderInformationViewModel = viewModel
    }

    private func setAssetInformationViewModel(
        from transaction: WCTransaction,
        and asset: Asset?
    ) {
        assetNameViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            asset: asset
        )
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
        self.feeInformationViewModel = feeInformationViewModel
    }

    private func setFeeWarningViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              transactionDetail.hasHighFee else {
            return
        }

        feeWarningViewModel = WCTransactionWarningViewModel(warning: .fee)
    }

    private func setManagerAccountViewModel(from transaction: WCTransaction) {
        guard let manager = transaction.transactionDetail?.assetConfigParams?.managerAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-manager-title".localized,
            detail: manager
        )

        self.managerAccountViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setReserveAccountViewModel(from transaction: WCTransaction) {
        guard let reserve = transaction.transactionDetail?.assetConfigParams?.reserveAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-reserve-title".localized,
            detail: reserve
        )

        self.reserveAccountViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setFreezeAccountViewModel(from transaction: WCTransaction) {
        guard let frozen = transaction.transactionDetail?.assetConfigParams?.frozenAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-freeze-title".localized,
            detail: frozen
        )

        self.freezeAccountViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setClawbackAccountViewModel(from transaction: WCTransaction) {
        guard let clawback = transaction.transactionDetail?.assetConfigParams?.clawbackAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-clawback-title".localized,
            detail: clawback
        )

        self.clawbackAccountViewModel = TransactionTextInformationViewModel(titledInformation)
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
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: false)
    }

    private func setAssetURLInformationViewModel(from asset: Asset?) {
        if let url = asset?.url,
           !url.isEmpty {
            assetURLInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: false)
        }
    }

    private func setPeraExplorerInformationViewModel(from transaction: WCTransaction) {
        peraExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .peraExplorer, isLastElement: true)
    }
}
