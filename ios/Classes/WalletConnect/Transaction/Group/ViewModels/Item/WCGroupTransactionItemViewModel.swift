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
//   WCGroupTransactionItemViewModel.swift

import UIKit

final class WCGroupTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var isAlgos = true
    private(set) var amount: String?
    private(set) var assetName: String?
    private(set) var usdValue: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?
    private(set) var showDetailLabelText: String?

    init(
        transaction: WCTransaction,
        account: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        setHasWarning(from: transaction, and: account)
        setTitle(from: transaction, and: account)
        setIsAlgos(from: transaction)
        setAmount(
            from: transaction,
            and: asset,
            currencyFormatter: currencyFormatter
        )
        setAssetName(from: asset)
        setUsdValue(
            transaction: transaction,
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setAccountInformationViewModel(
            from: account,
            with: asset,
            currencyFormatter: currencyFormatter
        )
        showDetailLabelText = "title-show-transaction-detail".localized
    }

    init(
        account: Account?,
        currencyFormatter: CurrencyFormatter
    ) {
        title = "title-arbitrary-data".localized

        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(
            account: account,
            asset: nil,
            isDisplayingAmount: true,
            currencyFormatter: currencyFormatter
        )

        showDetailLabelText = "title-show-details".localized
    }

    private func setHasWarning(
        from transaction: WCTransaction,
        and account: Account?
    ) {
        guard let transactionDetail = transaction.transactionDetail, account != nil else {
            return
        }

        hasWarning = transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(
        from transaction: WCTransaction,
        and account: Account?
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let transactionType = transactionDetail.transactionType(for: account) else {
            return
        }

        switch transactionType {
        case .algos:
            return
        case .asset:
            return
        case .assetAddition:
            if let assetId = transactionDetail.assetId {
                title = "wallet-connect-transaction-group-asset-addition-title".localized(params: "\(assetId)")
            }
        case .possibleAssetAddition:
            if let assetId = transactionDetail.assetId {
                title = "wallet-connect-transaction-group-possible-asset-addition-title".localized(params: "\(assetId)")
            }
        case .appCall:
            guard let appCallId = transactionDetail.appCallId else {
                return
            }

            if transactionDetail.isAppCreateTransaction {
                title = "wallet-connect-transaction-title-app-creation".localized
                return
            }

            guard let appCallOnComplete = transactionDetail.appCallOnComplete else {
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
                return
            }

            switch appCallOnComplete {
            case .close:
                title = "wallet-connect-transaction-group-app-close-title".localized(params: "\(appCallId)")
            case .optIn:
                title = "wallet-connect-transaction-group-app-opt-in-title".localized(params: "\(appCallId)")
            case .update:
                title = "wallet-connect-transaction-group-app-update-title".localized(params: "\(appCallId)")
            case .delete:
                title = "wallet-connect-transaction-group-app-delete-title".localized(params: "\(appCallId)")
            default:
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
            }
        case .assetConfig:
            break
        case .keyReg:
            break
        }
    }

    private func setIsAlgos(
        from transaction: WCTransaction
    ) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        isAlgos = transactionDetail.isAlgosTransaction
    }

    private func setAmount(
        from transaction: WCTransaction,
        and asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }
        
        if let asset = asset {
            let assetDecimals = asset.decimals

            /// <todo>
            /// Not sure we need this constraint, because the final number should be sent to the
            /// formatter unless the number itself is modified.
            var constraintRules = CurrencyFormattingContextRules()
            constraintRules.maximumFractionDigits = assetDecimals

            currencyFormatter.formattingContext = .standalone(constraints: constraintRules)
            currencyFormatter.currency = nil

            let finalAmount = transactionDetail.amount.assetAmount(fromFraction: assetDecimals)
            let finalAmountText = currencyFormatter.format(finalAmount)
            let text = finalAmountText.someString

            amount = text
        } else {
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            amount = currencyFormatter.format(transactionDetail.amount.toAlgos).someString
        }
    }

    private func setAssetName(
        from asset: Asset?
    ) {
        guard let asset = asset else {
            assetName = "ALGO"
            return
        }

        assetName = asset.naming.displayNames.secondaryName
    }

    private func setUsdValue(
        transaction: WCTransaction,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard
            let amount = transaction.transactionDetail?.amount,
            let currencyValue = currency.primaryValue
        else {
            usdValue = nil
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

            usdValue = currencyFormatter.format(amountInCurrency)
        } catch {
            usdValue = nil
        }
    }

    private func setAccountInformationViewModel(
        from account: Account?,
        with asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let account = account else {
            return
        }

        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(
            account: account,
            asset: asset,
            isDisplayingAmount: true,
            currencyFormatter: currencyFormatter
        )
    }
}

extension WCGroupTransactionItemViewModel {
    static func calculatePreferredSize(
        _ viewModel: WCGroupTransactionItemViewModel,
        fittingIn size: CGSize
    ) -> CGSize {
        var currentSize = size
        var defaultHeight: CGFloat = 65

        currentSize.width -= 45 // 45 is for main insets

        if viewModel.accountInformationViewModel != nil {
            defaultHeight += 36 + 8 // 36 is for account view, 8 is for top inset
        }

        if viewModel.usdValue != nil {
            defaultHeight += 20
        }

        guard viewModel.title == nil else {
            guard let title = viewModel.title else {
                return size
            }

            let totalSize = title.boundingSize(
                attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
                multiline: true,
                fittingSize: currentSize
            )

            return CGSize(width: size.width, height: totalSize.height + defaultHeight)
        }

        guard let amount = viewModel.amount else {
            return size
        }

        if viewModel.hasWarning {
            currentSize.width -= 24 + 4 // 24 is for warning icon size, 4 is for spacing
        }

        guard let assetName = viewModel.assetName else {
            let amountSize = viewModel.amount?.boundingSize(
                attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
                multiline: true,
                fittingSize: currentSize
            )

            let fittingSize = amountSize ?? size
            return CGSize(width: size.width, height: fittingSize.height + defaultHeight)
        }

        currentSize.width -= 4 // 4 is for spacing if asset name

        let totalSize = amount.appending(assetName).boundingSize(
            attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
            multiline: true,
            fittingSize: currentSize
        )

        return CGSize(width: size.width, height: totalSize.height + defaultHeight)
    }
}
