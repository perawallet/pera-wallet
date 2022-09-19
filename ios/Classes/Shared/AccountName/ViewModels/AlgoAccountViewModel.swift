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

//   AlgoAccountViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AlgoAccountViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var address: String?
    private(set) var amount: String?

    init(
        _ model: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        bindAddress(model)
        bindImage(model)
        bindAmount(
            model,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AlgoAccountViewModel {
    private func bindAddress(_ account: Account) {
        if let accountName = account.name {
            address = accountName
            return
        }

        let accountAddress = account.authAddress ?? account.address
        address = accountAddress.shortAddressDisplay
    }

    private func bindImage(_ account: Account) {
        image = account.typeImage
    }

    private func bindAmount(
        _ account: Account,
        currencyFormatter: CurrencyFormatter
    ) {
        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()

        amount = currencyFormatter.format(account.algo.amount.toAlgos)
    }
}
