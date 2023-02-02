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

//   CollectibleDetailHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleDetailHeaderViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?

    init(
        _ item: SingleLineIconTitleItem
    ) {
        bindTitle(item)
        bindTitleStyle()
    }
}

extension CollectibleDetailHeaderViewModel {
    mutating func bindTitle(
        _ item: SingleLineIconTitleItem
    ) {
        guard let text = item.title else {
            return
        }

        title = .attributedString(
            text
                .bodyMedium(lineBreakMode: .byTruncatingTail)
        )
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
    }
}

extension CollectibleDetailHeaderViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }

    static func == (
        lhs: CollectibleDetailHeaderViewModel,
        rhs: CollectibleDetailHeaderViewModel
    ) -> Bool {
        return lhs.title == rhs.title
    }
}
