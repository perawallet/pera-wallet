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

//   RecoverAccountViewController.swift

import UIKit

final class RecoverAccountViewController: BaseViewController {
    private lazy var addAccountView = RecoverAccountView()
    private lazy var theme = Theme()

    private let flow: AccountSetupFlow

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        addAccountView.bindData(RecoverAccountViewModel())
    }

    override func linkInteractors() {
        addAccountView.delegate = self
    }

    override func setListeners() {
        addAccountView.setListeners()
    }

    override func prepareLayout() {
        addAccountView.customize(theme.recoverAccountViewTheme)

        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension RecoverAccountViewController {
    private func addBarButtons() {
        switch flow {
        case .initializeAccount:
            addSkipBarButtonItem()
        default:
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

extension RecoverAccountViewController: RecoverAccountViewDelegate {
    func recoverAccountView(_ recoverAccountView: RecoverAccountView, didSelect type: RecoverType) {
        switch type {
        case .passphrase:
            open(.tutorial(flow: flow, tutorial: .recoverWithPassphrase), by: .push)
        case .ledger:
            open(.tutorial(flow: flow, tutorial: .recoverWithLedger), by: .push)
        default:
            break
        }
    }
}

