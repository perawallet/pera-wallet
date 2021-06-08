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
//  LedgerApprovalViewController.swift

import UIKit

class LedgerApprovalViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var ledgerApprovalView = LedgerApprovalView()
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        if mode == .connection {
            setConnectionModeTexts()
        } else {
            setApproveModeTexts()
        }
    }
    
    override func setListeners() {
        ledgerApprovalView.delegate = self
    }
    
    override func prepareLayout() {
        setupLedgerApprovalViewLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerApprovalView.startConnectionAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerApprovalView.stopConnectionAnimation()
    }
}

extension LedgerApprovalViewController {
    private func setupLedgerApprovalViewLayout() {
        view.addSubview(ledgerApprovalView)
        
        ledgerApprovalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerApprovalViewController: LedgerApprovalViewDelegate {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView) {
        dismissScreen()
    }
    
    func dismissIfNeeded() {
        if isModal {
            dismissScreen()
        }
    }
}

extension LedgerApprovalViewController {
    private func setConnectionModeTexts() {
        ledgerApprovalView.setTitle("ledger-approval-connection-title".localized)
        ledgerApprovalView.setDetail("ledger-approval-connection-message".localized)
    }
    
    private func setApproveModeTexts() {
        ledgerApprovalView.setTitle("ledger-approval-title".localized)
        ledgerApprovalView.setDetail("ledger-approval-message".localized)
    }
}

extension LedgerApprovalViewController {
    enum Mode {
        case connection
        case approve
    }
}
