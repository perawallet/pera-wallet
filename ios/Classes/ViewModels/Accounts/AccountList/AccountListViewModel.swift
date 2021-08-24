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
//  AccountListViewModel.swift

import UIKit

class AccountListViewModel {
    private(set) var name: String?
    private(set) var accountImage: UIImage?
    private(set) var detail: String?
    private(set) var attributedDetail: NSAttributedString?
    private(set) var detailColor: UIColor?
    private(set) var isDisplayingImage: Bool = false

    init(account: Account, mode: AccountListViewController.Mode) {
        setName(from: account)
        setAccountImage(from: account)
        setDetail(from: account, for: mode)
        setDetailColor(from: mode)
        setIsDisplayingImage(from: mode)
    }

    private func setName(from account: Account) {
        name = account.name
    }

    private func setAccountImage(from account: Account) {
        accountImage = account.accountImage()
    }

    private func setDetail(from account: Account, for mode: AccountListViewController.Mode) {
        switch mode {
        case .walletConnect:
            detail = account.amount.toAlgos.toAlgosStringForLabel
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if let assetDetail = assetDetail {
                guard let assetAmount = account.amount(for: assetDetail)else {
                    return
                }

                let amountText = "\(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "")".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(Colors.Text.primary)
                ])

                let codeText = " (\(assetDetail.getAssetCode()))".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(Colors.Text.tertiary)
                ])
                attributedDetail = amountText + codeText
            } else {
                detail = account.amount.toAlgos.toAlgosStringForLabel
            }
        }
    }

    private func setDetailColor(from mode: AccountListViewController.Mode) {
        switch mode {
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if assetDetail == nil {
                detailColor = Colors.Text.primary
            }
        case .walletConnect:
            detailColor = Colors.Text.primary
        }
    }

    private func setIsDisplayingImage(from mode: AccountListViewController.Mode) {
        switch mode {
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if assetDetail == nil {
                isDisplayingImage = true
            }
        case .walletConnect:
            isDisplayingImage = true
        }
    }
}
