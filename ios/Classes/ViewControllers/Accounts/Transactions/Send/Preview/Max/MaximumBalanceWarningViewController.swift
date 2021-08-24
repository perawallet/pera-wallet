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
//  MaximumBalanceWarningViewController.swift

import UIKit

class MaximumBalanceWarningViewController: BaseScrollViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    weak var delegate: MaximumBalanceWarningViewControllerDelegate?

    private lazy var maximumBalanceWarningView = MaximumBalanceWarningView()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.secondary
        maximumBalanceWarningView.bind(MaximumBalanceWarningViewModel(account: account))
    }

    override func linkInteractors() {
        super.linkInteractors()
        maximumBalanceWarningView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupMaximumBalanceWarningViewLayout()
    }
}

extension MaximumBalanceWarningViewController {
    private func setupMaximumBalanceWarningViewLayout() {
        contentView.addSubview(maximumBalanceWarningView)

        maximumBalanceWarningView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MaximumBalanceWarningViewController: MaximumBalanceWarningViewDelegate {
    func maximumBalanceWarningViewDidConfirmWarning(_ maximumBalanceWarningView: MaximumBalanceWarningView) {
        delegate?.maximumBalanceWarningViewControllerDidConfirmWarning(self)
    }

    func maximumBalanceWarningViewDidCancel(_ maximumBalanceWarningView: MaximumBalanceWarningView) {
        dismissScreen()
    }
}

protocol MaximumBalanceWarningViewControllerDelegate: AnyObject {
    func maximumBalanceWarningViewControllerDidConfirmWarning(_ maximumBalanceWarningViewController: MaximumBalanceWarningViewController)
}
