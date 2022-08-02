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

//   TransactionOptionListActionViewModel.swift

import MacaroonUIKit

protocol TransactionOptionListActionViewModel: ListActionViewModel { }

extension TransactionOptionListActionViewModel {
    static func getTitle(
        _ aTitle: String?,
        _ aTitleColor: Color? = nil
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        var attributes: TextAttributeGroup = [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .lineBreakMode(.byWordWrapping),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]

        if let textColor = aTitleColor {
            attributes.insert(.textColor(textColor))
        }

        return .attributedString(aTitle.attributed(attributes))
    }

    static func getSubtitle(
        _ aSubtitle: String?
    ) -> EditText? {
        guard let aSubtitle = aSubtitle else {
            return nil
        }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        return .attributedString(
            aSubtitle.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingMiddle),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}
