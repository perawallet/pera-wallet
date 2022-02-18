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
//  LedgerTutorialInstructionListView.swift

import UIKit
import MacaroonUIKit

final class LedgerTutorialInstructionListView: View {
    weak var delegate: LedgerTutorialViewDelegate?

    private lazy var openLedgerInstructionView = LedgerTutorialInstructionView()
    private lazy var installAppInstructionView = LedgerTutorialInstructionView()
    private lazy var openAppInstructionView = LedgerTutorialInstructionView()
    private lazy var turnOnBluetoothInstructionView = LedgerTutorialInstructionView()

    func customize(_ theme: LedgerTutorialInstructionListViewTheme) {
        addOpenLedgerInstructionView(theme)
        addInstallAppInstructionView(theme)
        addOpenAppInstructionView(theme)
        addTurnOnBluetoothInstructionView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func linkInteractors() {
        let ledgerBluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLedgerBluetoothConnection))
        openLedgerInstructionView.addGestureRecognizer(ledgerBluetoothTapGestureRecognizer)
        
        let installAppTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInstallApp))
        installAppInstructionView.addGestureRecognizer(installAppTapGestureRecognizer)
        
        let openAppTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOpenApp))
        openAppInstructionView.addGestureRecognizer(openAppTapGestureRecognizer)
        
        let bluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBluetoothConnection))
        turnOnBluetoothInstructionView.addGestureRecognizer(bluetoothTapGestureRecognizer)
    }

    func bindData() {
        openLedgerInstructionView.bindData(LedgerTutorialInstructionViewModel("ledger-tutorial-turned-on".localized))
        installAppInstructionView.bindData(LedgerTutorialInstructionViewModel("ledger-tutorial-install-app".localized))
        openAppInstructionView.bindData(LedgerTutorialInstructionViewModel("ledger-tutorial-open-app".localized))
        turnOnBluetoothInstructionView.bindData(LedgerTutorialInstructionViewModel("ledger-tutorial-bluetooth".localized))
    }
}

extension LedgerTutorialInstructionListView {
    private func addOpenLedgerInstructionView(_ theme: LedgerTutorialInstructionListViewTheme) {
        openLedgerInstructionView.customize(LedgerTutorialInstructionViewTheme())

        addSubview(openLedgerInstructionView)
        openLedgerInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(theme.listTopInset)
            $0.height.equalTo(theme.instructionHeight)
        }
    }

    private func addInstallAppInstructionView(_ theme: LedgerTutorialInstructionListViewTheme) {
        installAppInstructionView.customize(LedgerTutorialInstructionViewTheme())

        addSubview(installAppInstructionView)
        installAppInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(openLedgerInstructionView.snp.bottom).offset(theme.instructionOffset)
            $0.height.equalTo(openLedgerInstructionView)
        }
    }

    private func addOpenAppInstructionView(_ theme: LedgerTutorialInstructionListViewTheme) {
        openAppInstructionView.customize(LedgerTutorialInstructionViewTheme())

        addSubview(openAppInstructionView)
        openAppInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(installAppInstructionView.snp.bottom).offset(theme.instructionOffset)
            $0.height.equalTo(openLedgerInstructionView)
        }
    }

    private func addTurnOnBluetoothInstructionView(_ theme: LedgerTutorialInstructionListViewTheme) {
        turnOnBluetoothInstructionView.customize(LedgerTutorialInstructionViewTheme())

        addSubview(turnOnBluetoothInstructionView)
        turnOnBluetoothInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(openAppInstructionView.snp.bottom).offset(theme.instructionOffset)
            $0.height.equalTo(openLedgerInstructionView)
            $0.bottom.equalToSuperview()
        }
    }
}

extension LedgerTutorialInstructionListView {
    @objc
    private func didTapLedgerBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListView(self, didTap: .ledgerBluetoothConnection)
    }
    
    @objc
    private func didTapInstallApp() {
        delegate?.ledgerTutorialInstructionListView(self, didTap: .installApp)
    }
    
    @objc
    private func didTapOpenApp() {
        delegate?.ledgerTutorialInstructionListView(self, didTap: .openApp)
    }
    
    @objc
    private func didTapBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListView(self, didTap: .bluetoothConnection)
    }
}

protocol LedgerTutorialViewDelegate: AnyObject {
    func ledgerTutorialInstructionListView(
        _ ledgerTutorialInstructionListView: LedgerTutorialInstructionListView,
        didTap section: LedgerTutorialSection
    )
}

enum LedgerTutorialSection {
    case ledgerBluetoothConnection
    case openApp
    case installApp
    case bluetoothConnection
}
