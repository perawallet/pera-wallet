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

//   AlgorandSecureBackupErrorScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupErrorScreen: ScrollScreen {
    typealias EventHandler = (Event, AlgorandSecureBackupErrorScreen) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var resultView = ResultWithHyperlinkView()
    private lazy var tryAgainActionView = MacaroonUIKit.Button()

    private let theme: AlgorandSecureBackupErrorScreenTheme

    init(
        api: ALGAPI?,
        theme: AlgorandSecureBackupErrorScreenTheme = .init()
    ) {
        self.theme = theme
        super.init(api: api)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        disableInteractivePopGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        enableInteractivePopGesture()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        let closeButtonItem = ALGBarButtonItem(kind: .close(nil)) { [weak self] in
            guard let self else { return }
            self.dismissScreen()
        }
        
        hidesCloseBarButtonItem = true

        leftBarButtonItems = [closeButtonItem]
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
        addTryAgainAction()
    }
}

extension AlgorandSecureBackupErrorScreen {
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
        addTryAgainAction()
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

        resultView.startObserving(event: .performHyperlinkAction) {
            [unowned self] in
            self.open(AlgorandWeb.support.link)
        }
    }

    private func addTryAgainAction() {
        tryAgainActionView.customizeAppearance(theme.tryAgainAction)
        tryAgainActionView.contentEdgeInsets = UIEdgeInsets(theme.tryAgainActionContentEdgeInsets)

        footerView.addSubview(tryAgainActionView)
        tryAgainActionView.snp.makeConstraints {
            $0.top == theme.tryAgainActionEdgeInsets.top
            $0.leading == theme.tryAgainActionEdgeInsets.leading
            $0.trailing == theme.tryAgainActionEdgeInsets.trailing
            $0.bottom == theme.tryAgainActionEdgeInsets.bottom
        }

        tryAgainActionView.addTouch(
            target: self,
            action: #selector(performTryAgainAction)
        )
    }
}

extension AlgorandSecureBackupErrorScreen {
    private func bindResult() {
        let viewModel = AlgorandSecureBackupErrorResultViewModel()
        resultView.bindData(viewModel)
    }
}

extension AlgorandSecureBackupErrorScreen {
    @objc
    private func performTryAgainAction() {
        eventHandler?(.performTryAgain, self)
    }
}

extension AlgorandSecureBackupErrorScreen {
    enum Event {
        case performTryAgain
    }
}
