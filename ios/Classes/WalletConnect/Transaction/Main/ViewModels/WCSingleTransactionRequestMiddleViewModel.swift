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
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var isAssetIconHidden: Bool = true

    var asset: Asset? {
        didSet {
            setData(transaction, for: account)
        }
    }

    private let transaction: WCTransaction
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

    private func setData(
        _ transaction: WCTransaction,
        for account: Account?
    ) {
        guard let type = transaction.transactionDetail?.transactionType(for: account) else {
            return
        }

        switch type {
        case .algos:
            if let amount = transaction.transactionDetail?.amount {
                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = AlgoLocalCurrency()

                let text = currencyFormatter.format(amount.toAlgos)

                title = text.someString
            } else {
                title = ""
            }

            self.isAssetIconHidden = true
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

            if let assetCode = asset.presentation.hasOnlyAssetName ?
                    asset.presentation.displayNames.primaryName :
                    asset.presentation.displayNames.secondaryName {
                self.title = "\(text) \(assetCode)"
            }

            self.isAssetIconHidden = !asset.presentation.isVerified

            self.setUsdValue(transaction: transaction, asset: asset)
        case .assetAddition,
                .possibleAssetAddition:
            guard let asset = asset else {
                return
            }
            self.title = asset.presentation.displayNames.primaryName
            self.subtitle = "\(asset.id)"
            self.isAssetIconHidden = !asset.presentation.isVerified
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
                    self.title = "single-transaction-request-opt-in-title".localized
                    self.subtitle = appCallOncomplete.representation
                    self.isAssetIconHidden = true
                    return
                }
            }
            
            guard let id = transaction.transactionDetail?.appCallId else {
                return
            }

            self.title = "#\(id)"
            self.subtitle = "wallet-connect-transaction-title-app-id".localized
            self.isAssetIconHidden = true
        case .assetConfig(let type):
            switch type {
            case .create:
                if let assetConfigParams = transaction.transactionDetail?.assetConfigParams {
                    self.title = "\(assetConfigParams.name ?? assetConfigParams.unitName ?? "title-unknown".localized)"

                    self.isAssetIconHidden = assetConfigParams.name.isNilOrEmpty && assetConfigParams.unitName.isNilOrEmpty
                }
            case .reconfig:
                if let asset = asset {
                    self.title = "\(asset.presentation.name ?? asset.presentation.unitName ?? "title-unknown".localized)"
                    self.subtitle = "#\(asset.id)"
                    self.isAssetIconHidden = !asset.presentation.isVerified
                }
            case .delete:
                if let asset = asset {
                    self.title = "\(asset.presentation.name ?? asset.presentation.unitName ?? "title-unknown".localized)"
                    self.subtitle = "#\(asset.id)"
                    self.isAssetIconHidden = !asset.presentation.isVerified
                }
            }
        }

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
}
