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
//  TransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit

final class TransactionDetailViewModel: ViewModel {
    private(set) var transactionStatus: Transaction.Status?
    private(set) var userViewTitle: String?
    private(set) var userViewDetail: String?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var date: String?
    private(set) var roundViewIsHidden: Bool = false
    private(set) var roundViewDetail: String?
    private(set) var opponentViewTitle: String?
    private(set) var noteViewDetail: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var opponentType: Opponent?
    private(set) var opponentViewContact: Contact?
    private(set) var localAddress: String?
    private(set) var opponentViewAddress: String?
    private(set) var closeAmountViewMode: TransactionAmountView.Mode?
    private(set) var closeAmountViewIsHidden: Bool = false
    private(set) var closeToViewDetail: String?
    private(set) var closeToViewIsHidden: Bool = false
    private(set) var transactionAmountViewMode: TransactionAmountView.Mode?
    private(set) var rewardViewIsHidden: Bool = false
    private(set) var transactionIDTitle: String?
    private(set) var transactionID: String?
    private(set) var rewardViewMode: TransactionAmountView.Mode?

    init(
        transactionType: TransferType,
        transaction: Transaction,
        account: Account,
        assetDetail: Asset?
    ) {
        if transactionType == .received {
            bindReceivedTransaction(with: transaction, and: assetDetail, for: account)
        } else if transactionType == .sent {
            bindSentTransaction(with: transaction, and: assetDetail, for: account)
        }
    }
}

extension TransactionDetailViewModel {
    private func bindReceivedTransaction(
        with transaction: Transaction,
        and assetDetail: Asset?,
        for account: Account
    ) {
        transactionStatus = transaction.status
        userViewTitle = "transaction-detail-to".localized
        opponentViewTitle = "transaction-detail-from".localized

        let receiverAddress = transaction.getReceiver()
        let accountAddress = account.address

        if receiverAddress == accountAddress {
            userViewDetail = account.primaryDisplayName
        } else {
            userViewDetail = receiverAddress
        }

        if let fee = transaction.fee {
            feeViewMode = .normal(amount: fee.toAlgos)
        }

        bindDate(for: transaction)
        bindRound(for: transaction)
        if let sender = transaction.sender {
            opponentViewTitle = "transaction-detail-from".localized
            bindOpponent(for: transaction, with: sender)
        }

        if let assetTransaction = transaction.assetTransfer,
           let assetDetail = assetDetail {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true

            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals)

            if transaction.isSelfTransaction {
                transactionAmountViewMode = .normal(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
            } else if receiverAddress == accountAddress {
                transactionAmountViewMode = .positive(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
            } else {
                transactionAmountViewMode = .normal(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
            }
            rewardViewIsHidden = true
        } else if let payment = transaction.payment {
            let amount = payment.amountForTransaction(includesCloseAmount: false).toAlgos

            if transaction.isSelfTransaction {
                transactionAmountViewMode = .normal(amount: amount)
            } else if receiverAddress == accountAddress {
                transactionAmountViewMode = .positive(amount: amount)
            } else {
                transactionAmountViewMode = .normal(amount: amount)
            }

            bindCloseAmount(for: transaction)
            bindCloseTo(for: transaction)
            bindReward(for: transaction)
        } else if transaction.assetConfig != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            bindReward(for: transaction)
        } else if transaction.applicationCall != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            transactionAmountViewMode = nil
            bindReward(for: transaction)
        } else if transaction.keyRegTransaction != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            transactionAmountViewMode = nil
            bindReward(for: transaction)
        }

        bindTransactionIDTitle(transaction)
        transactionID = transaction.id ?? transaction.parentID
        bindNote(for: transaction)
    }
}

