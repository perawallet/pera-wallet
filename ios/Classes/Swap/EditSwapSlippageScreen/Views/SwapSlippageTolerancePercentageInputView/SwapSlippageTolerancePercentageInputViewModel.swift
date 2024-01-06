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

//   SwapAmountPercentageInputViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapSlippageTolerancePercentageInputViewModel: AdjustableSingleSelectionInputViewModel {
    private(set) var customText: String?
    private(set) var customTextOptionIndex: Int?
    private(set) var options: [Segment] = []
    private(set) var selectedOptionIndex: Int?

    let percentagesPreset: [SwapSlippageTolerancePercentage] = [
        PresetSwapSlippageTolerancePercentage(
            value: 0,
            customTitle: "swap-slippage-percentage-custom".localized
        ),
        PresetSwapSlippageTolerancePercentage(value: SlippageTolerancePercentage.halfPercent),
        PresetSwapSlippageTolerancePercentage(value: SlippageTolerancePercentage.onePercent),
        PresetSwapSlippageTolerancePercentage(value: SlippageTolerancePercentage.twoPercent),
        PresetSwapSlippageTolerancePercentage(value: SlippageTolerancePercentage.fivePercent)
    ]

    init(percentage: SwapSlippageTolerancePercentage?) {
        bindCustomText(percentage: percentage)
        bindOptions(percentage: percentage)
    }
}

extension SwapSlippageTolerancePercentageInputViewModel {
    mutating func bindCustomText(percentage: SwapSlippageTolerancePercentage?) {
        let selectedPercentage = percentage.unwrap(where: { !$0.isPreset })
        let newCustomText = selectedPercentage?.title
        customText = newCustomText

        /// <note>
        /// if percentagesPreset[0] == 'custom'
        customTextOptionIndex = 0
        selectedOptionIndex =  newCustomText.isNilOrEmpty ? nil : 0
    }

    mutating func bindOptions(percentage: SwapSlippageTolerancePercentage?) {
        let selectedPercentage = percentage.unwrap(where: \.isPreset)

        var newOptions: [SwapSlippageTolerancePercentageOption] = []
        percentagesPreset.enumerated().forEach {
            index, percentage in

            let option = SwapSlippageTolerancePercentageOption(percentage)
            newOptions.append(option)

            if percentage.title == selectedPercentage?.title {
                selectedOptionIndex = index
            }
        }
        options = newOptions
    }
}

struct SwapSlippageTolerancePercentageOption: Segment {
    let layout: Segment.Layout
    let style: Segment.Style
    let contentEdgeInsets: UIEdgeInsets

    init(_ percentage: SwapSlippageTolerancePercentage) {
        self.layout = .none
        self.style = [
            .backgroundImage([
                .normal("swap-selector-background-normal"),
                .selected("swap-selector-background-selected")
            ]),
            .font(Typography.footnoteMedium()),
            .title(percentage.title),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .selected(Colors.Helpers.positive)
            ]),
        ]
        self.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
    }
}
