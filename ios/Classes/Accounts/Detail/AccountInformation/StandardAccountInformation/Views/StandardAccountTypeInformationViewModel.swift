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

//   StandardAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct StandardAccountTypeInformationViewModel: AccountTypeInformationViewModel {
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

extension StandardAccountTypeInformationViewModel {
    mutating func bindTitle() {
        title =
            "title-account-type"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeIcon() {
        typeIcon = "icon-standard-account".uiImage
    }

    mutating func bindTypeTitle() {
        typeTitle =
            "title-standard"
                .localized
                .bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeDescription() {
        let descriptionText = "standard-account-type-description".localized.footnoteRegular()

        var descriptionHighlightedTextAttributes = Typography.footnoteMediumAttributes(alignment: .center)
        descriptionHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let descriptionHighlightedText = HighlightedText(
            text: "standard-account-type-description-highlighted-text".localized,
            attributes: descriptionHighlightedTextAttributes
        )

        typeDescription = TypeDescriptionTextProvider(
            text: descriptionText,
            highlightedText: descriptionHighlightedText
        )
    }
}
