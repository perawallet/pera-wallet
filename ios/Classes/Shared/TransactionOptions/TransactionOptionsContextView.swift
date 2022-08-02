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
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: UIControlInteraction(),
        .send: UIControlInteraction(),
        .receive: UIControlInteraction(),
        .more: UIControlInteraction()
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

        addActions(theme)
    }

    private func addActions(
        _ theme: TransactionOptionsViewTheme
    ) {
        actions.forEach {
            switch $0 {
            case .buyAlgo:
                addAction(
                    theme: theme.action,
                    viewModel: BuyAlgoTransactionOptionListActionViewModel(),
                    event: .buyAlgo
                )
            case .send:
                addAction(
                    theme: theme.action,
                    viewModel: SendTransactionOptionListActionViewModel(),
                    event: .send
                )
            case .receive:
                addAction(
                    theme: theme.action,
                    viewModel: ReceiveTransactionOptionListActionViewModel(isQR: true),
                    event: .receive
                )
            case .more:
                addAction(
                    theme: theme.action,
                    viewModel: MoreTransactionOptionListActionViewModel(),
                    event: .more
                )
            }
        }
    }

    private func addAction(
        theme: ListActionViewTheme,
        viewModel: TransactionOptionListActionViewModel,
        event: Event
    ) {
        let actionView = ListActionView()

        actionView.customize(theme)
        actionView.bindData(viewModel)

        addArrangedSubview(actionView)

        startPublishing(
            event: event,
            for: actionView
        )
    }
}

extension TransactionOptionsContextView {
    enum Action: CaseIterable {
        case buyAlgo
        case send
        case receive
        case more
    }

    enum Event {
        case buyAlgo
        case send
        case receive
        case more
    }
}
