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
//   WCTransactionRequestBottomViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestBottomViewModel {
    private(set) var senderAddress: String?
    private(set) var networkFee: String?
    private(set) var warningMessage: String?
    private(set) var assetIcon: UIImage?
    private(set) var balance: String?
    private(set) var showDetailsActionTitle: String?

    init(
        transaction: WCTransaction,
        account: Account?,
        asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        let warningCount = transaction.transactionDetail?.warningCount ?? 0
        senderAddress = transaction.requestedSigner.account?.name ?? transaction.requestedSigner.account?.address
        warningMessage = warningCount > 0 ? "node-settings-warning-title".localized: nil
        assetIcon = account?.typeImage

        bindNetworkFee(
            transaction: transaction,
            currencyFormatter: currencyFormatter
        )
        bindBalance(
            transaction: transaction,
            account: account,
            asset: asset,
            currencyFormatter: currencyFormatter
        )
        showDetailsActionTitle = "single-transaction-request-show-detail-title".localized
    }

    init(
        data: WCArbitraryData,
        account: Account?,
        currencyFormatter: CurrencyFormatter
    ) {
        senderAddress =
            data.requestedSigner.account?.name ??
            data.requestedSigner.account?.address
        assetIcon = account?.typeImage

        bindNetworkFee(
            data: data,
            currencyFormatter: currencyFormatter
        )
        bindBalance(
            data: data,
            account: account,
            currencyFormatter: currencyFormatter
        )
        showDetailsActionTitle = "title-show-details".localized
    }
}

extension WCSingleTransactionRequestBottomViewModel {
    private func bindNetworkFee(
        transaction: WCTransaction,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let fee = transaction.transactionDetail?.fee ?? 0
        let text = currencyFormatter.format(fee.toAlgos)

        networkFee = text.someString
    }

    private func bindBalance(
        transaction: WCTransaction,
        account: Account?,
        asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        if let asset = asset as? StandardAsset {
            balance = "\(asset.amountWithFraction) \(asset.unitNameRepresentation)"
        } else {
            guard let amount = account?.algo.amount else {
                balance = nil
                return
            }

            if transaction.transactionDetail?.currentAssetId != nil {
                balance = nil
                return
            }

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            balance = currencyFormatter.format(amount.toAlgos)
        }
    }
}

extension WCSingleTransactionRequestBottomViewModel {
    private func bindBalance(
        data: WCArbitraryData,
        account: Account?,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let amount = account?.algo.amount else {
            balance = nil
            return
        }

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()
        balance = currencyFormatter.format(amount.toAlgos)
    }

    private func bindNetworkFee(
        data: WCArbitraryData,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let fee: UInt64 = .zero
        let text = currencyFormatter.format(fee.toAlgos)
        networkFee = text.someString
    }
}
