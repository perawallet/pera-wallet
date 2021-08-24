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
//   WCGroupTransactionAccountInformationViewModel.swift

import Foundation

class WCGroupTransactionAccountInformationViewModel {
    private(set) var accountNameViewModel: AccountNameViewModel?
    private(set) var isAlgos = true
    private(set) var balance: String?
    private(set) var assetName: String?

    init(account: Account?, assetDetail: AssetDetail?) {
        setAccountNameViewModel(from: account)
        setIsAlgos(from: assetDetail)
        setBalance(from: account, and: assetDetail)
        setAssetName(from: assetDetail)
    }

    private func setAccountNameViewModel(from account: Account?) {
        guard let account = account else {
            return
        }

        accountNameViewModel = AccountNameViewModel(account: account)
    }

    private func setIsAlgos(from assetDetail: AssetDetail?) {
        isAlgos = assetDetail == nil
    }

    private func setBalance(from account: Account?, and assetDetail: AssetDetail?) {
        guard let account = account else {
            return
        }

        if let assetDetail = assetDetail {
            balance = account.amountDisplayWithFraction(for: assetDetail)
            return
        }

        balance = account.amount.toAlgos.toAlgosStringForLabel
    }

    private func setAssetName(from assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            assetName = assetDetail.getDisplayNames().1
        }
    }
}
