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
//  WatchAccountAdditionViewController.swift

import UIKit

final class WatchAccountAdditionViewController: BaseScrollViewController {
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!,
        bannerController: bannerController
    )

    private lazy var watchAccountAdditionView = WatchAccountAdditionView()
    private lazy var theme = Theme()
    
    private var keyboardController = KeyboardController()
    
    private let accountSetupFlow: AccountSetupFlow
    private var address: PublicKey?
    
    init(
        accountSetupFlow: AccountSetupFlow,
        address: PublicKey?,
        configuration: ViewControllerConfiguration
    ) {
        self.accountSetupFlow = accountSetupFlow
        self.address = address
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        super.setListeners()
        watchAccountAdditionView.setListeners()
        keyboardController.beginTracking()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pasteFromClipboard),
            name: UIPasteboard.changedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pasteFromClipboard),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func linkInteractors() {
        watchAccountAdditionView.linkInteractors()
        keyboardController.dataSource = self
        watchAccountAdditionView.delegate = self
        (scrollView as? TouchDetectingScrollView)?.touchDetectingDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        contentView.addSubview(watchAccountAdditionView)
        watchAccountAdditionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        if let address = address {
            watchAccountAdditionView.addressInputView.text = address
        }

        pasteFromClipboard()
    }
}

extension WatchAccountAdditionViewController {
    @objc
    func pasteFromClipboard() {
        watchAccountAdditionView.bindData(WatchAccountAdditionViewModel(UIPasteboard.general.string))
    }
}

extension WatchAccountAdditionViewController: WatchAccountAdditionViewDelegate {
    func watchAccountAdditionViewDidScanQR(_ watchAccountAdditionView: WatchAccountAdditionView) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }
        
        guard let qrScannerViewController = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
    
    func watchAccountAdditionViewDidAddAccount(_ watchAccountAdditionView: WatchAccountAdditionView) {
        guard let address = watchAccountAdditionView.addressInputView.text,
            !address.isEmpty,
            address.isValidatedAddress else {
            displaySimpleAlertWith(title: "title-error".localized, message: "watch-account-error-address".localized)
            return
        }
        
        if sharedDataController.accountCollection[address] != nil {
            displaySimpleAlertWith(title: "title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
            return
        }
        
        view.endEditing(true)
        let account = createAccount(from: address, with: address.shortAddressDisplay)
        analytics.track(.registerAccount(registrationType: .watch))
        open(.accountNameSetup(flow: accountSetupFlow, mode: .add(type: .watch), accountAddress: account.address), by: .push)
    }
    
    private func createAccount(from address: String, with name: String) -> AccountInformation {
        let account = AccountInformation(
            address: address,
            name: name,
            type: .watch,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount()
        )
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            if session?.authenticatedUser?.account(address: address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }
            pushNotificationController.sendDeviceDetails()
        } else {
            user = User(accounts: [account])
        }

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )
        
        session?.authenticatedUser = user
        return account
    }
}

extension WatchAccountAdditionViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .address else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-address-message".localized) { _ in
                if let handler = completionHandler {
                    handler()
                }
            }
            return
        }
        
        watchAccountAdditionView.addressInputView.text = qrText.qrText()
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension WatchAccountAdditionViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return watchAccountAdditionView.addressInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0.0
    }
}

extension WatchAccountAdditionViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if watchAccountAdditionView.createWatchAccountButton.frame.contains(point) ||
            watchAccountAdditionView.addressInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
