// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   LedgerAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct LedgerAccountTypeInformationViewModel: AccountTypeInformationViewModel {
    private(set) var title: TextProvider?
    private(set) var typeIcon: Image?
    private(set) var typeTitle: TextProvider?
    private(set) var typeFootnote: TextProvider?
    private(set) var typeDescription: TypeDescriptionTextProvider?

    init() {
        bindTitle()
        bindTypeIcon()
        bindTypeTitle()
        bindTypeDescription()
    }
}

extension LedgerAccountTypeInformationViewModel {
    private mutating func bindTitle() {
        title =
            "title-account-type"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindTypeIcon() {
        typeIcon = "icon-ledger-account".uiImage
    }

    private mutating func bindTypeTitle() {
        typeTitle =
            "title-ledger"
                .localized
                .bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindTypeDescription() {
        let descriptionText = "ledger-account-type-description".localized.footnoteRegular()

        var descriptionHighlightedTextAttributes = Typography.footnoteMediumAttributes(alignment: .center)
        descriptionHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let descriptionHighlightedText = HighlightedText(
            text: "ledger-account-type-description-highlighted-text".localized,
            attributes: descriptionHighlightedTextAttributes
        )

        typeDescription = TypeDescriptionTextProvider(
            text: descriptionText,
            highlightedText: descriptionHighlightedText
        )
    }
}
