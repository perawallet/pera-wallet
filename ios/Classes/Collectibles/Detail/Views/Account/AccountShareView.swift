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

//   AccountShareView.swift

import UIKit
import MacaroonUIKit

final class AccountShareView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performCopy: TargetActionInteraction(),
        .performShareQR: TargetActionInteraction()
    ]

    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var copyButton = UIButton()
    private lazy var shareQRButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: AccountShareViewTheme
    ) {
        addImageView(theme)
        addShareQRButton(theme)
        addCopyButton(theme)
        addNameLabel(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        startPublishing(
            event: .performCopy,
            for: copyButton
        )

        startPublishing(
            event: .performShareQR,
            for: shareQRButton
        )
    }
}

extension AccountShareView {
    private func addImageView(_ theme: AccountShareViewTheme) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top == theme.verticalInset
            $0.bottom == theme.verticalInset
            $0.fitToSize(theme.imageSize)
            $0.leading == 0
        }
    }

    private func addShareQRButton(_ theme: AccountShareViewTheme) {
        shareQRButton.customizeAppearance(theme.shareQR)

        addSubview(shareQRButton)
        shareQRButton.snp.makeConstraints {
            $0.top == theme.verticalInset
            $0.bottom == theme.verticalInset
            $0.fitToSize(theme.buttonSize)
            $0.trailing == 0
        }
    }

    private func addCopyButton(_ theme: AccountShareViewTheme) {
        copyButton.customizeAppearance(theme.copy)

        addSubview(copyButton)
        copyButton.snp.makeConstraints {
            $0.top == theme.verticalInset
            $0.bottom == theme.verticalInset
            $0.trailing == shareQRButton.snp.leading
            $0.fitToSize(theme.buttonSize)
        }
    }

    private func addNameLabel(_ theme: AccountShareViewTheme) {
        nameLabel.customizeAppearance(theme.name)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading == imageView.snp.trailing + theme.nameHorizontalPaddings.leading
            $0.trailing == copyButton.snp.leading - theme.nameHorizontalPaddings.trailing
        }
    }
}

extension AccountShareView {
    func bindData(_ viewModel: AccountShareViewModel?) {
        imageView.image = viewModel?.image
        nameLabel.editText = viewModel?.name
    }
}

extension AccountShareView {
    enum Event {
        case performCopy
        case performShareQR
    }
}
