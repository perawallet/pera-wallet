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
//   ActionableWarningAlertViewController.swift

import UIKit

class ActionableWarningAlertViewController: BaseViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    weak var delegate: ActionableWarningAlertViewControllerDelegate?

    private lazy var actionableWarningAlertView = ActionableWarningAlertView()

    private let warningAlert: WarningAlert

    init(warningAlert: WarningAlert, configuration: ViewControllerConfiguration) {
        self.warningAlert = warningAlert
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        actionableWarningAlertView.bind(WarningAlertViewModel(warningAlert: warningAlert))
        view.backgroundColor = Colors.Background.secondary
    }

    override func linkInteractors() {
        super.linkInteractors()
        actionableWarningAlertView.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(actionableWarningAlertView)
    }
}

extension ActionableWarningAlertViewController: ActionableWarningAlertViewDelegate {
    func actionableWarningAlertViewDidTakeAction(_ actionableWarningAlertView: ActionableWarningAlertView) {
        delegate?.actionableWarningAlertViewControllerDidTakeAction(self)
    }

    func actionableWarningAlertViewDidCancel(_ actionableWarningAlertView: ActionableWarningAlertView) {
        dismissScreen()
    }
}

protocol ActionableWarningAlertViewControllerDelegate: AnyObject {
    func actionableWarningAlertViewControllerDidTakeAction(_ actionableWarningAlertViewController: ActionableWarningAlertViewController)
}
