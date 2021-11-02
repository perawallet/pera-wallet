// Copyright 2019 Algorand, Inc.

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
    private(set) var assetNameViewModel: WCTransactionTextInformationViewModel?
    private(set) var unitNameViewModel: WCTransactionTextInformationViewModel?
    private(set) var authAccountInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var amountInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var decimalPlacesViewModel: WCTransactionTextInformationViewModel?
    private(set) var defaultFrozenViewModel: WCTransactionTextInformationViewModel?
    private(set) var managerAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var reserveAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var freezeAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var clawbackAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var metadataInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var assetURLInformationViewModel: WCTransactionActionableInformationViewModel?

    init(transaction: WCTransaction, senderAccount: Account?) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetNameViewModel(from: transaction)
        setUnitNameViewModel(from: transaction)
        setAuthAccountInformationViewModel(from: transaction)
        setCloseWarningInformationViewModel(from: transaction)
        setRekeyWarningInformationViewModel(from: transaction)
        setAmountInformationViewModel(from: transaction)
        setFeeInformationViewModel(from: transaction)
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

    private func setSenderInformationViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
        if let account = senderAccount {
            senderInformationViewModel = TitledTransactionAccountNameViewModel(
                title: "transaction-detail-from".localized,
                account: account
            )
            return
        }

        guard let senderAddress = transaction.transactionDetail?.sender else {
            return
        }

        let account = Account(address: senderAddress, type: .standard)
        senderInformationViewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from".localized,
            account: account,
            hasImage: false
        )
    }

    private func setAssetNameViewModel(from transaction: WCTransaction) {
        guard let assetName = transaction.transactionDetail?.assetConfigParams?.name else {
            return
        }

        assetNameViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-name-title".localized,
                detail: assetName
            ),
            isLastElement: false
        )
    }

    private func setUnitNameViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let unitName = transactionDetail.assetConfigParams?.unitName else {
            return
        }

        unitNameViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-unit-title".localized,
                detail: unitName
            ),
            isLastElement: transaction.hasValidAuthAddressForSigner && !transactionDetail.hasRekeyOrCloseAddress
        )
    }

    private func setAuthAccountInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let authAddress = transaction.authAddress,
              transaction.hasValidAuthAddressForSigner else {
            return
        }

        authAccountInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-transaction-title-auth-address".localized,
                detail: authAddress
            ),
            isLastElement: !transactionDetail.hasRekeyOrCloseAddress
        )
    }

    private func setCloseWarningInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let closeAddress = transactionDetail.closeAddress else {
            return
        }

        closeWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: closeAddress,
            warning: .closeAlgos,
            isLastElement: !transactionDetail.isRekeyTransaction
        )
    }

    private func setRekeyWarningInformationViewModel(from transaction: WCTransaction) {
        guard let rekeyAddress = transaction.transactionDetail?.rekeyAddress else {
            return
        }

        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: rekeyAddress,
            warning: .rekeyed,
            isLastElement: true
        )
    }

    private func setAmountInformationViewModel(from transaction: WCTransaction) {
        let amount = transaction.transactionDetail?.assetConfigParams?.totalSupply ?? 0
        let decimals = transaction.transactionDetail?.assetConfigParams?.decimal ?? 0

        amountInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-amount".localized,
            mode: .amount(value: amount, isAlgos: false, fraction: decimals),
            isLastElement: false
        )
    }

    private func setFeeInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee,
              fee != 0 else {
            return
        }

        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            mode: .fee(value: fee),
            isLastElement: false
        )
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

        decimalPlacesViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-decimals-title".localized,
                detail: "\(decimals)"
            ),
            isLastElement: false
        )
    }

    private func setDefaultFrozenViewModel(from transaction: WCTransaction) {
        let isFrozen = transaction.transactionDetail?.assetConfigParams?.isFrozen ?? false

        defaultFrozenViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-frozen-title".localized,
                detail: isFrozen ? "title-on".localized : "title-off".localized
            ),
            isLastElement: false
        )
    }

    private func setManagerAccountViewModel(from transaction: WCTransaction) {
        guard let manager = transaction.transactionDetail?.assetConfigParams?.managerAddress else {
            return
        }

        managerAccountViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-manager-title".localized,
                detail: manager
            ),
            isLastElement: false
        )
    }

    private func setReserveAccountViewModel(from transaction: WCTransaction) {
        guard let reserve = transaction.transactionDetail?.assetConfigParams?.reserveAddress else {
            return
        }

        reserveAccountViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-reserve-title".localized,
                detail: reserve
            ),
            isLastElement: false
        )
    }

    private func setFreezeAccountViewModel(from transaction: WCTransaction) {
        guard let frozen = transaction.transactionDetail?.assetConfigParams?.frozenAddress else {
            return
        }

        freezeAccountViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-freeze-title".localized,
                detail: frozen
            ),
            isLastElement: false
        )
    }

    private func setClawbackAccountViewModel(from transaction: WCTransaction) {
        guard let clawback = transaction.transactionDetail?.assetConfigParams?.clawbackAddress else {
            return
        }

        clawbackAccountViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-asset-clawback-title".localized,
                detail: clawback
            ),
            isLastElement: true
        )
    }

    private func setNoteInformationViewModel(from transaction: WCTransaction) {
        guard let note = transaction.transactionDetail?.noteRepresentation() else {
            return
        }

        noteInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-note".localized, detail: note),
            isLastElement: false
        )
    }

    private func setMetadataInformationViewModel(from transaction: WCTransaction) {
        guard let metadataHash = transaction.transactionDetail?.assetConfigParams?.metadataHash?.toHexString() else {
            return
        }

        metadataInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "wallet-connect-transaction-title-metadata".localized, detail: metadataHash),
            isLastElement: false
        )
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
