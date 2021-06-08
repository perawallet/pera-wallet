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
//  LedgerTutorialInstructionListView.swift

import UIKit

class LedgerTutorialInstructionListView: BaseView {
    private let layout = Layout<LayoutConstants>()
    
    private lazy var openLedgerInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.bind(LedgerTutorialInstructionViewModel(number: 1, title: "ledger-tutorial-turned-on".localized))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var installAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.bind(LedgerTutorialInstructionViewModel(number: 2, title: "ledger-tutorial-install-app".localized))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var openAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.bind(LedgerTutorialInstructionViewModel(number: 3, title: "ledger-tutorial-open-app".localized))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var turnOnBluetoohInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.bind(LedgerTutorialInstructionViewModel(number: 4, title: "ledger-tutorial-bluetooth".localized))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    weak var delegate: LedgerTutorialInstructionListViewDelegate?
        
    override func prepareLayout() {
        setupOpenLedgerInstructionViewLayout()
        setupInstallAppInstructionViewLayout()
        setupOpenAppInstructionViewLayout()
        setupTurnOnBluetoohInstructionViewLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        let ledgerBluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLedgerBluetoothConnection))
        openLedgerInstructionView.addGestureRecognizer(ledgerBluetoothTapGestureRecognizer)
        
        let installAppTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInstallApp))
        installAppInstructionView.addGestureRecognizer(installAppTapGestureRecognizer)
        
        let openAppTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOpenApp))
        openAppInstructionView.addGestureRecognizer(openAppTapGestureRecognizer)
        
        let bluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBluetoothConnection))
        turnOnBluetoohInstructionView.addGestureRecognizer(bluetoothTapGestureRecognizer)
    }
}

extension LedgerTutorialInstructionListView {
    private func setupOpenLedgerInstructionViewLayout() {
        addSubview(openLedgerInstructionView)
        
        openLedgerInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(layout.current.instructionHeight)
        }
    }

    private func setupInstallAppInstructionViewLayout() {
        addSubview(installAppInstructionView)
        
        installAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openLedgerInstructionView.snp.bottom).offset(layout.current.instructionOffset)
            make.height.equalTo(openLedgerInstructionView)
        }
    }

    private func setupOpenAppInstructionViewLayout() {
        addSubview(openAppInstructionView)
        
        openAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(installAppInstructionView.snp.bottom).offset(layout.current.instructionOffset)
            make.height.equalTo(openLedgerInstructionView)
        }
    }

    private func setupTurnOnBluetoohInstructionViewLayout() {
        addSubview(turnOnBluetoohInstructionView)
        
        turnOnBluetoohInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openAppInstructionView.snp.bottom).offset(layout.current.instructionOffset)
            make.height.equalTo(openLedgerInstructionView)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerTutorialInstructionListView {
    @objc
    private func didTapLedgerBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(self)
    }
    
    @objc
    private func didTapInstallApp() {
        delegate?.ledgerTutorialInstructionListViewDidTapInstallApp(self)
    }
    
    @objc
    private func didTapOpenApp() {
        delegate?.ledgerTutorialInstructionListViewDidTapOpenApp(self)
    }
    
    @objc
    private func didTapBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListViewDidTapBluetoothConnection(self)
    }
}

extension LedgerTutorialInstructionListView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let instructionHeight: CGFloat = 64.0
        let instructionOffset: CGFloat = 12.0
    }
}

protocol LedgerTutorialInstructionListViewDelegate: class {
    func ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapInstallApp(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapOpenApp(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapBluetoothConnection(_ view: LedgerTutorialInstructionListView)
}
