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
//   TransactionHistoryContextViewModel.swift

import MacaroonUIKit
import UIKit

struct TransactionHistoryContextViewModel:
    BindableViewModel,
    Hashable {
    private(set) var id: String?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var transactionAmountViewModel: TransactionAmountViewModel?
    private(set) var secondaryAmount: EditText?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }

    mutating func bind<T>(
        _ model: T
    ) {
        if let reward = model as? Reward {
            bindID(reward)
            bindTitle(reward)
            bindAmount(reward)
            return
        }

        if let transactionDependencies = model as? TransactionViewModelDependencies {
            bindID(transactionDependencies)
            bindTitle(transactionDependencies)
            bindSubtitle(transactionDependencies)
            bindAmount(transactionDependencies)
            bindSecondaryAmount(transactionDependencies)
        }
    }
}

extension TransactionHistoryContextViewModel {
    private mutating func bindID(
        _ reward: Reward
    ) {
        id = reward.transactionID
    }

    private mutating func bindTitle(
        _ reward: Reward
    ) {
        bindTitle("reward-list-title".localized)
    }

    private mutating func bindAmount(
        _ reward: Reward
    ) {
        let rewardViewModel = RewardViewModel(reward)
        transactionAmountViewModel = rewardViewModel.amountViewModel
    }
}

extension TransactionHistoryContextViewModel {
    private mutating func bindID(
        _ transactionDependency: TransactionViewModelDependencies
    ) {
        if let transaction = transactionDependency.transaction as? Transaction {
            id = transaction.id
        } else if let pendingTransaction = transactionDependency.transaction as? PendingTransaction {
            id = "\(pendingTransaction.hashValue)"
        }
    }

    private mutating func bindTitle(
        _ transactionDependency: TransactionViewModelDependencies
    ) {
        let account = transactionDependency.account

        if let transaction = transactionDependency.transaction as? Transaction {
            if let assetTransaction = transaction.assetTransfer {
                if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                    bindTitle("transaction-detail-send".localized)
                } else if transaction.isAssetAdditionTransaction(for: account.address) {
                    bindTitle("asset-creation-fee-title".localized)
                } else if assetTransaction.receiverAddress == account.address {
                    bindTitle("transaction-detail-receive".localized)
                } else {
                    bindTitle("transaction-detail-send".localized)
                }
            } else {
                guard let payment = transaction.payment else {
                    if transaction.isAssetAdditionTransaction(for: account.address) {
                        bindTitle("asset-creation-fee-title".localized)
                    }
                    return
                }

                if payment.receiver == transaction.sender {
                    bindTitle("transaction-detail-send".localized)
                } else if payment.receiver == account.address {
                    bindTitle("transaction-detail-receive".localized)
                } else {
                    bindTitle("transaction-detail-send".localized)
                }
            }
            return
        }

