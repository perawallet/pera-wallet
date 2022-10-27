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

//   ExportAccountListItemHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ExportAccountListItemHeaderViewModel:
    TitleViewModel,
    Hashable {
    private(set) var title: EditText?
    private(set) var titleStyle: TextStyle?

    init() {
        bindTitle()
        bindTitleStyle()
    }
}

extension ExportAccountListItemHeaderViewModel {
    mutating func bindTitle() {
        let title = "web-export-account-list-description".localized
        let textAttributes = NSMutableAttributedString(
            attributedString: title.bodyRegular(lineBreakMode: .byWordWrapping)
        )

        let highlightedText = "web-export-account-list-description-highlighted".localized
        var highlightedTextAttributes = Typography.bodyMediumAttributes(lineBreakMode: .byWordWrapping)
        highlightedTextAttributes.insert(.textColor(Colors.Helpers.negative))

        let highlightedTextRange =
        (textAttributes.string as NSString).range(of: highlightedText)

        textAttributes.addAttributes(
            highlightedTextAttributes.asSystemAttributes(),
            range: highlightedTextRange
        )

        self.title = .attributedString(
            textAttributes
        )
    }

    mutating func bindTitleStyle() {
        titleStyle = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
    }
}