extension TransactionDetailViewModel {
    private func bindSentTransaction(
        with transaction: Transaction,
        and assetDetail: Asset?,
        for account: Account
    ) {
        transactionStatus = transaction.status

        bindReward(for: transaction)

        userViewTitle = "transaction-detail-from".localized
        opponentViewTitle = "transaction-detail-to".localized

        let senderAddress = transaction.sender
        let accountAddress = account.address

        if senderAddress == accountAddress {
            userViewDetail = account.primaryDisplayName
        } else {
            userViewDetail = senderAddress
        }

        if let fee = transaction.fee {
            feeViewMode = .normal(amount: fee.toAlgos)
        }

        bindDate(for: transaction)
        bindRound(for: transaction)

        if let assetTransaction = transaction.assetTransfer {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            opponentViewTitle = "transaction-detail-to".localized
            bindOpponent(for: transaction, with: assetTransaction.receiverAddress ?? "")

            if let assetDetail = assetDetail {
                let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals)

                if transaction.isSelfTransaction {
                    transactionAmountViewMode = .normal(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
                } else if senderAddress == accountAddress {
                    transactionAmountViewMode = .negative(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
                } else {
                    transactionAmountViewMode = .normal(amount: amount, isAlgos: false, fraction: assetDetail.decimals)
                }
            } else if transaction.isAssetAdditionTransaction(for: account.address) {
                transactionAmountViewMode = .normal(amount: 0.0)
            }
        }  else if let payment = transaction.payment {
            opponentViewTitle = "transaction-detail-to".localized
            bindOpponent(for: transaction, with: payment.receiver)

            let amount = payment.amountForTransaction(includesCloseAmount: false).toAlgos

            if transaction.isSelfTransaction {
                transactionAmountViewMode = .normal(amount: amount)
            } else if senderAddress == accountAddress {
                transactionAmountViewMode = .negative(amount: amount)
            } else {
                transactionAmountViewMode = .normal(amount: amount)
            }

            bindCloseAmount(for: transaction)
            bindCloseTo(for: transaction)
        } else if transaction.assetConfig != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            bindReward(for: transaction)
        } else if transaction.applicationCall != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            bindReward(for: transaction)
        } else if transaction.keyRegTransaction != nil {
            closeAmountViewIsHidden = true
            closeToViewIsHidden = true
            bindReward(for: transaction)
        }

        bindTransactionIDTitle(transaction)
        transactionID = transaction.id ?? transaction.parentID
        bindNote(for: transaction)
    }
}

extension TransactionDetailViewModel {
    func bindOpponent(for transaction: Transaction, with address: String) {
        if let contact = transaction.contact {
            opponentType = .contact(address: address)
            opponentViewContact = contact
        } else if let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(from: address) {
            opponentType = .localAccount(address: address)
            localAddress = localAccount.name
        } else {
            opponentType = .address(address: address)
            opponentViewAddress = address
        }
    }

    private func bindDate(for transaction: Transaction) {
        if transaction.isPending() {
            date = Date().toFormat("MMMM dd, yyyy - HH:mm")
        } else {
            date = transaction.date?.toFormat("MMMM dd, yyyy - HH:mm")
        }
    }

    private func bindRound(for transaction: Transaction) {
        if transaction.isPending() {
            roundViewIsHidden = true
        } else {
            if let round = transaction.confirmedRound {
                roundViewDetail = "\(round)"
            }
        }
    }

    private func bindTransactionIDTitle(
        _ transaction: Transaction
    ) {
        if transaction.isInner {
            transactionIDTitle = "transaction-detail-parent-id".localized
            return
        }

        transactionIDTitle = "transaction-detail-id".localized
    }

    private func bindNote(for transaction: Transaction) {
        if let note = transaction.noteRepresentation() {
            noteViewDetail = note
        } else {
            noteViewIsHidden = true
        }
    }

    private func bindCloseAmount(for transaction: Transaction) {
        if let closeAmount = transaction.payment?.closeAmountForTransaction()?.toAlgos {
            closeAmountViewMode = .normal(amount: closeAmount)
        } else {
            closeAmountViewIsHidden = true
        }
    }

    private func bindCloseTo(for transaction: Transaction) {
        if let closeAddress = transaction.payment?.closeAddress {
            closeToViewDetail = closeAddress
        } else {
            closeToViewIsHidden = true
        }
    }

    private func bindReward(for transaction: Transaction) {
        if let rewards = transaction.senderRewards,
           rewards > 0 {
            rewardViewMode = .normal(amount: rewards.toAlgos)
        } else {
            rewardViewIsHidden = true
        }
    }
}

extension TransactionDetailViewModel {
    enum Opponent: Equatable {
        case localAccount(address: String)
        case contact(address: String)
        case address(address: String)

        var address: String {
            switch self {
            case .localAccount(let address),
                 .contact(let address),
                 .address(let address):
                return address
            }
        }
    }
}
