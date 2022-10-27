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

//   ExportsAccountsResultScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class ExportsAccountsResultScreen: BaseScrollViewController  {
    typealias EventHandler = (Event, ExportsAccountsResultScreen) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = ResultView()
    private lazy var closeActionView = MacaroonUIKit.Button()
    
    private let theme: ExportAccountsResultScreenTheme
    private let accounts: [Account]

    init(
        configuration: ViewControllerConfiguration,
        theme: ExportAccountsResultScreenTheme = .init(),
        accounts: [Account]
    ) {
        self.theme = theme
        self.accounts = accounts
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    private func addUI() {
        addBackground()
        addContext()
        addCloseAction()
    }
}

extension ExportsAccountsResultScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }

        contextView.bindData(ExportAccountsResultViewModel(accounts: accounts))
    }

    private func addCloseAction() {
        closeActionView.customizeAppearance(theme.closeAction)
        closeActionView.contentEdgeInsets = UIEdgeInsets(theme.closeActionEdgeInsets)

        footerView.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.top == theme.closeActionContentEdgeInsets.top
            $0.leading == theme.closeActionContentEdgeInsets.leading
            $0.trailing == theme.closeActionContentEdgeInsets.trailing
            $0.bottom == theme.closeActionContentEdgeInsets.bottom
        }

        closeActionView.addTouch(
            target: self,
            action: #selector(performClose)
        )
    }
}


extension ExportsAccountsResultScreen {
    @objc
    private func performClose() {
        eventHandler?(.performClose, self)
    }
}

extension ExportsAccountsResultScreen {
    enum Event {
        case performClose
    }
}
