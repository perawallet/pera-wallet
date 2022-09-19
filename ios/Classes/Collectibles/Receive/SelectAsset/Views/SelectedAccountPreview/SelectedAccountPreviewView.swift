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

//   SelectedAccountPreviewView.swift

import UIKit
import MacaroonUIKit

final class SelectedAccountPreviewView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performCopyAction: TargetActionInteraction(),
        .performQRAction: TargetActionInteraction()
    ]

    private lazy var iconView = ImageView()
    private lazy var contentView = UIView()
    private lazy var titleView = Label()
    private lazy var valueView = Label()
    private lazy var copyActionView = MacaroonUIKit.Button()
    private lazy var scanQRActionView = MacaroonUIKit.Button()

    func customize(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        addBackground(theme)
        addSeparator(theme.separator)
        addIcon(theme)
        addContent(theme)
        addCopyAction(theme)
        addScanQRAction(theme)
    }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func bindData(
        _ viewModel: SelectedAccountPreviewViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage
        titleView.editText = viewModel?.title
        valueView.editText = viewModel?.value
    }
}

extension SelectedAccountPreviewView {
    private func addBackground(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addIcon(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == theme.horizontalPadding
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addContent(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        addSeparator(theme.separator)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.centerY == 0
            $0.width >= self * theme.contentMinWidthRatio
            $0.top == theme.verticalPadding
            $0.leading == iconView.snp.trailing + theme.iconHorizontalPaddings.trailing
            $0.bottom == theme.verticalPadding
        }

        addTitle(theme)
        addValue(theme)
    }

    private func addTitle(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }
    }

    private func addValue(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        valueView.customizeAppearance(theme.value)

        contentView.addSubview(valueView)
        valueView.fitToVerticalIntrinsicSize()
        valueView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == titleView.snp.leading
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addCopyAction(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        copyActionView.customizeAppearance(theme.copyAction)

        addSubview(copyActionView)
        copyActionView.fitToIntrinsicSize()
        copyActionView.snp.makeConstraints {
            $0.leading == contentView.snp.trailing + theme.actionHorizontalPaddings.leading
            $0.centerY == 0
        }

        startPublishing(
            event: .performCopyAction,
            for: copyActionView
        )
    }

    private func addScanQRAction(
        _ theme: SelectedAccountPreviewViewTheme
    ) {
        scanQRActionView.customizeAppearance(theme.scanQRAction)

        addSubview(scanQRActionView)
        scanQRActionView.fitToIntrinsicSize()
        scanQRActionView.snp.makeConstraints {
            $0.leading == copyActionView.snp.trailing + theme.spacingBetweenActions
            $0.trailing == theme.actionHorizontalPaddings.trailing
            $0.centerY == copyActionView
        }

        startPublishing(
            event: .performQRAction,
            for: scanQRActionView
        )
    }
}

extension SelectedAccountPreviewView {
    enum Event {
        case performCopyAction
        case performQRAction
    }
}
