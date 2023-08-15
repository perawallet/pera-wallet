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

//   RekeyConfirmationBodyViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeyConfirmationBodyViewModel {
    private(set) var text: TextProvider?
    private(set) var highlightedText: HighlightedText?

    init(authAccount: Account?) {
        bindText(authAccount)
        bindHighlightedText(authAccount)
    }

    struct HighlightedText {
        let text: String
        let attributes: TextAttributeGroup
    }
}

extension RekeyConfirmationBodyViewModel {
    private mutating func bindText(_ authAccount: Account?) {
        let aText: String

        let hasAuthAccount = authAccount != nil
        if hasAuthAccount {
            aText = "rekey-rekeyed-to-any-account-confirmation-body".localized
        } else {
            aText = "rekey-any-to-any-account-confirmation-body".localized
        }

        text = aText.bodyRegular()
    }

    private mutating func bindHighlightedText(_ authAccount: Account?) {
        let aText: String
        
        let hasAuthAccount = authAccount != nil
        if hasAuthAccount {
            aText = "rekey-rekeyed-to-any-account-confirmation-body-highlighted-text".localized
        } else {
            aText = "rekey-any-to-any-account-confirmation-body-highlighted-text".localized
        }

        var attributes = Typography.bodyMediumAttributes()
        attributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        highlightedText = HighlightedText(
            text: aText,
            attributes: attributes
        )
    }
}
