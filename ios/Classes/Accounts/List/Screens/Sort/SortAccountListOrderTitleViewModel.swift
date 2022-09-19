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

//   SortAccountListOrderTitleViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SortAccountListOrderTitleViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?

    init() {
        bind(
            "sort-account-list-manually-header-title".localized
        )
    }
}

extension SortAccountListOrderTitleViewModel {
    mutating func bind(
        _ title: String
    ) {
        bindTitle(title)
        bindTitleStyle()
    }

    mutating func bindTitle(
        _ title: String
    ) {
        self.title = .attributedString(
            title
                .footnoteRegular()
        )
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
    }
}
