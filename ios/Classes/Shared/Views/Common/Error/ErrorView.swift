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

//
//   ErrorView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ErrorView:
    View,
    ViewModelBindable {
    private lazy var iconView = ImageView()
    private lazy var messageView = Label()

    /// <todo>
    /// Rename these methods `build()`
    func customize(
        _ theme: ErrorViewTheme
    ) {
        addIcon(theme)
        addMessage(theme)
        addSeparator(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: ErrorViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        messageView.editText = viewModel?.message
    }
}

extension ErrorView {
    private func addIcon(
        _ theme: ErrorViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addMessage(
        _ theme: ErrorViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        addSubview(messageView)
        messageView.fitToVerticalIntrinsicSize()
        messageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.trailing == 0
        }
    }
    
    private func addSeparator(
        _ theme: ErrorViewTheme
    ) {
        let separatorView = attachSeparator(
            theme.separator,
            to: messageView,
            margin: theme.spacingBetweenMessageAndSeparator
        )
        separatorView.snp.makeConstraints {
            $0.bottom == 0
        }
    }
}
