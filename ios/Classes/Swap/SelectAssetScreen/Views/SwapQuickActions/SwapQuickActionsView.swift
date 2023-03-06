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

//   SwapQuickActionsView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapQuickActionsView:
    MacaroonUIKit.BaseView,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .switchAssets: UIBlockInteraction(),
        .editAmount: UIBlockInteraction(),
        .setMaxAmount: UIBlockInteraction()
    ]

    private let leftQuickActionsView: SwapQuickActionsGroupView
    private let rightQuickActionsView: SwapQuickActionsGroupView

    init(_ theme: SwapQuickActionsViewTheme = .init()) {
        self.leftQuickActionsView = .init(theme.leftQuickActions)
        self.rightQuickActionsView = .init(theme.rightQuickActions)

        super.init(frame: .zero)

        addUI(theme)
    }

    func bind(_ viewModel: SwapQuickActionsViewModel?) {
        bindLeftQuickActions(viewModel)
        bindRightQuickActions(viewModel)
    }
}

extension SwapQuickActionsView {
    private func addUI(_ theme: SwapQuickActionsViewTheme) {
        addLeftQuickActions(theme)
        addRightQuickActions(theme)
    }

    private func addLeftQuickActions(_ theme: SwapQuickActionsViewTheme) {
        addSubview(leftQuickActionsView)
        leftQuickActionsView.fitToIntrinsicSize()
        leftQuickActionsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addRightQuickActions(_ theme: SwapQuickActionsViewTheme) {
        addSubview(rightQuickActionsView)
        rightQuickActionsView.fitToIntrinsicSize()
        rightQuickActionsView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= leftQuickActionsView.snp.trailing + 8
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension SwapQuickActionsView {
    private func bindLeftQuickActions(_ viewModel: SwapQuickActionsViewModel?) {
        guard let viewModel = viewModel else {
            leftQuickActionsView.bind(nil)
            leftQuickActionsView.selector = nil
            return
        }

        let leftQuickActionItems: [any SwapQuickActionItem] = [
            viewModel.switchAssetsQuickActionItem
        ]
        leftQuickActionsView.bind(leftQuickActionItems)

        leftQuickActionsView.selector = { [weak self] _ in
            guard let self = self else { return }
            self.uiInteractions[.switchAssets]?.publish()
        }
    }

    private func bindRightQuickActions(_ viewModel: SwapQuickActionsViewModel?) {
        guard let viewModel = viewModel else {
            rightQuickActionsView.bind(nil)
            rightQuickActionsView.selector = nil
            return
        }

        let rightQuickActionItems: [any SwapQuickActionItem] = [
            viewModel.editAmountQuickActionItem,
            viewModel.setMaxAmountQuickActionItem
        ]
        rightQuickActionsView.bind(rightQuickActionItems)

        rightQuickActionsView.selector = { [weak self] index in
            guard let self = self else { return }

            let event: Event?
            switch index {
            case 0: event = .editAmount
            case 1: event = .setMaxAmount
            default: event = nil
            }

            let interaction = event.unwrap { self.uiInteractions[$0] }
            interaction?.publish()
        }
    }
}

extension SwapQuickActionsView {
    func setLeftQuickActionsHidden(
        _ isHidden: Bool
    ) {
        leftQuickActionsView.isHidden = isHidden
    }

    func setRightQuickActionsHidden(
        _ isHidden: Bool
    ) {
        rightQuickActionsView.isHidden = isHidden
    }
    
    func setLeftQuickActionsEnabled(
        _ isEnabled: Bool
    ) {
        leftQuickActionsView.setActionsEnabled(isEnabled)
    }
}

extension SwapQuickActionsView {
    enum Event {
        case switchAssets
        case editAmount
        case setMaxAmount
    }
}
