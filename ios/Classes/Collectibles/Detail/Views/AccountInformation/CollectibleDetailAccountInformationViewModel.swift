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

//   CollectibleDetailAccountInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDetailAccountInformationViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var amount: TextProvider?

    init(_ item: CollectibleAssetItem) {
        bindIcon()
        bindTitle(item)
        bindAmount(item)
    }
}

extension CollectibleDetailAccountInformationViewModel {
    mutating func bindIcon() {
        icon = "icon-wallet-24".templateImage
    }

    mutating func bindTitle(_ item: CollectibleAssetItem) {
        let name = item.account.primaryDisplayName
        title = name.captionMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAmount(_ item: CollectibleAssetItem) {
        let asset = item.asset

        if asset.isPure || !asset.isOwned {
            amount = nil
            return
        }

        let formatter = item.amountFormatter
        formatter.formattingContext = .standalone
        let formattedAmount =
            formatter
                .format(asset.decimalAmount)
                .unwrap { "x" + $0 }

        amount = formattedAmount?.captionRegular(lineBreakMode: .byTruncatingTail)
    }
}
