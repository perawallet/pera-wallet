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

//   FileInfoView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class FileInfoView:
    TripleShadowView,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performCopyAction: GestureInteraction()
    ]

    private lazy var iconView = UIImageView()
    private lazy var infoContentView = UIView()
    private lazy var infoNameView = UILabel()
    private lazy var infoSizeView = UILabel()
    private lazy var copyAccessory = UIButton()

    func customize(_ theme: FileInfoViewTheme) {
        addContent(theme)
    }

    func bindData(_ viewModel: FileInfoViewModel?) {
        if let icon = viewModel?.icon {
            iconView.image = icon.uiImage
        } else {
            iconView.image = nil
        }

        if let name = viewModel?.name {
            name.load(in: infoNameView)
        } else {
            infoNameView.text = nil
            infoNameView.attributedText = nil
        }

        if let size = viewModel?.size {
            size.load(in: infoSizeView)
        } else {
            infoSizeView.text = nil
            infoSizeView.attributedText = nil
        }
    }
}

extension FileInfoView {
    private func addContent(_ theme: FileInfoViewTheme) {
        drawAppearance(shadow: theme.contentFirstShadow)
        drawAppearance(secondShadow: theme.contentSecondShadow)
        drawAppearance(thirdShadow: theme.contentThirdShadow)

        addIcon(theme)
        addInfoContent(theme)
        addCopyAccessory(theme)
        
        startPublishing(
            event: .performCopyAction,
            for: self
        )
    }

    private func addIcon(_ theme: FileInfoViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
            $0.bottom == theme.contentPaddings.bottom
        }
    }

    private func addInfoContent(_ theme: FileInfoViewTheme) {
        addSubview(infoContentView)
        infoContentView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndInfoContent
            $0.bottom <= 0
            $0.centerY == 0
        }

        addInfoName(theme)
        addInfoSize(theme)
    }

    private func addInfoName(_ theme: FileInfoViewTheme) {
        infoNameView.customizeAppearance(theme.infoName)

        infoContentView.addSubview(infoNameView)
        infoNameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addInfoSize(_ theme: FileInfoViewTheme) {
        infoSizeView.customizeAppearance(theme.infoSize)

        infoContentView.addSubview(infoSizeView)
        infoSizeView.snp.makeConstraints {
            $0.top == infoNameView.snp.bottom + theme.spacingBetweenInfoNameAndInfoSize
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addCopyAccessory(_ theme: FileInfoViewTheme) {
        copyAccessory.customizeAppearance(theme.copyAccessory)

        addSubview(copyAccessory)
        copyAccessory.fitToIntrinsicSize()
        copyAccessory.snp.makeConstraints {
            $0.leading == infoContentView.snp.trailing + theme.spacingBetweenInfoContentAndCopyAccessory
            $0.trailing == theme.contentPaddings.trailing
            $0.centerY == 0
        }

        startPublishing(
            event: .performCopyAction,
            for: copyAccessory
        )
    }
}

extension FileInfoView {
    enum Event {
        case performCopyAction
    }
}
