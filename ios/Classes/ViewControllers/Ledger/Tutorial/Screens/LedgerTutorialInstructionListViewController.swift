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
//  LedgerTutorialInstructionListViewController.swift

import UIKit

final class LedgerTutorialInstructionListViewController: BaseScrollViewController {
    private lazy var ledgerTutorialInstructionListView = LedgerTutorialInstructionListView()
    private lazy var theme = Theme()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "tutorial-action-title-ledger".localized
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialInstructionListView.linkInteractors()
        ledgerTutorialInstructionListView.delegate = self
    }

    override func bindData() {
        super.bindData()
        ledgerTutorialInstructionListView.bindData()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        ledgerTutorialInstructionListView.customize(theme.ledgerTutorialInstructionViewTheme)

        contentView.addSubview(ledgerTutorialInstructionListView)
        ledgerTutorialInstructionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension LedgerTutorialInstructionListViewController: LedgerTutorialViewDelegate {
    func ledgerTutorialInstructionListView(_ ledgerTutorialView: LedgerTutorialInstructionListView, didTap section: LedgerTutorialSection) {
        switch section {
        case .ledgerBluetoothConnection:
            open(.tutorialSteps(step: .bluetooth), by: .push)
        case .installApp:
            open(.tutorialSteps(step: .installApp), by: .push)
        case .openApp:
            open(.tutorialSteps(step: .openApp), by: .push)
        case .bluetoothConnection:
            open(.tutorialSteps(step: .bluetoothConnection), by: .push)
        }
    }
}
