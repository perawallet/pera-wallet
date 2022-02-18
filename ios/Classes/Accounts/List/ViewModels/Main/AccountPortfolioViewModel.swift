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
//   AccountPortfolioViewModel.swift

import Foundation
import MacaroonUIKit

struct AccountPortfolioViewModel:
    PairedViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var value: EditText?

    init(
        _ model: AccountPortfolio
    ) {
        bind(model)
    }
}

extension AccountPortfolioViewModel {
    mutating func bind(
        _ portfolio: AccountPortfolio
    ) {
        var mPortfolio = portfolio
        mPortfolio.calculate()
        
        bindTitle(mPortfolio)
        bindValue(mPortfolio)
    }
    
    mutating func bindTitle(
        _ portfolio: AccountPortfolio
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        title = .attributedString(
            "account-detail-portfolio-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
            )
    }
    
    mutating func bindValue(
        _ portfolio: AccountPortfolio
    ) {
        let font = Fonts.DMMono.regular.make(36)
        let lineHeightMultiplier = 1.02
        
        value = .attributedString(
            portfolio.valueResult.uiDescription.attributed([
                .font(font),
                .letterSpacing(-0.72),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}

extension AccountPortfolioViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(value)
    }
    
    static func == (
        lhs: AccountPortfolioViewModel,
        rhs: AccountPortfolioViewModel
    ) -> Bool {
        return lhs.value == rhs.value
    }
}
