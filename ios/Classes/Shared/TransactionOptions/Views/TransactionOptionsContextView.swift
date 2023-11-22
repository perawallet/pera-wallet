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
import UIKit

final class TransactionOptionsContextView: VStackView {
    private var uiInteractions: [MacaroonUIKit.UIInteraction] = []

    private let actions: [TransactionOptionListAction]

    init(actions: [TransactionOptionListAction]) {
        self.actions = actions
        super.init()
    }

    func customize(_ theme: TransactionOptionsViewTheme) {
        addContext(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
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

        addActions(theme)
    }

    private func addActions(
        _ theme: TransactionOptionsViewTheme
    ) {
        actions.forEach { action in
            addAction(
                action,
                theme: theme.action
            )
        }
    }

    private func addAction(
        _ action: TransactionOptionListAction,
        theme: ListItemButtonTheme
    ) {
        let actionView = ListItemButton()

        actionView.customize(theme)
        actionView.bindData(action.viewModel)
        actionView.isEnabled = action.isEnabled

        addArrangedSubview(actionView)

        let interaction = GestureInteraction()

        let selector = {
            [unowned actionView] in
            action.handler(actionView)
        }

        interaction.setSelector(selector)
        interaction.attach(to: actionView)

        uiInteractions.append(interaction)
    }
}
