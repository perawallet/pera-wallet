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
//   WCGroupTransactionItemViewModel.swift

import UIKit

class WCGroupTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var isAlgos = true
    private(set) var amount: String?
    private(set) var assetName: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init(transaction: WCTransaction, account: Account?, assetDetail: AssetDetail?) {
        setHasWarning(from: transaction)
        setTitle(from: transaction, and: account)
        setIsAlgos(from: transaction)
        setAmount(from: transaction, and: assetDetail)
        setAssetName(from: assetDetail)
        setAccountInformationViewModel(from: account, with: assetDetail)
    }

    private func setHasWarning(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        hasWarning = transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(from transaction: WCTransaction, and account: Account?) {
        guard let transactionDetail = transaction.transactionDetail,
              let transactionType = transactionDetail.transactionType(for: account) else {
            return
        }

        switch transactionType {
        case .algos:
            let receiver = transactionDetail.receiver?.shortAddressDisplay()
            title = "wallet-connect-transaction-group-algos-title".localized(params: receiver ?? "")
        case .asset:
            let receiver = transactionDetail.receiver?.shortAddressDisplay()
            title = "wallet-connect-transaction-group-asset-title".localized(params: receiver ?? "")
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

            guard let appCallOnComplete = transactionDetail.appCallOnComplete else {
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
                return
            }

            switch appCallOnComplete {
            case .close:
                title = "wallet-connect-transaction-group-app-close-title".localized(params: "\(appCallId)")
            case .optIn:
                title = "wallet-connect-transaction-group-app-opt-in-title".localized(params: "\(appCallId)")
            default:
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
            }
        }
    }

    private func setIsAlgos(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        isAlgos = transactionDetail.isAlgosTransaction
    }

    private func setAmount(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }
        
        if let assetDetail = assetDetail {
            let decimals = assetDetail.fractionDecimals
            amount = transactionDetail.amount.assetAmount(fromFraction: decimals).toFractionStringForLabel(fraction: decimals) ?? ""
        } else {
            amount = transactionDetail.amount.toAlgos.toAlgosStringForLabel ?? ""
        }
    }

    private func setAssetName(from assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail else {
            return
        }

        assetName = assetDetail.getDisplayNames().1
    }

    private func setAccountInformationViewModel(from account: Account?, with assetDetail: AssetDetail?) {
        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(account: account, assetDetail: assetDetail)
    }
}
