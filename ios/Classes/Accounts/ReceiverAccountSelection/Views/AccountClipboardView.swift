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
//   AccountClipboardView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountClipboardView:
    View,
    TripleShadowDrawable,
    ViewModelBindable {

    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()

    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    private lazy var titleLabel = UILabel()
    private lazy var addressLabel = UILabel()
    private lazy var copyIconView = UIImageView()

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        drawAppearance(
            secondShadow: secondShadow
        )
        drawAppearance(
            thirdShadow: thirdShadow
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let secondShadow = secondShadow {
            updateOnLayoutSubviews(
                secondShadow: secondShadow
            )
        }

        if let thirdShadow = thirdShadow {
            updateOnLayoutSubviews(
                thirdShadow: thirdShadow
            )
        }
    }

    func customize(_ theme: AccountClipboardViewTheme) {
        draw(shadow: theme.containerFirstShadow)
        draw(secondShadow: theme.containerSecondShadow)
        draw(thirdShadow: theme.containerThirdShadow)

        addTitleLabel(theme)
        addAddressLabel(theme)
        addCopyIconView(theme)

        titleLabel.text = "account-select-clipboard-title".localized
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func bindData(_ viewModel: AccountClipboardViewModel?) {
        addressLabel.text = viewModel?.title
    }
}

extension AccountClipboardView {
    private func addTitleLabel(_ theme: AccountClipboardViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(theme.titleLabelTopInset)
            make.leading.equalToSuperview().inset(theme.titleLabelLeadingInset)
        }
    }

    private func addAddressLabel(_ theme: AccountClipboardViewTheme) {
        addressLabel.customizeAppearance(theme.addressLabel)
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(theme.addressLabelTopOffset)
            make.leading.equalToSuperview().inset(theme.titleLabelLeadingInset)
            make.bottom.equalToSuperview().inset(theme.titleLabelTopInset)
        }
    }

    private func addCopyIconView(_ theme: AccountClipboardViewTheme) {
        copyIconView.customizeAppearance(theme.copyIcon)
        addSubview(copyIconView)
        copyIconView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(theme.copyIconTrailingInset)
            make.bottom.equalToSuperview().inset(theme.copyIconBottomInset)
            make.fitToSize(theme.copyIconSize)
            make.leading.equalTo(addressLabel.snp.trailing).offset(theme.copyIconLeadingOffset).priority(.high)
        }
    }
}
