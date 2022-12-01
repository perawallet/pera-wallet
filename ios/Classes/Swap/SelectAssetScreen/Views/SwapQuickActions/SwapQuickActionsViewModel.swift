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

//   SwapQuickActionsViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapQuickActionsViewModel: ViewModel {
    private(set) var switchAssetsQuickActionItem: SwapQuickActionItem
    private(set) var editAmountQuickActionItem: SwapQuickActionItem
    private(set) var setMaxAmountQuickActionItem: SwapQuickActionItem

    init(amountPercentage: SwapAmountPercentage? = nil) {
        self.switchAssetsQuickActionItem = SwapSwitchAssetsQuickActionItem(isEnabled: true)
        self.editAmountQuickActionItem =
            Self.makeEditAmountQuickActionItem(percentage: amountPercentage)
        self.setMaxAmountQuickActionItem = SwapSetMaxAmountQuickActionItem()
    }
}

extension SwapQuickActionsViewModel {
    mutating func bind(amountPercentage: SwapAmountPercentage?) {
        bindEditAmountQuickActionItem(amountPercentage: amountPercentage)
    }

    mutating func bindEditAmountQuickActionItem(amountPercentage: SwapAmountPercentage?) {
        editAmountQuickActionItem = Self.makeEditAmountQuickActionItem(percentage: amountPercentage)
    }

    mutating func bindSwitchAssetsQuickActionItemEnabled(_ isEnabled: Bool) {
        switchAssetsQuickActionItem = SwapSwitchAssetsQuickActionItem(isEnabled: isEnabled)
    }
}

extension SwapQuickActionsViewModel {
    private static func makeEditAmountQuickActionItem(percentage: SwapAmountPercentage?) -> SwapEditAmountQuickActionItem {
        let title = percentage.unwrap { $0.value.doubleValue.toPercentageWith(fractions: 2) }
        return SwapEditAmountQuickActionItem(title: title)
    }
}

struct SwapSwitchAssetsQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets
    let isEnabled: Bool

    init(isEnabled: Bool) {
        self.layout = .none
        self.style = [
            .icon([
                .normal("swap-switch-icon"),
                .disabled("swap-switch-icon-disabled")
            ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 16)
        self.isEnabled = isEnabled
    }
}

struct SwapEditAmountQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets
    let isEnabled: Bool

    init(title: String? = nil) {
        self.layout = title.isNilOrEmpty ? .none : .imageAtRight(spacing: 4)
        self.style = [
            .font(Typography.captionBold()),
            .icon([
                .normal("swap-divider-customize-active-icon")
            ]),
            .title(title.someString),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 12)
        self.isEnabled = true
    }
}

struct SwapSetMaxAmountQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets
    let isEnabled: Bool

    init() {
        self.layout = .none
        self.style = [
            .title("send-transaction-max-button-title".localized),
            .font(Typography.captionBold()),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 12, bottom: 13, right: 16)
        self.isEnabled = true
    }
}
