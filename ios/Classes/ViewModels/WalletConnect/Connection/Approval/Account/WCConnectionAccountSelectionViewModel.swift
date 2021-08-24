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
//   WCConnectionAccountSelectionViewModel.swift

import UIKit

class WCConnectionAccountSelectionViewModel {
    private(set) var image: UIImage?
    private(set) var accountName: String?
    private(set) var detail: String?

    init(account: Account) {
        setImage(from: account)
        setAccountName(from: account)
        setDetail(from: account)
    }

    private func setImage(from account: Account) {
        image = account.accountImage()
    }

    private func setAccountName(from account: Account) {
        accountName = account.name ?? account.address.shortAddressDisplay()
    }

    private func setDetail(from account: Account) {
        if let amount = account.amount.toAlgos.toAlgosStringForLabel {
            detail = "\(amount) \("asset-algos-title".localized)"
        }
    }
}
