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

//   AssetQuickActionView.swift

import UIKit
import MacaroonUIKit

final class AssetQuickActionView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var button = Button(.imageAtLeft(spacing: 8))
    private lazy var titleLabel = Label()
    private lazy var accountTypeImageView = ImageView()
    private lazy var accountNameLabel = Label()

    func customize(_ theme: AssetQuickActionViewTheme) {
        draw(shadow: theme.containerShadow)
        
        addButton(theme)
        addTitle(theme)
        addAccountTypeImage(theme)
        addAccountName(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AssetQuickActionViewModel?) {
        if let firstShadow = viewModel?.buttonFirstShadow,
           let secondShadow = viewModel?.buttonSecondShadow,
           let thirdShadow = viewModel?.buttonThirdShadow {
            self.button.draw(shadow: firstShadow)
            self.button.draw(secondShadow: secondShadow)
            self.button.draw(thirdShadow: thirdShadow)
        }
        
        self.button.setEditTitle(
            viewModel?.buttonTitle,
            for: .normal
        )
        self.button.setImage(
            viewModel?.buttonIcon?.uiImage,
            for: .normal
        )
        self.button.setTitleColor(
            viewModel?.buttonTitleColor?.uiColor,
            for: .normal
        )
        self.button.customizeBaseAppearance(
            backgroundColor: viewModel?.buttonBackgroundColor
        )

        self.titleLabel.editText = viewModel?.title

        if let imageStyle = viewModel?.accountTypeImage, let accountName = viewModel?.accountName {
            self.accountTypeImageView.recustomizeAppearance(imageStyle)
            self.accountNameLabel.editText = accountName
            return
        }

        accountTypeImageView.removeFromSuperview()
        accountNameLabel.removeFromSuperview()

        if let topPadding = viewModel?.titleTopPadding {
            titleLabel.snp.updateConstraints {
                $0.top == topPadding
            }
        }
    }
}

extension AssetQuickActionView {
    private func addButton(_ theme: AssetQuickActionViewTheme) {
        button.contentEdgeInsets = UIEdgeInsets(theme.buttonContentInsets)
        button.draw(corner: theme.buttonCorner)

        addSubview(button)
        button.fitToHorizontalIntrinsicSize()
        button.snp.makeConstraints {
            let horizontalPaddings =
            theme.spacingBetweenTitleAndButton +
            2 * theme.horizontalPadding
            $0.width <= (self - horizontalPaddings) * theme.buttonMaxWidthRatio

            $0.top == theme.topPadding
            $0.trailing == theme.horizontalPadding
            $0.bottom == theme.bottomPadding + safeAreaBottom
        }

        startPublishing(
            event: .performAction,
            for: button
        )
    }

    private func addTitle(_ theme: AssetQuickActionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == theme.topPadding
            $0.leading == theme.horizontalPadding
            $0.trailing <= button.snp.leading - theme.spacingBetweenTitleAndButton
        }
    }

    private func addAccountTypeImage(_ theme: AssetQuickActionViewTheme) {
        addSubview(accountTypeImageView)
        accountTypeImageView.snp.makeConstraints {
            $0.fitToSize(theme.accountTypeImageSize)
            $0.leading == theme.horizontalPadding
            $0.top == titleLabel.snp.bottom + theme.accountTypeImageTopPadding
            $0.bottom == theme.bottomPadding + safeAreaBottom
        }
    }

    private func addAccountName(_ theme: AssetQuickActionViewTheme) {
        accountNameLabel.customizeAppearance(theme.accountName)

        addSubview(accountNameLabel)
        accountNameLabel.snp.makeConstraints {
            $0.centerY == accountTypeImageView
            $0.leading == accountTypeImageView.snp.trailing + theme.spacingBetweenAccountTypeAndName
            $0.trailing <= button.snp.leading - theme.spacingBetweenTitleAndButton
        }
    }
}

extension AssetQuickActionView {
    enum Event {
        case performAction
    }
}
