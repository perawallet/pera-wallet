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

//   CollectibleMediaErrorView.swift

import UIKit
import MacaroonUIKit

final class CollectibleMediaErrorView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var imageView = UIImageView()
    private lazy var messageLabel = UILabel()
    
    func customize(
        _ theme: CollectibleMediaErrorViewTheme
    ) {
        addMessageLabel(theme)
        addImageView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleMediaErrorView {
    private func addMessageLabel(
        _ theme: CollectibleMediaErrorViewTheme
    ) {
        messageLabel.customizeAppearance(theme.message)

        addSubview(messageLabel)
        messageLabel.fitToVerticalIntrinsicSize()
        messageLabel.snp.makeConstraints {
            $0.top == theme.messageVerticalInset
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addImageView(
        _ theme: CollectibleMediaErrorViewTheme
    ) {
        imageView.customizeAppearance(theme.icon)

        addSubview(imageView)
        imageView.fitToVerticalIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == messageLabel.snp.leading - theme.horizontalInset
            $0.centerY == messageLabel
            $0.fitToSize(theme.iconSize)
        }
    }
}

extension CollectibleMediaErrorView {
    func bindData(
        _ viewModel: CollectibleMediaErrorViewModel?
    ) {
        imageView.image = viewModel?.image
        messageLabel.editText = viewModel?.message
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaErrorViewModel?,
        for theme: CollectibleMediaErrorViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let messageWidth =
            size.width -
            theme.iconSize.w -
            theme.horizontalInset
        let messageSize = viewModel.message.boundingSize(
            multiline: true,
            fittingSize: CGSize((messageWidth, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            messageSize.height +
            theme.messageVerticalInset
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}
