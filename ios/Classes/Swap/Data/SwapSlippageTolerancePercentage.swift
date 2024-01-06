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

//   SwapSlippageTolerancePercentage.swift

import Foundation

protocol SwapSlippageTolerancePercentage {
    var value: Decimal { get }
    var title: String { get }
    var isPreset: Bool { get }
}

struct CustomSwapSlippageTolerancePercentage: SwapSlippageTolerancePercentage {
    let value: Decimal
    let title: String
    let isPreset: Bool

    init(
        value: Decimal,
        title: String? = nil
    ) {
        let percentValue = value / 100

        self.value = percentValue

        if let title = title.unwrapNonEmptyString() {
            self.title = title
        } else {
            self.title = NSDecimalNumber(decimal: value).stringValue
        }

        self.isPreset = false
    }
}

struct PresetSwapSlippageTolerancePercentage: SwapSlippageTolerancePercentage {
    let value: Decimal
    let title: String
    let isPreset: Bool

    init(
        value: Decimal,
        customTitle: String? = nil
    ) {
        let percentValue = value / 100

        self.value = percentValue

        if let customTitle = customTitle.unwrapNonEmptyString() {
            self.title = customTitle
        } else {
            let localizedTitle = percentValue.toPercentageWith(fractions: 2)
            let fallbackTitle = NSDecimalNumber(decimal: value).stringValue
            self.title = localizedTitle ?? fallbackTitle
        }

        self.isPreset = true
    }
}
