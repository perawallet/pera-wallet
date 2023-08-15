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

//   UndoRekeySuccessScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class UndoRekeySuccessScreen: ScrollScreen {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var resultView = ResultView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private let sourceAccount: Account
    private let theme: UndoRekeySuccessScreenTheme

    init(
        sourceAccount: Account,
        theme: UndoRekeySuccessScreenTheme = .init(),
        api: ALGAPI
    ) {
        self.sourceAccount = sourceAccount
        self.theme = theme
        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        hidesCloseBarButtonItem = true

        navigationItem.largeTitleDisplayMode = .never

        addNavigationBarButtonItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    private func addUI() {
        addBackground()
        addContext()
        addPrimaryAction()
    }
}

extension UndoRekeySuccessScreen {
    private func addNavigationBarButtonItems() {
        leftBarButtonItems = [ makeCloseBarButtonItem() ]
    }

    private func makeCloseBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .close(Colors.Text.main.uiColor)) {
            [unowned self] in
            self.eventHandler?(.performCloseAction)
        }
    }
}

extension UndoRekeySuccessScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addResult()
        addPrimaryAction()
    }

    private func addResult() {
        resultView.customize(theme.result)

        contextView.addSubview(resultView)
        resultView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        bindResult()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.primaryActionContentEdgeInsets)

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == theme.primaryActionContentEdgeInsets.top
            $0.leading == theme.primaryActionContentEdgeInsets.leading
            $0.trailing == theme.primaryActionContentEdgeInsets.trailing
            $0.bottom == theme.primaryActionContentEdgeInsets.bottom
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }
}

extension UndoRekeySuccessScreen {
    private func bindResult() {
        let viewModel = UndoRekeySuccessResultViewModel(sourceAccount: sourceAccount)
        resultView.bindData(viewModel)
    }
}

extension UndoRekeySuccessScreen {
    @objc
    private func performPrimaryAction() {
        eventHandler?(.performPrimaryAction)
    }
}

extension UndoRekeySuccessScreen {
    enum Event {
        case performPrimaryAction
        case performCloseAction
    }
}
