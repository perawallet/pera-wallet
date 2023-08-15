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

//   AccountInformationOptionsView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountInformationOptionsView: View {
    private var uiInteractions: [MacaroonUIKit.UIInteraction] = []

    private lazy var contentView = MacaroonUIKit.VStackView()

    private var theme: AccountInformationOptionsViewTheme?

    func customize(_ theme: AccountInformationOptionsViewTheme) {
        self.theme = theme

        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AccountInformationOptionsView {
    private func addContent(_ theme: AccountInformationOptionsViewTheme) {
        addSubview(contentView)
        contentView.spacing = theme.spacingBetweenOptions
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension AccountInformationOptionsView {
    func addOption(_ option: AccountInformationOptionItem) {
        guard let view = makeOptionView(option) else {
            return
        }

        let interaction = TargetActionInteraction()
        interaction.setSelector(option.handler)
        interaction.attach(to: view)
        uiInteractions.append(interaction)

        contentView.addArrangedSubview(view)
    }

    private func makeOptionView(_ option: AccountInformationOptionItem) -> ListItemButton? {
        guard let theme else {
            return nil
        }

        let view = ListItemButton()
        view.customize(theme.option)
        view.bindData(option.viewModel)
        return view
    }
}
