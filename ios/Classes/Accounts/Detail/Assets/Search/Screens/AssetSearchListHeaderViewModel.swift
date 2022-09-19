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

//   AssetSearchListHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetSearchListHeaderViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?

    init(
        _ title: String
    ) {
        bind(title)
    }
}

extension AssetSearchListHeaderViewModel {
    mutating func bind(
        _ title: String
    ) {
        bindTitle(title)
        bindTitleStyle()
    }

    mutating func bindTitle(
        _ title: String
    ) {
        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.02

        self.title = .attributedString(
            title
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
    }
}
