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
//   WCAlgosTransactionViewModel.swift

import UIKit

class WCAlgosTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: TransactionAssetViewModel?
    private(set) var receiverInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var authAccountInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var balanceInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var amountInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeWarningViewModel: WCTransactionWarningViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?

    init(transaction: WCTransaction, senderAccount: Account?) {
        setSenderInformationViewModel(from: senderAccount, and: transaction)
        setAssetInformationViewModel(from: transaction)
        setBalanceInformationViewModel(from: transaction, with: senderAccount)
        setAuthAccountInformationViewModel(from: transaction)
        setCloseWarningInformationViewModel(from: transaction)
        setRekeyWarningInformationViewModel(from: transaction)
        setReceiverInformationViewModel(from: transaction)
        setAmountInformationViewModel(from: transaction)
        setFeeInformationViewModel(from: transaction)
        setFeeWarningViewModel(from: transaction)
        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
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

        senderInformationViewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from".localized,
            account: Account(address: senderAddress, type: .standard),
            hasImage: false
        )
    }

    private func setAssetInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        assetInformationViewModel = TransactionAssetViewModel(
            assetDetail: nil,
            isLastElement: transaction.signerAccount == nil &&
                transaction.hasValidAuthAddressForSigner &&
                !transactionDetail.hasRekeyOrCloseAddress
        )
    }

    private func setBalanceInformationViewModel(from transaction: WCTransaction, with senderAccount: Account?) {
        guard let senderAccount = senderAccount,
              let transactionDetail = transaction.transactionDetail,
              transaction.signerAccount != nil else {
            return
        }

        balanceInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-balance".localized,
            mode: .balance(value: Int64(senderAccount.amount)),
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

    private func setReceiverInformationViewModel(from transaction: WCTransaction) {
        guard let receiverAddress = transaction.transactionDetail?.receiver else {
            return
        }

        receiverInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-to".localized, detail: receiverAddress),
            isLastElement: false
        )
    }

    private func setAmountInformationViewModel(from transaction: WCTransaction) {
        guard let amount = transaction.transactionDetail?.amount else {
            return
        }

        amountInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-amount".localized,
            mode: .amount(value: amount),
            isLastElement: false
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
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: true)
    }
}
