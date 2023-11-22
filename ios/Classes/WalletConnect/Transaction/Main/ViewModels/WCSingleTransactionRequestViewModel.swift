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
//   WCSingleTransactionRequestViewModel.swift

import Foundation
import MacaroonUIKit

final class WCSingleTransactionRequestViewModel {
    private(set) var title: String?

    private(set) var bottomView: WCSingleTransactionRequestBottomViewModel?
    private(set) var middleView: WCSingleTransactionRequestMiddleViewModel?

    init(
        transaction: WCTransaction,
        account: Account?,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bottomView = WCSingleTransactionRequestBottomViewModel(
            transaction: transaction,
            account: account,
            asset: asset,
            currencyFormatter: currencyFormatter
        )
        middleView = WCSingleTransactionRequestMiddleViewModel(
            transaction: transaction,
            account: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        setTitle(transaction: transaction, account: account)
    }

    init(
        data: WCArbitraryData,
        account: Account?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bottomView = WCSingleTransactionRequestBottomViewModel(
            data: data,
            account: account,
            currencyFormatter: currencyFormatter
        )
        middleView = WCSingleTransactionRequestMiddleViewModel(
            data: data,
            account: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        title = "request-title".localized
    }

    private func setTitle(transaction: WCTransaction, account: Account?) {
        guard let transactionDetail = transaction.transactionDetail,
              let type = transactionDetail.transactionType(for: account) else {
                  return
        }

        switch type {
        case .algos, .asset:
            self.title = "wallet-connect-transaction-title-transaction".localized
        case .assetAddition:
            self.title = "wallet-connect-transaction-title-opt-in".localized
        case .possibleAssetAddition:
            self.title = "wallet-connect-transaction-title-possible-opt-in".localized
        case .appCall:

            let appCallOncomplete = transactionDetail.appCallOnComplete ?? .noOp

            switch appCallOncomplete {
            case .delete:
                self.title = "wallet-connect-transaction-title-app-delete".localized
            case .update:
                self.title = "wallet-connect-transaction-title-app-update".localized
            default:
                if transactionDetail.isAppCreateTransaction {
                    self.title = "wallet-connect-transaction-title-app-create".localized
                } else {
                    self.title = "wallet-connect-transaction-title-app-call".localized
                }
            }

        case .assetConfig(let type):
            switch type {
            case .create:
                self.title = "wallet-connect-asset-creation-title".localized
            case .reconfig:
                self.title = "wallet-connect-asset-reconfiguration-title".localized
            case .delete:
                self.title = "wallet-connect-asset-deletion-title".localized
            }
        case .keyReg:
            self.title = "wallet-connect-transaction-title-transaction".localized
        }

        if self.title == nil {
            self.title = "wallet-connect-transaction-title-transaction".localized
        }
    }
}
