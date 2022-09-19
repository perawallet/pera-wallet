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
//   WCAssetConfigTransactionItemViewModel.swift

import Foundation

class WCAssetConfigTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var detail: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init(
        transaction: WCTransaction,
        account: Account?,
        asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        setHasWarning(from: transaction, and: account)
        setTitle(from: transaction, and: account)
        setDetail(from: transaction, and: account, with: asset)
        setAccountInformationViewModel(
            from: account,
            with: asset,
            currencyFormatter: currencyFormatter
        )
    }

    private func setHasWarning(
        from transaction: WCTransaction,
        and account: Account?
    ) {
        guard let transactionDetail = transaction.transactionDetail, account != nil else {
            return
        }

        hasWarning = transactionDetail.isAssetDeletionTransaction || transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(
        from transaction: WCTransaction,
        and account: Account?
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let transactionType = transactionDetail.transactionType(for: account),
              transactionDetail.isAssetConfigTransaction else {
            return
        }

        switch transactionType {
        case let .assetConfig(type):
            switch type {
            case .create:
                title = "wallet-connect-asset-creation-title".localized
            case .reconfig:
                title = "wallet-connect-asset-reconfiguration-title".localized
            case .delete:
                title = "wallet-connect-asset-deletion-title".localized
            }
        default:
            break
        }
    }

    private func setDetail(
        from transaction: WCTransaction,
        and account: Account?,
        with asset: Asset?
    ) {
        guard let transactionDetail = transaction.transactionDetail,
              let transactionType = transactionDetail.transactionType(for: account),
              transactionDetail.isAssetConfigTransaction else {
            return
        }

        switch transactionType {
        case let .assetConfig(type):
            switch type {
            case .create:
                if let assetConfigParams = transactionDetail.assetConfigParams {
                    detail = "\(assetConfigParams.name ?? assetConfigParams.unitName ?? "title-unknown".localized)"
                }
            case .reconfig:
                if let asset = asset {
                    detail = "\(asset.naming.name ?? asset.naming.unitName ?? "title-unknown".localized)"
                }
            case .delete:
                if let assetId = transactionDetail.assetIdBeingConfigured {
                    detail = "#\(assetId)"
                }
            }
        default:
            break
        }
    }

    private func setAccountInformationViewModel(
        from account: Account?,
        with asset: Asset?,
        currencyFormatter: CurrencyFormatter
    ) {
        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(
            account: account,
            asset: nil,
            isDisplayingAmount: false,
            currencyFormatter: currencyFormatter
        )
    }
}
