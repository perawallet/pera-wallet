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

//   AlgorandSecureBackupAccountListAccountCell.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AlgorandSecureBackupAccountListAccountCell:
    CollectionCell<AccountListItemView>,
    ViewModelBindable  {
    var accessory: AlgorandSecureBackupAccountListItemAccessory = .unselected {
        didSet { updateAccessoryIfNeeded(old: oldValue) }
    }

    override class var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = AlgorandSecureBackupAccountListItemCellTheme()

    private lazy var accessoryView = UIImageView()

    override func prepareLayout() {
        addContext()
        addAccessory()
        addSeparator()
    }

    override func addContext() {
        let theme = Self.theme

        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.bottom == theme.contextEdgeInsets.bottom
        }
    }

    static func calculatePreferredSize(
        _ viewModel: AccountListItemViewModel?,
        for theme: AlgorandSecureBackupAccountListItemCellTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let contextWidth =
            width -
            theme.contextEdgeInsets.leading -
            theme.spacingBetweenContextAndAccessory -
            theme.accessorySize.w -
            theme.contextEdgeInsets.trailing
        let maxContextSize = CGSize(width: contextWidth, height: .greatestFiniteMagnitude)
        let contextSize = ContextView.calculatePreferredSize(
            viewModel,
            for: theme.context,
            fittingIn: maxContextSize
        )
        let preferredHeight =
            theme.contextEdgeInsets.top +
            contextSize.height +
            theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AlgorandSecureBackupAccountListAccountCell {
    private func addAccessory() {
        let theme = Self.theme

        contentView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.fitToSize(theme.accessorySize)
            $0.leading == contextView.snp.trailing + theme.spacingBetweenContextAndAccessory
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.centerY == 0
        }

        updateAccessory()
    }

    private func updateAccessoryIfNeeded(old: AlgorandSecureBackupAccountListItemAccessory) {
        if accessory != old {
            updateAccessory()
            hideSeparatorIfNeeded()
        }
    }

    private func updateAccessory() {
        let style = Self.theme[accessory]
        accessoryView.customizeAppearance(style)
    }

    private func hideSeparatorIfNeeded() {
        if accessory == .none {
            separatorStyle = .none
        }
    }

    private func addSeparator() {
        separatorStyle = .single(Self.theme.separator)
    }
}
