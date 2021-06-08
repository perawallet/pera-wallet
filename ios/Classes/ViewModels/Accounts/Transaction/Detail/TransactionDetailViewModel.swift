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
//  TransactionDetailViewModel.swift

import UIKit

class TransactionDetailViewModel {
    private(set) var opponentType: Opponent?
    
    func configureReceivedTransaction(
        _ view: TransactionDetailView,
        with transaction: Transaction,
        and assetDetail: AssetDetail?,
        for account: Account
    ) {
        if let status = transaction.status {
             view.statusView.setTransactionStatus(status)
        }
        
        view.userView.setTitle("transaction-detail-to".localized)
        view.userView.setDetail(account.name)

        if let fee = transaction.fee {
            view.feeView.setAmountViewMode(.normal(amount: fee.toAlgos))
        }

        setDate(for: transaction, in: view)
        setRound(for: transaction, in: view)
        
        view.opponentView.setTitle("transaction-detail-from".localized)
        if let sender = transaction.sender {
            setOpponent(for: transaction, with: sender, in: view)
        }
        
        if let assetTransaction = transaction.assetTransfer,
            let assetDetail = assetDetail {
            view.closeAmountView.removeFromSuperview()
            view.closeToView.removeFromSuperview()
            let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)

            let value: TransactionAmountView.Mode = transaction.isSelfTransaction()
                ? .normal(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals)
                : .positive(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals)
            view.amountView.setAmountViewMode(value)
            
            view.rewardView.removeFromSuperview()
        } else if let payment = transaction.payment {
            let amount = payment.amountForTransaction(includesCloseAmount: false).toAlgos

            let value: TransactionAmountView.Mode = transaction.isSelfTransaction() ? .normal(amount: amount) : .positive(amount: amount)
            view.amountView.setAmountViewMode(value)
            
            setCloseAmount(for: transaction, in: view)
            setCloseTo(for: transaction, in: view)
            setReward(for: transaction, in: view)
        }

        if let id = transaction.id {
            view.setTransactionID(id)
        }

        setNote(for: transaction, in: view)
    }
    
    func configureSentTransaction(
        _ view: TransactionDetailView,
        with transaction: Transaction,
        and assetDetail: AssetDetail?,
        for account: Account
    ) {
        if let status = transaction.status {
             view.statusView.setTransactionStatus(status)
        }
        
        setReward(for: transaction, in: view)
        
        view.userView.setTitle("transaction-detail-from".localized)
        view.userView.setDetail(account.name)

        if let fee = transaction.fee {
            view.feeView.setAmountViewMode(.normal(amount: fee.toAlgos))
        }

        setDate(for: transaction, in: view)
        setRound(for: transaction, in: view)
        
        view.opponentView.setTitle("transaction-detail-to".localized)
        
        if let assetTransaction = transaction.assetTransfer {
            view.closeAmountView.removeFromSuperview()
            view.closeToView.removeFromSuperview()
            setOpponent(for: transaction, with: assetTransaction.receiverAddress ?? "", in: view)

            if let assetDetail = assetDetail {
                let amount = assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)

                let value: TransactionAmountView.Mode = transaction.isSelfTransaction()
                    ? .normal(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals)
                    : .negative(amount: amount, isAlgos: false, fraction: assetDetail.fractionDecimals)
                view.amountView.setAmountViewMode(value)
            } else if transaction.isAssetAdditionTransaction(for: account.address) {
                view.amountView.setAmountViewMode(.normal(amount: 0.0))
            }
        } else if let payment = transaction.payment {
            setOpponent(for: transaction, with: payment.receiver, in: view)
            
            let amount = payment.amountForTransaction(includesCloseAmount: false).toAlgos

            let value: TransactionAmountView.Mode = transaction.isSelfTransaction() ? .normal(amount: amount) : .negative(amount: amount)
            view.amountView.setAmountViewMode(value)
            
            setCloseAmount(for: transaction, in: view)
            setCloseTo(for: transaction, in: view)
        }

        if let transactionId = transaction.id {
            view.setTransactionID(transactionId)
        }

        setNote(for: transaction, in: view)
    }
    
    private func setCloseAmount(for transaction: Transaction, in view: TransactionDetailView) {
        if let closeAmount = transaction.payment?.closeAmountForTransaction()?.toAlgos {
            view.closeAmountView.setAmountViewMode(.normal(amount: closeAmount))
        } else {
            view.closeAmountView.removeFromSuperview()
        }
    }
    
    private func setCloseTo(for transaction: Transaction, in view: TransactionDetailView) {
        if let closeAddress = transaction.payment?.closeAddress {
            view.closeToView.setDetail(closeAddress)
        } else {
            view.closeToView.removeFromSuperview()
        }
    }
    
    func setOpponent(for transaction: Transaction, with address: String, in view: TransactionDetailView) {
        if let contact = transaction.contact {
            opponentType = .contact(address: address)
            view.opponentView.setContact(contact)
            view.opponentView.setContactButtonImage(img("icon-qr"))
        } else if let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(from: address) {
            opponentType = .localAccount(address: address)
            view.opponentView.setName(localAccount.name)
            view.opponentView.setContactImage(hidden: true)
            view.opponentView.setContactButtonImage(img("icon-qr"))
        } else {
            opponentType = .address(address: address)
            view.opponentView.setContactButtonImage(img("icon-user-add"))
            view.opponentView.setName(address)
            view.opponentView.setContactImage(hidden: true)
        }
    }
    
    private func setDate(for transaction: Transaction, in view: TransactionDetailView) {
        if transaction.isPending() {
            view.setDate(Date().toFormat("MMMM dd, yyyy - HH:mm"))
        } else {
            if let date = transaction.date {
                view.setDate(date.toFormat("MMMM dd, yyyy - HH:mm"))
            }
        }
    }
    
    private func setRound(for transaction: Transaction, in view: TransactionDetailView) {
        if transaction.isPending() {
            view.roundView.removeFromSuperview()
        } else {
            if let round = transaction.confirmedRound {
                view.roundView.setDetail("\(round)")
            }
        }
    }
    
    private func setReward(for transaction: Transaction, in view: TransactionDetailView) {
        if let rewards = transaction.senderRewards, rewards > 0 {
            view.rewardView.setAmountViewMode(.normal(amount: rewards.toAlgos))
        } else {
            view.rewardView.removeFromSuperview()
        }
    }
    
    private func setNote(for transaction: Transaction, in view: TransactionDetailView) {
        if let note = transaction.noteRepresentation() {
            view.noteView.setDetail(note)
            view.noteView.setSeparatorView(hidden: true)
        } else {
            view.idView.setSeparatorView(hidden: true)
            view.noteView.removeFromSuperview()
        }
    }
}

extension TransactionDetailViewModel {
    enum Opponent {
        case localAccount(address: String)
        case contact(address: String)
        case address(address: String)
    }
}
