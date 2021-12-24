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
//  LedgerDeviceListViewController.swift

import UIKit
import CoreBluetooth

class LedgerDeviceListViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()

    private lazy var ledgerDeviceListView = LedgerDeviceListView()
    
    private lazy var ledgerAccountFetchOperation: LedgerAccountFetchOperation = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return LedgerAccountFetchOperation(api: api, ledgerApprovalMode: .connection)
    }()

    private lazy var initialPairingWarningModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 496.0))
    )

    private let accountSetupFlow: AccountSetupFlow
    private var ledgerDevices = [CBPeripheral]()
    private var selectedDevice: CBPeripheral?
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerDeviceListView.startSearchSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerAccountFetchOperation.reset()
        ledgerDeviceListView.stopSearchSpinner()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-device-list-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerDeviceListView.delegate = self
        ledgerAccountFetchOperation.delegate = self
        ledgerDeviceListView.devicesCollectionView.delegate = self
        ledgerDeviceListView.devicesCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerDeviceListViewLayout()
    }
}

extension LedgerDeviceListViewController {
    private func setupLedgerDeviceListViewLayout() {
        view.addSubview(ledgerDeviceListView)
        
        ledgerDeviceListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerDeviceListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ledgerDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LedgerDeviceCell.reusableIdentifier,
            for: indexPath) as? LedgerDeviceCell else {
                fatalError("Index path is out of bounds")
        }
        
        let device = ledgerDevices[indexPath.item]
        cell.bind(LedgerDeviceListViewModel(peripheral: device))
        cell.delegate = self
        return cell
    }
}

extension LedgerDeviceListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }
}

extension LedgerDeviceListViewController: LedgerDeviceCellDelegate {
    func ledgerDeviceCellDidTapConnectButton(_ ledgerDeviceCell: LedgerDeviceCell) {
        guard let indexPath = ledgerDeviceListView.devicesCollectionView.indexPath(for: ledgerDeviceCell) else {
            return
        }
        
        selectedDevice = ledgerDevices[indexPath.item]

        let oneTimeDisplayStorage = OneTimeDisplayStorage()
        if oneTimeDisplayStorage.isDisplayedOnce(for: .ledgerPairingWarning) {
            ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
            selectedDevice = nil
            return
        }

        oneTimeDisplayStorage.setDisplayedOnce(for: .ledgerPairingWarning)

        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: initialPairingWarningModalPresenter
        )

        let controller = open(.ledgerPairWarning, by: transitionStyle) as? LedgerPairWarningViewController
        controller?.delegate = self
    }
}

extension LedgerDeviceListViewController: LedgerPairWarningViewControllerDelegate {
    func ledgerPairWarningViewControllerDidTakeAction(_ ledgerPairWarningViewController: LedgerPairWarningViewController) {
        if let ledgerDevice = selectedDevice {
            ledgerAccountFetchOperation.connectToDevice(ledgerDevice)
            selectedDevice = nil
        }
    }
}

extension LedgerDeviceListViewController: LedgerDeviceListViewDelegate {
    func ledgerDeviceListViewDidTapTroubleshootButton(_ ledgerDeviceListView: LedgerDeviceListView) {
        open(.ledgerTroubleshoot, by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }
}

extension LedgerDeviceListViewController: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account],
        in ledgerApprovalViewController: LedgerApprovalViewController?
    ) {
        if isViewDisappearing {
            return
        }
        
        ledgerApprovalViewController?.closeScreen(by: .dismiss, animated: true) {
            self.open(.ledgerAccountSelection(flow: self.accountSetupFlow, accounts: accounts), by: .push)
        }
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral]) {
        ledgerDevices = peripherals
        ledgerDeviceListView.invalidateContentSize(by: ledgerDevices.count)
        ledgerDeviceListView.devicesCollectionView.reloadData()
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError) {
        switch error {
        case .cancelled:
            NotificationBanner.showError(
                "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}

extension LedgerDeviceListViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 28.0, height: 60.0)
    }
}
