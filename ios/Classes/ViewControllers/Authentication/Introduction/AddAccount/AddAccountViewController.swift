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
//  AddAccountViewController.swift

import UIKit

class AddAccountViewController: BaseViewController {
    
    private lazy var addAccountView = AddAccountView()
    
    private let flow: AccountSetupFlow
    
    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        addAccountView.configureCreateNewAccountView(with: AccountTypeViewModel(accountSetupMode: .add(type: .create)))
        addAccountView.configureWatchAccountView(with: AccountTypeViewModel(accountSetupMode: .add(type: .watch)))
        addAccountView.configurePairAccountView(with: AccountTypeViewModel(accountSetupMode: .add(type: .pair)))
    }
    
    override func linkInteractors() {
        addAccountView.delegate = self
    }
    
    override func prepareLayout() {
        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType) {
        switch type {
        case .create:
            open(.animatedTutorial(flow: flow, tutorial: .backUp, isActionable: false), by: .push)
        case .watch:
            open(.animatedTutorial(flow: flow, tutorial: .watchAccount, isActionable: false), by: .push)
        case .pair:
            open(.ledgerTutorial(flow: .addNewAccount(mode: .add(type: .pair))), by: .push)
        default:
            break
        }
    }
}
