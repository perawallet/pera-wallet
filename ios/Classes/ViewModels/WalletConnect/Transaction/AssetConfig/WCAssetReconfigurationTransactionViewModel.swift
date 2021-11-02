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
//   WCAssetReconfigurationTransactionViewModel.swift

import UIKit

class WCAssetReconfigurationTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: TransactionAssetViewModel?
    private(set) var authAccountInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var managerAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var reserveAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var freezeAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var clawbackAccountViewModel: WCTransactionTextInformationViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var assetURLInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var algoExplorerInformationViewModel: WCTransactionActionableInformationViewModel?

    init(transaction: WCTransaction, senderAccount: Account?, assetDetail: AssetDetail?) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: transaction, and: assetDetail)
        setAuthAccountInformationViewModel(from: transaction)
        setCloseWarningInformationViewModel(from: transaction, and: assetDetail)
        setRekeyWarningInformationViewModel(from: transaction)
        setFeeInformationViewModel(from: transaction)
        setFeeWarningViewModel(from: transaction)
        setManagerAccountViewModel(from: transaction)
        setReserveAccountViewModel(from: transaction)
        setFreezeAccountViewModel(from: transaction)
        setClawbackAccountViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
        setAssetURLInformationViewModel(from: assetDetail)
        setAlgoExplorerInformationViewModel(from: transaction)
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

    private func setAssetInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail,
              let transactionDetail = transaction.transactionDetail else {
            return
        }

        assetInformationViewModel = TransactionAssetViewModel(
            assetDetail: assetDetail,
            isLastElement: transaction.signerAccount == nil &&
                transaction.hasValidAuthAddressForSigner &&
                !transactionDetail.hasRekeyOrCloseAddress
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

    private func setCloseWarningInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard let transactionDetail = transaction.transactionDetail,
              let closeAddress = transactionDetail.closeAddress,
              let assetDetail = assetDetail else {
            return
        }

        closeWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: closeAddress,
            warning: .closeAsset(asset: assetDetail),
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

    private func setFeeInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee,
              fee != 0 else {
            return
        }

        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            mode: .fee(value: fee),
            isLastElement: !transactionDetail.hasHighFee
        )
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

    private func setRawTransactionInformationViewModel(from transaction: WCTransaction) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: false)
    }

    private func setAssetURLInformationViewModel(from assetDetail: AssetDetail?) {
        if let url = assetDetail?.url,
           !url.isEmpty {
            assetURLInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: false)
        }
    }

    private func setAlgoExplorerInformationViewModel(from transaction: WCTransaction) {
        algoExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .algoExplorer, isLastElement: true)
    }
}