        if let transaction = transactionDependency.transaction as? PendingTransaction {
            if transaction.receiver == transaction.sender {
                bindTitle("transaction-detail-send".localized)
            } else if transaction.isAssetAdditionTransaction(for: account.address) {
                bindTitle("asset-creation-fee-title".localized)
            } else if transaction.receiver == account.address {
                bindTitle("transaction-detail-receive".localized)
            } else {
                bindTitle("transaction-detail-send".localized)
            }
        }
    }

    private mutating func bindSubtitle(
        _ transactionDependency: TransactionViewModelDependencies
    ) {
        let account = transactionDependency.account

        if let transaction = transactionDependency.transaction as? Transaction {
            if let assetTransaction = transaction.assetTransfer {
                if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: assetTransaction.receiverAddress
                    )
                    bindSubtitle(subtitle)
                } else if transaction.isAssetAdditionTransaction(for: account.address) {
                    subtitle = nil
                } else if assetTransaction.receiverAddress == account.address {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: assetTransaction.receiverAddress
                    )
                    bindSubtitle(subtitle)
                } else {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: assetTransaction.receiverAddress
                    )
                    bindSubtitle(subtitle)
                }
            } else {
                guard let payment = transaction.payment else {
                    if transaction.isAssetAdditionTransaction(for: account.address) {
                        subtitle = nil
                    }
                    return
                }

                if payment.receiver == transaction.sender {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: transaction.sender
                    )
                    bindSubtitle(subtitle)
                } else if payment.receiver == account.address {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: transaction.sender
                    )
                    bindSubtitle(subtitle)
                } else {
                    let subtitle = getSubtitle(
                        from: transactionDependency,
                        and: payment.receiver
                    )
                    bindSubtitle(subtitle)
                }
            }
            return
        }

        if let transaction = transactionDependency.transaction as? PendingTransaction {
            if transaction.receiver == transaction.sender {
                let subtitle = getSubtitle(
                    from: transactionDependency,
                    and: transaction.receiver
                )
                bindSubtitle(subtitle)
            } else if transaction.isAssetAdditionTransaction(for: account.address) {
                subtitle = nil
            } else if transaction.receiver == account.address {
                let subtitle = getSubtitle(
                    from: transactionDependency,
                    and: transaction.sender
                )
                bindSubtitle(subtitle)
            } else {
                let subtitle = getSubtitle(
                    from: transactionDependency,
                    and: transaction.receiver
                )
                bindSubtitle(subtitle)
            }
        }
    }

    private mutating func bindAmount(
        _ transactionDependency: TransactionViewModelDependencies
    ) {
        let account = transactionDependency.account

        if let transaction = transactionDependency.transaction as? Transaction {
            if let assetTransaction = transaction.assetTransfer,
               let assetDetail = transactionDependency.assetDetail {
                if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .normal(
                            amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                } else if transaction.isAssetAdditionTransaction(for: account.address) {
                    if let fee = transaction.fee {
                        transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                    }
                } else if assetTransaction.receiverAddress == account.address {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .positive(
                            amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                } else {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .negative(
                            amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                }
            } else {
                guard let payment = transaction.payment else {
                    if transaction.isAssetAdditionTransaction(for: account.address) {
                        if let fee = transaction.fee {
                            transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                        }
                    }
                    return
                }

                if payment.receiver == transaction.sender {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .normal(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                    )
                } else if payment.receiver == account.address {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                    )
                } else {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .negative(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                    )
                }
            }
            return
        }

        if let transaction = transactionDependency.transaction as? PendingTransaction {
            if let assetDetail = transactionDependency.assetDetail {
                if transaction.receiver == transaction.sender {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .normal(
                            amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                } else if transaction.isAssetAdditionTransaction(for: account.address) {
                    if let fee = transaction.fee {
                        transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                    }
                } else if transaction.receiver == account.address {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .positive(
                            amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                } else {
                    transactionAmountViewModel = TransactionAmountViewModel(
                        .negative(
                            amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                            isAlgos: false,
                            fraction: assetDetail.decimals,
                            assetSymbol: getAssetSymbol(from: assetDetail)
                        )
                    )
                }
            } else {
                if transaction.receiver == transaction.sender {
                    transactionAmountViewModel = TransactionAmountViewModel(.normal(amount: transaction.amount.toAlgos))
                } else if transaction.receiver == account.address {
                    transactionAmountViewModel = TransactionAmountViewModel(.positive(amount: transaction.amount.toAlgos))
                } else {
                    transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: transaction.amount.toAlgos))
                }
            }
        }
    }

    private mutating func bindSecondaryAmount(
        _ transactionDependency: TransactionViewModelDependencies
    ) {
        let account = transactionDependency.account

        if let transaction = transactionDependency.transaction as? Transaction {
            if let assetDetail = transactionDependency.assetDetail {
                bindSecondaryAmount(
                    getAssetCurrencyValue(
                        from: transactionDependency,
                        and: transaction.getAmount()?.assetAmount(fromFraction: assetDetail.decimals)
                    )
                )
            } else {
                if transaction.payment == nil {
                    if transaction.isAssetAdditionTransaction(for: account.address) {
                        bindSecondaryAmount(getAlgoCurrencyValue(from: transactionDependency, and: transaction.fee?.toAlgos))
                    }
                    return
                }

                bindSecondaryAmount(getAlgoCurrencyValue(from: transactionDependency, and: transaction.getAmount()?.toAlgos))
            }
            return
        }

        if let transaction = transactionDependency.transaction as? PendingTransaction {
            if let assetDetail = transactionDependency.assetDetail {
                bindSecondaryAmount(
                    getAssetCurrencyValue(
                        from: transactionDependency,
                        and: transaction.amount.assetAmount(fromFraction: assetDetail.decimals)
                    )
                )
            } else {
                bindSecondaryAmount(getAlgoCurrencyValue(from: transactionDependency, and: transaction.amount.toAlgos))
            }
        }
    }
}

extension TransactionHistoryContextViewModel {
    private func getAlgoCurrencyValue(
        from transactionDependency: TransactionViewModelDependencies,
        and amount: Decimal?
    ) -> String? {
        guard let amount = amount,
              let currency = transactionDependency.currency,
              let currencyPriceValue = currency.priceValue,
              !(currency is AlgoCurrency)
        else {
            return nil
        }

        let totalAmount = amount * currencyPriceValue
        return totalAmount.toCurrencyStringForLabel(with: currency.symbol)
    }

    private func getAssetCurrencyValue(
        from transactionDependency: TransactionViewModelDependencies,
        and amount: Decimal?
    ) -> String? {
        guard let amount = amount,
              let assetDetail = transactionDependency.assetDetail,
              let assetUSDValue = assetDetail.usdValue,
              let currency = transactionDependency.currency,
              let currencyUSDValue = currency.usdValue else {
            return nil
        }

        let currencyValue = assetUSDValue * amount * currencyUSDValue
        if currencyValue > 0 {
            return currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        }

        return nil
    }

    private func getSubtitle(
        from transactionDependency: TransactionViewModelDependencies,
        and account: PublicKey?
    ) -> String? {
        if let contact = transactionDependency.contact {
            return contact.name
        }

        if let address = account,
           let localAccount = transactionDependency.localAccounts.first(matching: (\.address, address)) {
            return localAccount.name
        }

        return account.shortAddressDisplay()
    }

    private func getAssetSymbol(
        from assetDetail: AssetInformation
    ) -> String {
        if let unitName = assetDetail.unitName,
           !unitName.isEmptyOrBlank {
            return unitName
        }

        if let name = assetDetail.name,
           !name.isEmptyOrBlank {
            return name
        }

        return "title-unknown".localized.uppercased()
    }
}

extension TransactionHistoryContextViewModel {
    private mutating func bindTitle(
        _ title: String?
    ) {
        guard let title = title else {
            self.title = nil
            return
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.title = .attributedString(
            title.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }

    private mutating func bindSubtitle(
        _ subtitle: String?
    ) {
        guard let subtitle = subtitle else {
            self.subtitle = nil
            return
        }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        self.subtitle = .attributedString(
            subtitle.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }

    private mutating func bindSecondaryAmount(
        _ secondaryAmount: String?
    ) {
        guard let secondaryAmount = secondaryAmount else {
            self.secondaryAmount = nil
            return
        }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        self.secondaryAmount = .attributedString(
            secondaryAmount.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.right)
                ])
            ])
        )
    }
}
