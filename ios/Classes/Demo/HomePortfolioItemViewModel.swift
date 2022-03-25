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
//   HomePortfolioItemViewModel.swift

import Foundation
import MacaroonUIKit

struct HomePortfolioItemViewModel:
    PairedViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var value: EditText?
    
    init(
        _ model: PortfolioItem
    ) {
        bind(model)
    }
}

extension HomePortfolioItemViewModel {
    mutating func bind(
        _ item: PortfolioItem
    ) {
        bindTitle(item)
        bindValue(item)
    }
    
    mutating func bindTitle(
        _ item: PortfolioItem
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        title = .attributedString(
            item.title.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.left)
                ])
            ])
        )
    }
    
    mutating func bindValue(
        _ item: PortfolioItem
    ) {
        let font = Fonts.DMMono.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        value = .attributedString(
            item.valueResult.uiDescription.attributed([
                .font(font),
                .letterSpacing(-0.3),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ]),
                .textColor(AppColors.Components.Text.main)
            ])
        )
    }
}

extension HomePortfolioItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(value)
    }
    
    static func == (
        lhs: HomePortfolioItemViewModel,
        rhs: HomePortfolioItemViewModel
    ) -> Bool {
        return lhs.value == rhs.value
    }
}
