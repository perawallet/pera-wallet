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
//   WCSingleTransactionRequestMiddleViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestMiddleViewModel {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var verificationTierIcon: UIImage?

    var asset: Asset? {
        didSet {
            if let transaction {
                setData(transaction, for: account)
            }
        }
    }

    private let transaction: WCTransaction?
    private let account: Account?
    private let currency: CurrencyProvider
    private let currencyFormatter: CurrencyFormatter

    init(
        transaction: WCTransaction,
        account: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        self.transaction = transaction
        self.account = account
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        
        self.setData(
            transaction,
            for: account
        )
    }

    init(
        data: WCArbitraryData,
        account: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        self.transaction = nil
        
        self.account = account
        self.currency = currency
        self.currencyFormatter = currencyFormatter

        self.title = "title-arbitrary-data".localized
        self.subtitle = data.message
    }

    private func setData(
        _ transaction: WCTransaction,
        for account: Account?
    ) {
        guard
            let transactionDetail = transaction.transactionDetail,
            let type = transactionDetail.transactionType(for: account)
        else {
            return
        }

        switch type {
        case .algos:
            var titleAttributes = Typography.largeTitleRegularAttributes()
            titleAttributes.insert(.textColor(Colors.Text.main))

            if let amount = transaction.transactionDetail?.amount {
                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = AlgoLocalCurrency()

                let text = currencyFormatter.format(amount.toAlgos)

                title = text.someString.attributed(titleAttributes)
            } else {
                title = "".attributed(titleAttributes)
            }

            self.verificationTierIcon = "icon-trusted".uiImage
            self.setUsdValue(transaction: transaction, asset: nil)
        case .asset:
            guard
                let asset = asset,
                let amount = transaction.transactionDetail?.amount
            else {
                return
            }

            let assetDecimals = asset.decimals

            /// <todo>
            /// Not sure we need this constraint, because the final number should be sent to the
            /// formatter unless the number itself is modified.
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = assetDecimals

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
            currencyFormatter.currency = nil

            let finalAmount = amount.assetAmount(fromFraction: assetDecimals)
            let finalAmountText = currencyFormatter.format(finalAmount)
            let text = finalAmountText.someString

            if let assetCode = asset.naming.hasOnlyAssetName ?
                    asset.naming.displayNames.primaryName :
                    asset.naming.displayNames.secondaryName {
                var titleAttributes = Typography.largeTitleRegularAttributes()

                if asset.verificationTier.isSuspicious {
                    titleAttributes.insert(.textColor(Colors.Helpers.negative))
                } else {
                    titleAttributes.insert(.textColor(Colors.Text.main))
                }

                let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
                let assetText = "\(text) \(assetCode)".attributed(titleAttributes)
                let text = [ destroyedText, assetText ].compound(" ")
                self.title = text
            }

            self.verificationTierIcon = getVerificationTierIcon(asset.verificationTier)
            self.setUsdValue(transaction: transaction, asset: asset)
        case .assetAddition,
             .possibleAssetAddition:
            guard let asset = asset else {
                return
            }
            var titleAttributes = Typography.largeTitleRegularAttributes()

            if asset.verificationTier.isSuspicious {
                titleAttributes.insert(.textColor(Colors.Helpers.negative))
            } else {
                titleAttributes.insert(.textColor(Colors.Text.main))
            }

            let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
            let assetText = asset.naming.displayNames.primaryName.attributed(titleAttributes)
            let text = [ destroyedText, assetText ].compound(" ")
            self.title = text
            self.subtitle = "\(asset.id)"
            self.verificationTierIcon = getVerificationTierIcon(asset.verificationTier)
            return
        case .appCall:
            let appCallOncomplete = transaction.transactionDetail?.appCallOnComplete ?? .noOp

            switch appCallOncomplete {
            case .delete:
                break
            case .update:
                break
            default:
                if (transaction.transactionDetail?.isAppCreateTransaction ?? false) {
                    var titleAttributes = Typography.largeTitleRegularAttributes()
                    titleAttributes.insert(.textColor(Colors.Text.main))
                    self.title =
                        "single-transaction-request-opt-in-title"
                            .localized
                            .attributed(titleAttributes)
                    self.subtitle = appCallOncomplete.representation
                    self.verificationTierIcon = nil
                    return
                }
            }
            
            guard let id = transaction.transactionDetail?.appCallId else {
                return
            }
            var titleAttributes = Typography.largeTitleRegularAttributes()
            titleAttributes.insert(.textColor(Colors.Text.main))
            self.title = "#\(id)".attributed(titleAttributes)
            self.subtitle = "wallet-connect-transaction-title-app-id".localized
            self.verificationTierIcon = nil
        case .assetConfig(let type):
            switch type {
            case .create:
                if let assetConfigParams = transaction.transactionDetail?.assetConfigParams {
                    var titleAttributes = Typography.largeTitleRegularAttributes()
                    titleAttributes.insert(.textColor(Colors.Text.main))
                    self.title = "\(assetConfigParams.name ?? assetConfigParams.unitName ?? "title-unknown".localized)".attributed(titleAttributes)
                    /// <note> Newly created asset should be unverified.
                    self.verificationTierIcon = nil
                }
            case .reconfig:
                if let asset = asset {
                    var titleAttributes = Typography.largeTitleRegularAttributes()

                    if asset.verificationTier.isSuspicious {
                        titleAttributes.insert(.textColor(Colors.Helpers.negative))
                    } else {
                        titleAttributes.insert(.textColor(Colors.Text.main))
                    }

                    let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
                    let assetText = "\(asset.naming.name ?? asset.naming.unitName ?? "title-unknown".localized)".attributed(titleAttributes)
                    let text = [ destroyedText, assetText ].compound(" ")
                    self.title = text
                    self.subtitle = "#\(asset.id)"
                    self.verificationTierIcon = getVerificationTierIcon(asset.verificationTier)
                }
            case .delete:
                if let asset = asset {
                    var titleAttributes = Typography.largeTitleRegularAttributes()

                    if asset.verificationTier.isSuspicious {
                        titleAttributes.insert(.textColor(Colors.Helpers.negative))
                    } else {
                        titleAttributes.insert(.textColor(Colors.Text.main))
                    }

                    let destroyedText = makeDestroyedAssetTextIfNeeded(asset.isDestroyed)
                    let assetText =
                        "\(asset.naming.name ?? asset.naming.unitName ?? "title-unknown".localized)".attributed(titleAttributes)
                    let text = [ destroyedText, assetText ].compound(" ")
                    self.title = text
                    self.subtitle = "#\(asset.id)"
                    self.verificationTierIcon = getVerificationTierIcon(asset.verificationTier)
                }
            }
        case .keyReg:
            self.title = "key-reg-title".localized
            self.subtitle =
                transactionDetail.isOnlineKeyRegTransaction
                ? "online-title".localized
                : "offline-title".localized
        }
    }

    private func makeDestroyedAssetTextIfNeeded(_ isAssetDestroyed: Bool) -> NSAttributedString? {
        guard isAssetDestroyed else {
            return nil
        }

        let title = "title-deleted-with-parantheses".localized
        var attributes = Typography.largeTitleMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.negative))
        return title.attributed(attributes)
    }

    private func setUsdValue(
        transaction: WCTransaction,
        asset: Asset?
    ) {
        guard
            let amount = transaction.transactionDetail?.amount,
            let currencyValue = currency.primaryValue
        else {
            subtitle = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()
            let exchanger = CurrencyExchanger(currency: rawCurrency)

            let amountInCurrency: Decimal
            if let asset = asset {
                let assetAmount = amount.assetAmount(fromFraction: asset.decimals)
                amountInCurrency = try exchanger.exchange(
                    asset,
                    amount: assetAmount
                )
            } else {
                let algoAmount = amount.toAlgos
                amountInCurrency = try exchanger.exchangeAlgo(amount: algoAmount)
            }

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            subtitle = currencyFormatter.format(amountInCurrency)
        } catch {
            subtitle = nil
        }
    }

    private func getTitleColor(
        _ verificationTier: AssetVerificationTier?
    ) -> Color {
        let isSuspicious = verificationTier?.isSuspicious ?? false

        if isSuspicious {
            return Colors.Helpers.negative
        }

        return Colors.Text.main
    }

    private func getVerificationTierIcon(
        _ verificationTier: AssetVerificationTier
    ) -> UIImage? {
        switch verificationTier {
        case .trusted: return "icon-trusted".uiImage
        case .verified: return "icon-verified".uiImage
        case .unverified: return nil
        case .suspicious: return "icon-suspicious".uiImage
        }
    }
}
