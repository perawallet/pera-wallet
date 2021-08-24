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
//   WCAppCallTransactionViewModel.swift

import Foundation

class WCAppCallTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var idInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var onCompletionInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var authAccountInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var algoExplorerInformationViewModel: WCTransactionActionableInformationViewModel?

    init(transaction: WCTransaction, account: Account?) {
        setSenderInformationViewModel(from: account, and: transaction)
        setIdInformationViewModel(from: transaction)
        setOnCompletionInformationViewModel(from: transaction)
        setAuthAccountInformationViewModel(from: transaction)
        setCloseWarningInformationViewModel(from: transaction)
        setRekeyWarningInformationViewModel(from: transaction)
        setFeeInformationViewModel(from: transaction)
        setFeeWarningViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
        setAlgoExplorerInformationViewModel(from: transaction)
    }

    private func setSenderInformationViewModel(from account: Account?, and transaction: WCTransaction) {
        if let account = account {
            senderInformationViewModel = TitledTransactionAccountNameViewModel(
                title: "transaction-detail-sender".localized,
                account: account,
                isLastElement: false
            )
            return
        }

        guard let senderAddress = transaction.transactionDetail?.sender else {
            return
        }

        let senderAccount = Account(address: senderAddress, type: .standard)
        senderInformationViewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-sender".localized,
            account: senderAccount,
            isLastElement: false,
            hasImage: false
        )
    }

    private func setIdInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let id = transactionDetail.appCallId else {
            return
        }

        idInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-transaction-title-app-id".localized,
                detail: "#\(id)"
            ),
            isLastElement: false
        )
    }

    private func setOnCompletionInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let appCallOnComplete = transactionDetail.appCallOnComplete else {
            return
        }

        onCompletionInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(
                title: "wallet-connect-transaction-title-app-call-on-complete".localized,
                detail: "\(appCallOnComplete.representation)"
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

    private func setFeeInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee else {
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

    private func setAlgoExplorerInformationViewModel(from transaction: WCTransaction) {
        algoExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .algoExplorer, isLastElement: true)
    }
}
