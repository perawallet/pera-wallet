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

class WCAssetAdditionTransactionViewModel {
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
    private(set) var algoExplorerInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var urlInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var metadataInformationViewModel: WCTransactionActionableInformationViewModel?

    init(transaction: WCTransaction, senderAccount: Account?, assetDetail: AssetDetail?) {
        setFromInformationViewModel(from: senderAccount, and: transaction)
        setToInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: senderAccount, and: assetDetail)
        setCloseWarningViewModel(from: transaction, and: assetDetail)
        setRekeyWarningViewModel(from: senderAccount, and: transaction)

        setFeeInformationViewModel(from: transaction, and: assetDetail)
        setFeeWarningInformationViewModel(from: transaction)

        setNoteInformationViewModel(from: transaction)

        setRawTransactionInformationViewModel(from: transaction, and: assetDetail)
        setAlgoExplorerInformationViewModel(from: assetDetail)
        setUrlInformationViewModel(from: assetDetail)
        setMetadataInformationViewModel(from: assetDetail)
    }

    private func setFromInformationViewModel(from senderAccount: Account?, and transaction: WCTransaction) {
        guard let senderAddress = transaction.transactionDetail?.sender else {
            return
        }

        let account: Account

        if let senderAccount = senderAccount, senderAddress == senderAccount.address {
            account = senderAccount
        } else {
            account = Account(address: senderAddress, type: .standard)
        }

        let viewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-sender".localized,
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
            account = Account(address: toAddress, type: .standard)
        }

        let viewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-to".localized,
            account: account,
            hasImage: account == senderAccount
        )

        self.toInformationViewModel = viewModel
    }

    private func setAssetInformationViewModel(from senderAccount: Account?, and assetDetail: AssetDetail?) {

        assetInformationViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            assetDetail: assetDetail
        )
    }

    private func setCloseWarningViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard
            let transactionDetail = transaction.transactionDetail,
            let closeAddress = transactionDetail.closeAddress,
            let assetDetail = assetDetail else {
                return
            }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-close-asset-title".localized,
            detail: closeAddress
        )

        self.closeInformationViewModel = TransactionTextInformationViewModel(titledInformation)

        self.closeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .closeAsset(asset: assetDetail))
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

    private func setFeeInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {

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
            )
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
    
    private func setRawTransactionInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(
            information: .rawTransaction,
            isLastElement: assetDetail == nil
        )
    }

    private func setAlgoExplorerInformationViewModel(from assetDetail: AssetDetail?) {
        if assetDetail == nil {
            return
        }

        algoExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .algoExplorer, isLastElement: false)
    }

    private func setUrlInformationViewModel(from assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail,
              assetDetail.url != nil else {
            return
        }

        urlInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: false)
    }

    private func setMetadataInformationViewModel(from assetDetail: AssetDetail?) {
        if assetDetail == nil {
            return
        }

        metadataInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetMetadata, isLastElement: true)
    }
}
