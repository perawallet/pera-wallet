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

//   SwapConfirmPriceImpactInfoViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapConfirmPriceImpactInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var iconTintColor: Color?
    private(set) var detail: TextProvider?
    private(set) var action: Image?

    init(
        _ quote: SwapQuote
    ) {
        bindTitle(quote)
        bindIcon(quote)
        bindDetail(quote)
        action = nil
    }
}

extension SwapConfirmPriceImpactInfoViewModel {
    mutating func bindTitle(
        _ quote: SwapQuote
    ) {
        guard let priceImpact = quote.priceImpact else {
            title = nil
            return
        }

        let aTitle = "swap-price-impact-title".localized

        let attributes: TextAttributeGroup

        if priceImpact > PriceImpactLimit.fivePercent {
            var someAttributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
            someAttributes.insert(.textColor(Colors.Helpers.negative))
            attributes = someAttributes
        } else {
            var someAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
            someAttributes.insert(.textColor(Colors.Text.gray))
            attributes = someAttributes
        }

        title = aTitle.attributed(attributes)
    }

    mutating func bindIcon(
        _ quote: SwapQuote
    ) {
        guard let priceImpact = quote.priceImpact else {
            icon = nil
            iconTintColor = nil
            return
        }

        icon = "icon-info-20"

        if priceImpact > PriceImpactLimit.fivePercent {
            iconTintColor = Colors.Helpers.negative
        } else {
            iconTintColor = Colors.Text.grayLighter
        }
    }

    mutating func bindDetail(
        _ quote: SwapQuote
    ) {
        guard let priceImpact = quote.priceImpact else {
            detail = nil
            return
        }

        let aDetail = priceImpact
            .doubleValue
            .toPercentageWith(fractions: 3)

        let attributes: TextAttributeGroup

        if priceImpact > PriceImpactLimit.fivePercent {
            var someAttributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
            someAttributes.insert(.textColor(Colors.Helpers.negative))
            attributes = someAttributes
        } else {
            var someAttributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
            someAttributes.insert(.textColor(Colors.Text.main))
            attributes = someAttributes
        }

        detail = aDetail?.attributed(attributes)
    }
}
