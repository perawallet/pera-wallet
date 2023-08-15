// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountListItemWithActionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountListItemWithActionView:
    UIView,
    ViewComposable,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var contextView = UIView()
    private lazy var contentView = AccountListItemView()
    private lazy var actionView = MacaroonUIKit.Button()

    func customize(_ theme: AccountListItemWithActionViewTheme) {
        addContext(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AccountListItemWithActionViewModel?) {
        if let content = viewModel?.content {
            contentView.bindData(content)
        } else {
            contentView.prepareForReuse()
        }

        if let action = viewModel?.action {
            actionView.customizeAppearance(action)
        } else {
            actionView.resetAppearance()
        }
    }
}

extension AccountListItemWithActionView {
    private func addContext(_ theme: AccountListItemWithActionViewTheme) {
        addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addContent(theme)
        addAction(theme)
    }

    private func addContent(_ theme: AccountListItemWithActionViewTheme) {
        contentView.customize(theme.content)
        
        contextView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAction(_ theme: AccountListItemWithActionViewTheme) {
        contextView.addSubview(actionView)
        actionView.fitToHorizontalIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == contentView.snp.trailing + theme.spacingBetweenContentAndAction
            $0.bottom <= 0
            $0.trailing == 0
            $0.centerY == 0
        }

        startPublishing(
            event: .performAction,
            for: actionView
        )
    }
}

extension AccountListItemWithActionView {
    enum Event {
        case performAction
    }
}
