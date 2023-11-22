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
//  TransactionStatusView.swift

import UIKit
import MacaroonUIKit

final class TransactionStatusView: View {
    private lazy var statusLabel = Label()

    func customize(_ theme: TransactionStatusViewTheme) {
        addStatusLabel(theme)
        drawAppearance(corner: theme.corner)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionStatusView {
    private func addStatusLabel(_ theme: TransactionStatusViewTheme) {
        statusLabel.customizeAppearance(theme.statusLabel)

        addSubview(statusLabel)
        statusLabel.pinToSuperview()
        statusLabel.contentEdgeInsets = theme.statusLabelEdgeInsets
    }
}

extension TransactionStatusView: ViewModelBindable {
    func bindData(_ viewModel: TransactionStatusViewModel?) {
        statusLabel.text = viewModel?.statusLabelTitle
        statusLabel.textColor = viewModel?.statusLabelTextColor?.uiColor

        if viewModel?.status == .pending {
            backgroundColor = .clear
            draw(border: Border(color: Colors.Text.grayLighter.uiColor, width: 1))
        } else {
            backgroundColor = viewModel?.backgroundColor?.uiColor.withAlphaComponent(0.5)
        }
    }
}
