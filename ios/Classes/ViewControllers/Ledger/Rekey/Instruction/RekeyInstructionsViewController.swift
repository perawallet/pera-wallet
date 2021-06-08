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
//  RekeyInstructionsViewController.swift

import UIKit

class RekeyInstructionsViewController: BaseScrollViewController {
    
    private lazy var rekeyInstructionsView = RekeyInstructionsView()
    
    private let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if account.requiresLedgerConnection() {
            rekeyInstructionsView.setSubtitleText("rekey-instruction-subtitle-ledger".localized)
            rekeyInstructionsView.setSecondInstructionViewTitle("rekey-instruction-second-ledger".localized)
        } else {
            rekeyInstructionsView.setSubtitleText("rekey-instruction-subtitle-standard".localized)
            rekeyInstructionsView.setSecondInstructionViewTitle("rekey-instruction-second-standard".localized)
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        rekeyInstructionsView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRekeyInstructionsViewLayout()
    }
}

extension RekeyInstructionsViewController {
    private func setupRekeyInstructionsViewLayout() {
        contentView.addSubview(rekeyInstructionsView)
        
        rekeyInstructionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RekeyInstructionsViewController: RekeyInstructionsViewDelegate {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView) {
        open(.ledgerDeviceList(flow: .addNewAccount(mode: .rekey(account: account))), by: .push)
    }
}
