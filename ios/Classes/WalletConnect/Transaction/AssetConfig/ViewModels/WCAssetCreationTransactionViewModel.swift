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
//   WCAssetCreationTransactionViewModel.swift

import UIKit

class WCAssetCreationTransactionViewModel {
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
    private(set) var decimalPlacesViewModel: TransactionTextInformationViewModel?
    private(set) var defaultFrozenViewModel: TransactionTextInformationViewModel?
    private(set) var managerAccountViewModel: TransactionTextInformationViewModel?
    private(set) var reserveAccountViewModel: TransactionTextInformationViewModel?
    private(set) var freezeAccountViewModel: TransactionTextInformationViewModel?
    private(set) var clawbackAccountViewModel: TransactionTextInformationViewModel?
    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?
    private(set) var metadataInformationViewModel: TransactionTextInformationViewModel?

    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var assetURLInformationViewModel: WCTransactionActionableInformationViewModel?

    init(
        transaction: WCTransaction,
        senderAccount: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetNameViewModel(from: transaction, asset: asset)
        setUnitNameViewModel(from: transaction)
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
        setFeeWarningViewModel(from: transaction)
        setDecimalPlacesViewModel(from: transaction)
        setDefaultFrozenViewModel(from: transaction)
        setManagerAccountViewModel(from: transaction)
        setReserveAccountViewModel(from: transaction)
        setFreezeAccountViewModel(from: transaction)
        setClawbackAccountViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setMetadataInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
        setAssetURLInformationViewModel(from: transaction)
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

    private func setAssetNameViewModel(
        from transaction: WCTransaction,
        asset: Asset?
    ) {
        assetNameViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            asset: asset
        )
    }

    private func setUnitNameViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let unitName = transactionDetail.assetConfigParams?.unitName else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-unit-title".localized,
            detail: unitName
        )

        self.unitNameViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setCloseWarningViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
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

    private func setAmountInformationViewModel(
        from transaction: WCTransaction,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        let amount = transaction.transactionDetail?.assetConfigParams?.totalSupply ?? 0
        let decimals = transaction.transactionDetail?.assetConfigParams?.decimal ?? 0

        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: Decimal(amount),
                isAlgos: false,
                fraction: decimals
            ),
            currency: currency,
            currencyFormatter: currencyFormatter
        )

        let amountInformationViewModel = TransactionAmountInformationViewModel(transactionViewModel: amountViewModel)
        amountInformationViewModel.setTitle("transaction-detail-amount".localized)
        self.amountInformationViewModel = amountInformationViewModel
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

    private func setDecimalPlacesViewModel(from transaction: WCTransaction) {
        let decimals = transaction.transactionDetail?.assetConfigParams?.decimal ?? 0

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-decimals-title".localized,
            detail: "\(decimals)"
        )

        self.decimalPlacesViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setDefaultFrozenViewModel(from transaction: WCTransaction) {
        let isFrozen = transaction.transactionDetail?.assetConfigParams?.isFrozen ?? false

        let titledInformation = TitledInformation(
            title: "wallet-connect-asset-frozen-title".localized,
            detail: isFrozen ? "title-on".localized : "title-off".localized
        )

        self.defaultFrozenViewModel = TransactionTextInformationViewModel(titledInformation)
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

    private func setMetadataInformationViewModel(from transaction: WCTransaction) {
        guard let metadataHash = transaction.transactionDetail?.assetConfigParams?.metadataHash?.toHexString() else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-title-metadata".localized,
            detail: metadataHash
        )

        self.metadataInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setRawTransactionInformationViewModel(from transaction: WCTransaction) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(
            information: .rawTransaction,
            isLastElement: !hasURLForAsset(transaction)
        )
    }

    private func setAssetURLInformationViewModel(from transaction: WCTransaction) {
        if hasURLForAsset(transaction) {
            assetURLInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: true)
        }
    }

    private func hasURLForAsset(_ transaction: WCTransaction) -> Bool {
        if let url = transaction.transactionDetail?.assetConfigParams?.url,
           !url.isEmpty {
            return true
        }

        return false
    }
}
