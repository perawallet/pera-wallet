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
            setData(transaction, for: account, with: currency)
        }
    }

    private let transaction: WCTransaction
    private let account: Account?
    private let currency: Currency?

    init(transaction: WCTransaction, account: Account?, currency: Currency?) {
        self.transaction = transaction
        self.account = account
        self.currency = currency
        
        self.setData(transaction, for: account, with: currency)
    }

    private func setData(_ transaction: WCTransaction, for account: Account?, with currency: Currency?) {
        guard let type = transaction.transactionDetail?.transactionType(for: account) else {
            return
        }

        switch type {
        case .algos:
            self.title = "\(transaction.transactionDetail?.amount.toAlgos.toAlgosStringForLabel ?? "")"
            self.isAssetIconHidden = true
            self.setUsdValue(transaction: transaction, asset: nil, currency: currency)
        case .asset:
            guard let asset = asset else {
                return
            }

            let decimals = asset.presentation.decimals

            let amount = transaction.transactionDetail?.amount.assetAmount(fromFraction: decimals).toFractionStringForLabel(fraction: decimals) ?? ""

            if let assetCode = asset.presentation.hasOnlyAssetName ?
                    asset.presentation.displayNames.primaryName :
                    asset.presentation.displayNames.secondaryName {
                self.title = "\(amount) \(assetCode)"
            }

            self.isAssetIconHidden = !asset.presentation.isVerified

            self.setUsdValue(transaction: transaction, asset: asset, currency: currency)
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
        asset: Asset?,
        currency: Currency?
    ) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue,
              let currencyUsdValue = currency.usdValue,
              let amount = transaction.transactionDetail?.amount else {
                  return
        }

        if let asset = asset {
            guard let assetUSDValue = AssetDecoration(asset: asset).usdValue else {
                return
            }

            let currencyValue = assetUSDValue * amount.assetAmount(fromFraction: asset.presentation.decimals) * currencyUsdValue
            if currencyValue > 0 {
                subtitle = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
            }

            return
        }

        let totalAmount = amount.toAlgos * currencyPriceValue
        subtitle = totalAmount.toCurrencyStringForLabel(with: currency.symbol)
    }
}
