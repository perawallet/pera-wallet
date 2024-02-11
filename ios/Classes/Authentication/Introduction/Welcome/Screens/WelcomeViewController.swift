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
        welcomeView.bindData(WelcomeViewModel(with : flow))
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
        case .initializeAccount:
            hidesCloseBarButtonItem = true

            addSkipBarButtonItem()
        case .addNewAccount,
             .backUpAccount,
             .none:
            break
        }
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
    func welcomeViewDidSelectCreate(_ welcomeView: WelcomeView) {
        analytics.track(.onboardWelcomeScreen(type: .create))
        open(.tutorial(flow: flow, tutorial: .backUp(flow: flow, address: "temp")), by: .push)
    }
    
    func welcomeViewDidSelectImport(_ welcomeView: WelcomeView) {
        analytics.track(.onboardWelcomeScreen(type: .recover))
        open(.recoverAccount(flow: flow), by: .push)
    }
    
    func welcomeViewDidSelectWatch(_ welcomeView: WelcomeView) {
        analytics.track(.onboardWelcomeScreen(type: .watch))

        let routingScreen: Screen
        let tutorial: Tutorial = .watchAccount

        switch flow {
        case .initializeAccount:
            routingScreen = .tutorial(flow: .initializeAccount(mode: .watch), tutorial: tutorial)
        default:
            routingScreen = .tutorial(flow: .addNewAccount(mode: .watch), tutorial: tutorial)
        }

        open(
            routingScreen,
            by: .push
        )
    }

    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL) {
        open(url)
    }
}
