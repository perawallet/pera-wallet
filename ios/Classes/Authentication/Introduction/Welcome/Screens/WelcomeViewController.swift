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

//
//  WelcomeViewController.swift

import UIKit

final class WelcomeViewController: BaseViewController {
    private lazy var welcomeView = WelcomeView()
    private lazy var theme = Theme()

    private let flow: AccountSetupFlow

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func bindData() {
        welcomeView.bindAddAccountView(AccountTypeViewModel(.add(type: .none)))
        welcomeView.bindRecoverAccountView(AccountTypeViewModel(.recover))
    }

    override func linkInteractors() {
        welcomeView.delegate = self
        welcomeView.linkInteractors()
    }

    override func setListeners() {
        welcomeView.setListeners()
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        welcomeView.customize(theme.welcomeViewTheme)

        prepareWholeScreenLayoutFor(welcomeView)
    }
}

extension WelcomeViewController {
    private func addBarButtons() {
        switch flow {
        case .addNewAccount:
            addCloseBarButtonItem()
        case .initializeAccount:
            addSkipBarButtonItem()
        case .none:
            break
        }
    }

    private func addCloseBarButtonItem() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    private func addSkipBarButtonItem() {
        let skipBarButtonItem = ALGBarButtonItem(kind: .skip) { [unowned self] in
            self.session?.createUser()
            self.launchMain()
        }

        rightBarButtonItems = [skipBarButtonItem]
    }
}

extension WelcomeViewController: WelcomeViewDelegate {
    func welcomeViewDidSelectAdd(_ welcomeView: WelcomeView) {
        open(.addAccount(flow: flow), by: .push)
    }

    func welcomeViewDidSelectRecover(_ welcomeView: WelcomeView) {
        open(.tutorial(flow: flow, tutorial: .recover), by: .push)
    }

    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL) {
        open(url)
    }
}
