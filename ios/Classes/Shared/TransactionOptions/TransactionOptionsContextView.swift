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

//   TransactionOptionsContextView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class TransactionOptionsContextView:
    VStackView,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .receive: TargetActionInteraction(),
        .addAsset: TargetActionInteraction(),
        .more: TargetActionInteraction()
    ]

    private let actions: [Action]

    init(actions: [Action] = Action.allCases) {
        self.actions = actions
        super.init()
    }

    func customize(
        _ theme: TransactionOptionsViewTheme
    ) {
        addContext(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}


extension TransactionOptionsContextView {
    private func addContext(
        _ theme: TransactionOptionsViewTheme
    ) {

        spacing = theme.spacingBetweenActions
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top + theme.contentSafeAreaInsets.top,
            leading: theme.contentPaddings.leading + theme.contentSafeAreaInsets.left,
            bottom: theme.contentPaddings.bottom + theme.contentSafeAreaInsets.bottom,
            trailing: theme.contentPaddings.trailing + theme.contentSafeAreaInsets.right
        )
        insetsLayoutMarginsFromSafeArea = false
        isLayoutMarginsRelativeArrangement = true

        addButtons(theme)
    }

    private func addButtons(
        _ theme: TransactionOptionsViewTheme
    ) {
        actions.forEach {
            switch $0 {
            case .buyAlgo:
                addButton(
                    theme: theme.button,
                    viewModel: BuyAlgoTransactionOptionListItemButtonViewModel(),
                    event: .buyAlgo
                )
            case .send:
                addButton(
                    theme: theme.button,
                    viewModel: SendTransactionOptionListItemButtonViewModel(),
                    event: .send
                )
            case .receive:
                addButton(
                    theme: theme.button,
                    viewModel: ReceiveTransactionOptionListItemButtonViewModel(isQR: true),
                    event: .receive
                )
            case .addAsset:
                addButton(
                    theme: theme.button,
                    viewModel: AddAssetTransactionOptionListActionViewModel(),
                    event: .addAsset
                )
            case .more:
                addButton(
                    theme: theme.button,
                    viewModel: MoreTransactionOptionListItemButtonViewModel(),
                    event: .more
                )
            }
        }
    }

    private func addButton(
        theme: ListItemButtonTheme,
        viewModel: TransactionOptionListItemButtonViewModel,
        event: Event
    ) {
        let button = ListItemButton()

        button.customize(theme)
        button.bindData(viewModel)

        addArrangedSubview(button)

        startPublishing(
            event: event,
            for: button
        )
    }
}

extension TransactionOptionsContextView {
    enum Action: CaseIterable {
        case buyAlgo
        case send
        case receive
        case addAsset
        case more
    }

    enum Event {
        case buyAlgo
        case send
        case receive
        case addAsset
        case more
    }
}
