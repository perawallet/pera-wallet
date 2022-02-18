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
//  LedgerTutorialViewController.swift

import UIKit

class LedgerTutorialViewController: BaseScrollViewController {
    
    private lazy var ledgerTutorialView = LedgerTutorialView()
    
    private let accountSetupFlow: AccountSetupFlow

    private lazy var pairingWarningModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 496.0))
    )
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.openWalletSupport()
        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerTutorialView.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerTutorialView.stopAnimating()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setNavigationBarTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTutorialViewLayout()
    }
}

extension LedgerTutorialViewController {
    private func setupLedgerTutorialViewLayout() {
        contentView.addSubview(ledgerTutorialView)
        
        ledgerTutorialView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTutorialViewController: LedgerTutorialViewDelegate {
    func ledgerTutorialViewDidTapSearchButton(_ ledgerTutorialView: LedgerTutorialView) {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: pairingWarningModalPresenter
        )

        let controller = open(.ledgerPairWarning, by: transitionStyle) as? LedgerPairWarningViewController
        controller?.delegate = self
    }
    
    func ledgerTutorialView(_ ledgerTutorialView: LedgerTutorialView, didTap section: LedgerTutorialSection) {
        switch section {
        case .ledgerBluetoothConnection:
            open(.ledgerTroubleshootLedgerConnection, by: .present)
        case .installApp:
            open(.ledgerTroubleshootInstallApp, by: .present)
        case .openApp:
            open(.ledgerTroubleshootOpenApp, by: .present)
        case .bluetoothConnection:
            open(.ledgerTroubleshootBluetooth, by: .present)
        }
    }
}

extension LedgerTutorialViewController: LedgerPairWarningViewControllerDelegate {
    func ledgerPairWarningViewControllerDidTakeAction(_ ledgerPairWarningViewController: LedgerPairWarningViewController) {
        open(.ledgerDeviceList(flow: accountSetupFlow), by: .push)
    }
}

extension LedgerTutorialViewController {
    private func openWalletSupport() {
        if let url = AlgorandWeb.ledgerSupport.link {
            open(url)
        }
    }
}
