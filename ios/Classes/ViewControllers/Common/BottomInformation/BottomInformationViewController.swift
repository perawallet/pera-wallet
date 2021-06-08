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
//  BottomInformationViewController.swift

import UIKit

class BottomInformationViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private(set) var bottomInformationView: BottomInformationView
    private let mode: Mode
    private let bottomInformationBundle: BottomInformationBundle
    
    init(mode: Mode, bottomInformationBundle: BottomInformationBundle, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.bottomInformationBundle = bottomInformationBundle
        
        switch mode {
        case .confirmation:
            bottomInformationView = ConfirmationBottomInformationView()
        case .action:
            bottomInformationView = ActionBottomInformationView()
        case .qr:
            bottomInformationView = QRBottomInformationView()
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary

        if let confirmationBottomInformationView = bottomInformationView as? ConfirmationBottomInformationView {
            confirmationBottomInformationView.bind(BottomInformationViewModel(configurator: bottomInformationBundle))
        }

        if let actionBottomInformationView = bottomInformationView as? ActionBottomInformationView {
            actionBottomInformationView.bind(BottomInformationViewModel(configurator: bottomInformationBundle))
        }

        if let qrBottomInformationView = bottomInformationView as? QRBottomInformationView {
            qrBottomInformationView.bind(BottomInformationViewModel(configurator: bottomInformationBundle))
        }
    }
    
    override func setListeners() {
        switch mode {
        case .confirmation:
            setConfirmationBottomInformationViewAction()
        case .action:
            setActionBottomInformationViewAction()
        case .qr:
            setQRBottomInformationViewAction()
        }
    }
    
    override func prepareLayout() {
        setupBottomInformationViewLayout()
    }
}

extension BottomInformationViewController {
    private func setupBottomInformationViewLayout() {
        view.addSubview(bottomInformationView)
        
        bottomInformationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BottomInformationViewController {
    private func setConfirmationBottomInformationViewAction() {
        guard let confirmationBottomInformationView = bottomInformationView as? ConfirmationBottomInformationView else {
            return
        }
        
        confirmationBottomInformationView.delegate = self
    }
    
    private func setActionBottomInformationViewAction() {
        guard let actionBottomInformationView = bottomInformationView as? ActionBottomInformationView else {
            return
        }
        
        actionBottomInformationView.delegate = self
    }
    
    private func setQRBottomInformationViewAction() {
        guard let qrBottomInformationView = bottomInformationView as? QRBottomInformationView else {
            return
        }
        
        qrBottomInformationView.delegate = self
    }
}

extension BottomInformationViewController {
    private func executeHandler() {
        if let handler = bottomInformationBundle.actionHandler {
            dismiss(animated: true) {
                handler()
            }
            return
        }
        
        dismissScreen()
    }
}

extension BottomInformationViewController: ConfirmationBottomInformationViewDelegate {
    func confirmationBottomInformationViewDidTapActionButton(_ confirmationBottomInformationView: ConfirmationBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController: ActionBottomInformationViewDelegate {
    func actionBottomInformationViewDidTapCancelButton(_ actionBottomInformationView: ActionBottomInformationView) {
        dismissScreen()
    }
    
    func actionBottomInformationViewDidTapActionButton(_ actionBottomInformationView: ActionBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController: QRBottomInformationViewDelegate {
    func qrBottomInformationViewDidTapCancelButton(_ qrBottomInformationView: QRBottomInformationView) {
        dismissScreen()
    }
    
    func qrBottomInformationViewDidTapActionButton(_ qrBottomInformationView: QRBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController {
    enum Mode {
        case confirmation
        case action
        case qr
    }
}
