// Copyright 2019 Algorand, Inc.

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

class WelcomeViewController: BaseViewController {

    private lazy var welcomeView = WelcomeView()

    private let flow: AccountSetupFlow

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        welcomeView.configureAddAccountView(with: AccountTypeViewModel(accountSetupMode: .add(type: .none)))
        welcomeView.configureRecoverAccountView(with: AccountTypeViewModel(accountSetupMode: .recover))
    }

    override func linkInteractors() {
        welcomeView.delegate = self
    }

    override func prepareLayout() {
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
            session?.createUser()

            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    UIApplication.shared.rootViewController()?.setupTabBarController()
                }
            }
        }

        rightBarButtonItems = [skipBarButtonItem]
    }
}

extension WelcomeViewController: WelcomeViewDelegate {
    func welcomeView(_ welcomeView: WelcomeView, didSelect mode: AccountSetupMode) {
        switch mode {
        case .add:
            open(.addAccount(flow: flow), by: .push)
        case .recover:
            open(.animatedTutorial(flow: flow, tutorial: .recover, isActionable: false), by: .push)
        default:
            break
        }
    }

    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL) {
        open(url)
    }
}
