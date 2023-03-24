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

//   SecuredByPaymentOptionsView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SecuredByPaymentOptionsView:
    View,
    ViewModelBindable {
    private lazy var iconAndTitleContentView = UIView()
    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var optionsContentView = MacaroonUIKit.HStackView()

    func customize(_ theme: SecuredByPaymentOptionsViewTheme) {
        addIconAndSubtitleContent(theme)
        addOptionsContent(theme)
    }

    func bindData(_ viewModel: SecuredByPaymentOptionsViewModel?) {
        if let icon = viewModel?.icon {
            iconView.image = icon.uiImage
        } else {
            iconView.image = nil
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        optionsContentView.deleteAllArrangedSubviews()
        viewModel?.options?.forEach(addOption)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension SecuredByPaymentOptionsView {
    private func addIconAndSubtitleContent(_ theme: SecuredByPaymentOptionsViewTheme) {
        addSubview(iconAndTitleContentView)
        iconAndTitleContentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIcon(theme)
        addTitle(theme)
    }

    private func addIcon(_ theme: SecuredByPaymentOptionsViewTheme) {
        iconAndTitleContentView.addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading == 0
            $0.bottom <= 0
        }
    }

    private func addTitle(_ theme: SecuredByPaymentOptionsViewTheme) {
        titleView.customizeAppearance(theme.title)

        iconAndTitleContentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.height >= iconView
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndTitle
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addOptionsContent(_ theme: SecuredByPaymentOptionsViewTheme) {
        addSubview(optionsContentView)
        optionsContentView.spacing = theme.spacingBetweenOptions
        optionsContentView.alignment = .center
        optionsContentView.snp.makeConstraints {
            $0.top == iconAndTitleContentView.snp.bottom + theme.spacingBetweenIconAndTitleContentAndOptions
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
}

extension SecuredByPaymentOptionsView {
    private func addOption(_ option: PaymentOption) {
        let view = makeOptionView(option)
        optionsContentView.addArrangedSubview(view)
    }

    private func makeOptionView(_ option: PaymentOption) -> UIView {
        let view = UIImageView()
        view.image = option.image.uiImage
        return view
    }
}
