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
//  TransactionHistoryViewModel.swift

import UIKit
import SwiftDate

class TransactionHistoryViewModel {
    
    func configure(_ view: TransactionHistoryContextView, with dependencies: TransactionViewModelDependencies) {
        guard let transaction = dependencies.transaction as? Transaction else {
            return
        }
        
        let account = dependencies.account
        let contact = dependencies.contact
        
        if let assetDetail = dependencies.assetDetail {
            guard let assetTransaction = transaction.assetTransfer else {
                return
            }
            
            if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.mode = .normal(
                    amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            } else if assetTransaction.receiverAddress == account.address &&
                assetTransaction.amount == 0 &&
                transaction.type == .assetTransfer {
                view.setContact("asset-creation-fee-title".localized)
                view.subtitleLabel.isHidden = true
                if let fee = transaction.fee {
                    view.transactionAmountView.mode = .negative(amount: fee.toAlgos)
                }
            } else if assetTransaction.receiverAddress == account.address {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.mode = .positive(
                    amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            } else {
                configure(view, with: contact, and: assetTransaction.receiverAddress)
                view.transactionAmountView.mode = .negative(
                    amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            }
        } else {
            guard let payment = transaction.payment else {
                if let assetTransaction = transaction.assetTransfer,
                    assetTransaction.receiverAddress == account.address
                    && assetTransaction.amount == 0
                    && transaction.type == .assetTransfer {
                    view.setContact("asset-creation-fee-title".localized)
                    view.subtitleLabel.isHidden = true
                    if let fee = transaction.fee {
                        view.transactionAmountView.mode = .negative(amount: fee.toAlgos)
                    }
                }
                let formattedDate = transaction.date?.toFormat("MMMM dd, yyyy")
                view.dateLabel.text = formattedDate
                return
            }
            
            if payment.receiver == transaction.sender {
                configure(view, with: contact, and: transaction.sender)
                view.transactionAmountView.mode = .normal(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
            } else if payment.receiver == account.address {
                configure(view, with: contact, and: transaction.sender)
                view.transactionAmountView.mode = .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
            } else {
                configure(view, with: contact, and: payment.receiver)
                view.transactionAmountView.mode = .negative(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
            }
        }
        
        let formattedDate = transaction.date?.toFormat("MMMM dd, yyyy")
        view.dateLabel.text = formattedDate
    }
    
    private func configure(_ view: TransactionHistoryContextView, with contact: Contact?, and address: String?) {
        if let contact = contact {
            view.setContact(contact.name)
            view.subtitleLabel.text = contact.address?.shortAddressDisplay()
        } else if let address = address,
            let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(from: address) {
            view.setContact(localAccount.name)
            view.subtitleLabel.text = address.shortAddressDisplay()
        } else {
            view.setAddress(address)
            view.subtitleLabel.isHidden = true
        }
    }
    
    func configurePending(_ view: TransactionHistoryContextView, with dependencies: TransactionViewModelDependencies) {
        guard let transaction = dependencies.transaction as? PendingTransaction else {
            return
        }
        
        let account = dependencies.account
        let contact = dependencies.contact
        
        if let assetDetail = dependencies.assetDetail {
            if transaction.receiver == transaction.sender {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .normal(
                    amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            } else if transaction.receiver == account.address && transaction.amount == 0 && transaction.type == .assetTransfer {
                view.setContact("asset-creation-fee-title".localized)
                view.subtitleLabel.isHidden = true
                if let fee = transaction.fee {
                    view.transactionAmountView.mode = .negative(amount: fee.toAlgos)
                }
            } else if transaction.receiver == account.address {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .positive(
                    amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            } else {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .negative(
                    amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                    isAlgos: false,
                    fraction: assetDetail.fractionDecimals
                )
            }
        } else {
            if transaction.receiver == transaction.sender {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .normal(amount: transaction.amount.toAlgos)
            } else if transaction.receiver == account.address {
                configure(view, with: contact, and: transaction.sender)
                view.transactionAmountView.mode = .positive(amount: transaction.amount.toAlgos)
            } else {
                configure(view, with: contact, and: transaction.receiver)
                view.transactionAmountView.mode = .negative(amount: transaction.amount.toAlgos)
            }
        }
        
        let formattedDate = Date().toFormat("MMMM dd, yyyy")
        view.dateLabel.text = formattedDate
    }
}
