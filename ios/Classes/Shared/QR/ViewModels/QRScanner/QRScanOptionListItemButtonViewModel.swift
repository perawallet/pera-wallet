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

//   QRScanOptionListItemButtonViewModel.swift

import MacaroonUIKit

protocol QRScanOptionListItemButtonViewModel: ListItemButtonViewModel { }

extension QRScanOptionListItemButtonViewModel {
    static func getTitle(
        _ aTitle: String?
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        let attributes: TextAttributeGroup = [
            .font(font),
            .lineHeightMultiplier(lineHeightMultiplier, font),
            .paragraph([
                .lineBreakMode(.byWordWrapping),
                .lineHeightMultiple(lineHeightMultiplier)
            ])
        ]

        return .attributedString(aTitle.attributed(attributes))
    }
}
