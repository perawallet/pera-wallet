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
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)


    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var transitionToLedgerConnection: BottomSheetTransition?

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

        ledgerAccountFetchOperation.startScan()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        ledgerAccountFetchOperation.reset()
        stopTimer()

        ledgerDeviceListView.stopAnimatingImageView()
        ledgerDeviceListView.stopAnimatingIndicatorView()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerAccountFetchOperation.delegate = self
        ledgerDeviceListView.devicesCollectionView.delegate = self
        ledgerDeviceListView.devicesCollectionView.dataSource = self
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

        /// <note>
        /// Ledger pairing tutorial is temporarily disabled due to its association with connection issues on Ledger devices. We can re-enable it once the underlying issue has been resolved. Date: 27.09.2023
        ///
//        let oneTimeDisplayStorage = OneTimeDisplayStorage()
        let bleState = ledgerAccountFetchOperation.bleConnectionManager.state
        let isBLEPoweredOn = bleState == .poweredOn
        if !isBLEPoweredOn {
            presentBLEError(bleState)
            return
        }

//        if oneTimeDisplayStorage.isDisplayedOnce(for: .ledgerPairingWarning) {
            ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
            selectedDevice = nil
//            return
//        }

//        oneTimeDisplayStorage.setDisplayedOnce(for: .ledgerPairingWarning)
//
//        initialPairingWarningTransition.perform(
//            .ledgerPairWarning(delegate: self),
//            by: .presentWithoutNavigationController
//        )
//
//        ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
    }

    private func presentBLEError(_ state: CBManagerState) {
        guard let title = state.errorDescription.title,
              let subtitle = state.errorDescription.subtitle else {
            return
        }

        bannerController?.presentErrorBanner(
            title: title,
            message: subtitle
        )
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
        transitionToLedgerConnectionIssuesWarning.perform(
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
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerAccountFetchOperation.stopScan()

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

extension LedgerDeviceListViewController: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account]
    ) {
        ledgerDeviceListView.stopAnimatingIndicatorView()

        if isViewDisappearing {
            return
        }
        
        ledgerConnectionScreen?.closeScreen(by: .dismiss, animated: true) {
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
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            bannerController?.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )

            ledgerConnectionScreen?.dismissScreen()
            ledgerConnectionScreen = nil
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
        let transition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.ledgerAccountFetchOperation.disconnectFromCurrentDevice()
                self.stopTimer()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnection = transition
    }

    func ledgerAccountFetchOperationDidFinishTimingOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        stopTimer()
    }

    func ledgerAccountFetchOperationDidResetOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil
    }
}
