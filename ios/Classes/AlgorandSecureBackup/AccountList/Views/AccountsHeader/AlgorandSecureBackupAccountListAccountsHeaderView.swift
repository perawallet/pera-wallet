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

//   AlgorandSecureBackupAccountListAccountsHeaderView.swift

import UIKit
import MacaroonUIKit

final class AlgorandSecureBackupAccountListAccountsHeaderView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: TargetActionInteraction()
    ]

    private lazy var infoView = Label()
    private lazy var actionView = MacaroonUIKit.Button(theme.actionLayout)

    private var theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme!

    func customize(
        _ theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme
    ) {
        self.theme = theme

        addBackground(theme)
        addInfo(theme)
        addAction(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AlgorandSecureBackupAccountListAccountsHeaderViewModel?
    ) {
        guard let viewModel = viewModel else {
            infoView.clearText()
            return
        }

        viewModel.info?.load(in: infoView)

        actionView.isHidden = viewModel.hasSingularAccount
    }

    class func calculatePreferredSize(
        _ viewModel: AlgorandSecureBackupAccountListAccountsHeaderViewModel?,
        for theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width - theme.minimumHorizontalSpacing
        let infoSize = viewModel.info?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let buttonHeight: LayoutMetric = 24
        let preferredHeight = max(infoSize.height, buttonHeight)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AlgorandSecureBackupAccountListAccountsHeaderView {
    private func addBackground(
        _ theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addInfo(
        _ theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme
    ) {
        infoView.customizeAppearance(theme.info)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.width >= (self - theme.minimumHorizontalSpacing) * theme.infoMinWidthRatio
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAction(
        _ theme: AlgorandSecureBackupAccountListAccountsHeaderViewTheme
    ) {
        addSubview(actionView)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= infoView.snp.trailing + theme.minimumHorizontalSpacing
            $0.trailing == 0
            $0.bottom == 0
        }

        startPublishing(
            event: .performAction,
            for: actionView
        )

        updateAction(.selectAll)
    }
}

extension AlgorandSecureBackupAccountListAccountsHeaderView {
    func updateState(_ state: AlgorandSecureBackupAccountListAccountHeaderItemState) {
        updateAction(state)
    }

    func updateAction(_ state: AlgorandSecureBackupAccountListAccountHeaderItemState) {
        let actionStyle = theme[state]

        actionView.customizeAppearance(actionStyle)
    }
}

extension AlgorandSecureBackupAccountListAccountsHeaderView {
    enum Event {
        case performAction
    }
}
