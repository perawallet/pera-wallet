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
//  LedgerTroubleshootingViewController.swift

import UIKit

class LedgerTroubleshootingViewController: BaseScrollViewController {
    
    private lazy var ledgerTutorialInstructionListView: LedgerTutorialInstructionListView = {
        let ledgerTutorialInstructionListView = LedgerTutorialInstructionListView()
        ledgerTutorialInstructionListView.backgroundColor = Colors.Background.tertiary
        return ledgerTutorialInstructionListView
    }()
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setNavigationBarTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        title = "ledger-troubleshooting-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialInstructionListView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTroubleshootingViewLayout()
    }
}

extension LedgerTroubleshootingViewController {
    private func setupLedgerTroubleshootingViewLayout() {
        contentView.addSubview(ledgerTutorialInstructionListView)
        
        ledgerTutorialInstructionListView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

extension LedgerTroubleshootingViewController: LedgerTutorialInstructionListViewDelegate {
    func ledgerTutorialInstructionListViewDidTapOpenApp(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootOpenApp, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapInstallApp(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootInstallApp, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootBluetooth, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootLedgerConnection, by: .present)
    }
}
