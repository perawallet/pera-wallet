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

//   AssetStatisticsSectionTotalSupplyViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetStatisticsSectionTotalSupplyViewModel: PrimaryTitleViewModel {
    var primaryTitle: TextProvider?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    init(
        asset: Asset,
        amountFormatter: CollectibleAmountFormatter
    ) {
        bindTitle()
        bindIcon()
        bindSubtitle(
            asset: asset,
            amountFormatter: amountFormatter
        )
    }
}

extension AssetStatisticsSectionTotalSupplyViewModel {
    mutating func bindTitle() {
        primaryTitle = "title-total-supply"
            .localized
            .footnoteRegular(
                lineBreakMode: .byTruncatingTail
            )
    }

    mutating func bindIcon() {
        primaryTitleAccessory = "icon-info-20"
    }

    mutating func bindSubtitle(
        asset: Asset,
        amountFormatter: CollectibleAmountFormatter
    ) {
        guard let totalSupply = asset.totalSupply else {
            bindSubtitle(text: nil)
            return
        }

        amountFormatter.formattingContext = .listItem

        let text = amountFormatter.format(totalSupply)
        bindSubtitle(text: text)
    }

    mutating func bindSubtitle(text: String?) {
        secondaryTitle = (text ?? "-").bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }
}
