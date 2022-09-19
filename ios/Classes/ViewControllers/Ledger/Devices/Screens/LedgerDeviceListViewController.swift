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
//  LedgerDeviceListViewController.swift

import UIKit
import CoreBluetooth

final class LedgerDeviceListViewController: BaseViewController {
    private lazy var ledgerDeviceListView = LedgerDeviceListView()
    private lazy var theme = Theme()
    
    private lazy var ledgerAccountFetchOperation: LedgerAccountFetchOperation = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return LedgerAccountFetchOperation(api: api, analytics: analytics)
    }()

    private lazy var initialPairingWarningTransition = BottomSheetTransition(presentingViewController: self)

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    private var timer: Timer?

    private let accountSetupFlow: AccountSetupFlow
    private var ledgerDevices = [CBPeripheral]()

    private var selectedDevice: CBPeripheral?

    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ledgerDeviceListView.startAnimatingImageView()
        ledgerDeviceListView.startAnimatingIndicatorView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ledgerAccountFetchOperation.reset()
        ledgerDeviceListView.stopAnimatingImageView()
        ledgerDeviceListView.stopAnimatingIndicatorView()
        stopTimer()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerAccountFetchOperation.delegate = self
        ledgerDeviceListView.devicesCollectionView.delegate = self
        ledgerDeviceListView.devicesCollectionView.dataSource = self
    }

    override func setListeners() {
        super.setListeners()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startScanFromBackground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        view.addSubview(ledgerDeviceListView)
        ledgerDeviceListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension LedgerDeviceListViewController {
    private func addBarButtons() {
        addTroubleshootBarButton()
    }

    private func addTroubleshootBarButton() {
        let troubleshootBarButtonItem = ALGBarButtonItem(kind: .troubleshoot) { [weak self] in
            self?.open(
                .ledgerTutorial(
                    flow: .addNewAccount(mode: .recover(type: .ledger))
                ),
                by: .present
            )
        }

        rightBarButtonItems = [troubleshootBarButtonItem]
    }
}

extension LedgerDeviceListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ledgerDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(LedgerDeviceCell.self, at: indexPath)
        let device = ledgerDevices[indexPath.item]
        cell.bindData(LedgerDeviceListViewModel(device))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startTimer()
        
        selectedDevice = ledgerDevices[indexPath.item]

        let oneTimeDisplayStorage = OneTimeDisplayStorage()
        if oneTimeDisplayStorage.isDisplayedOnce(for: .ledgerPairingWarning) {
            ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
            selectedDevice = nil
            return
        }

        oneTimeDisplayStorage.setDisplayedOnce(for: .ledgerPairingWarning)

        initialPairingWarningTransition.perform(
            .ledgerPairWarning(delegate: self),
            by: .presentWithoutNavigationController
        )
        
        ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
    }
}

extension LedgerDeviceListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
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

extension LedgerDeviceListViewController {
    private func presentConnectionSupportWarningAlert() {
        let bottomTransition = BottomSheetTransition(presentingViewController: self)

        bottomTransition.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerAccountFetchOperation.bleConnectionManager.stopScan()

            self.bannerController?.presentErrorBanner(
                title: "ble-error-connection-title".localized,
                message: ""
            )

            self.presentConnectionSupportWarningAlert()
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension LedgerDeviceListViewController {
    @objc
    private func startScanFromBackground() {
        ledgerDeviceListView.startAnimatingImageView()
        ledgerAccountFetchOperation.startScan()
    }
}

extension LedgerDeviceListViewController: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account]
    ) {
        ledgerDeviceListView.stopAnimatingIndicatorView()

        if isViewDisappearing {
            return
        }
        
        ledgerApprovalViewController?.closeScreen(by: .dismiss, animated: true) {
            self.open(.ledgerAccountSelection(flow: self.accountSetupFlow, accounts: accounts), by: .push)
        }
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral]) {
        ledgerDeviceListView.stopAnimatingIndicatorView()
        ledgerDevices = peripherals
        ledgerDeviceListView.devicesCollectionView.reloadData()
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError) {
        ledgerDeviceListView.stopAnimatingIndicatorView()
        switch error {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )

        ledgerApprovalViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCancel:
                self.ledgerApprovalViewController?.dismissScreen()
            }
        }
    }

    func ledgerAccountFetchOperationDidFinishTimingOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        stopTimer()
    }

    func ledgerAccountFetchOperationDidResetOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        ledgerApprovalViewController?.dismissScreen()
    }
}
