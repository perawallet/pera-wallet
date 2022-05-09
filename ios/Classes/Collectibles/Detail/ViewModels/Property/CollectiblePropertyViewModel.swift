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

//   CollectiblePropertyViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectiblePropertyViewModel:
    ViewModel,
    Hashable {
    private(set) var name: EditText?
    private(set) var value: EditText?

    init(
        _ property: CollectibleTrait
    ) {
        bindName(property)
        bindValue(property)
    }
}

extension CollectiblePropertyViewModel {
    private mutating func bindName(
        _ property: CollectibleTrait
    ) {
        guard let aName = property.displayName?.uppercased() else {
            return
        }

        let font = Fonts.DMSans.regular.make(11)
        let lineHeightMultiplier = 1.12

        name = .attributedString(
            aName.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }

    private mutating func bindValue(
        _ property: CollectibleTrait
    ) {
        guard let aValue = property.displayValue else {
            return
        }

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        value = .attributedString(
            aValue.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}
