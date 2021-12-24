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
//  WatchAccountAdditionViewController.swift

import UIKit
import SVProgressHUD

class WatchAccountAdditionViewController: BaseScrollViewController {
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    private lazy var watchAccountAdditionView = WatchAccountAdditionView()
    
    private var keyboardController = KeyboardController()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "watch-account-create".localized
    }
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        watchAccountAdditionView.delegate = self
        scrollView.touchDetectingDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupWatchAccountAdditionViewLayout()
    }
}

extension WatchAccountAdditionViewController {
    private func setupWatchAccountAdditionViewLayout() {
        contentView.addSubview(watchAccountAdditionView)
        
        watchAccountAdditionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        guard let address = watchAccountAdditionView.addressInputView.inputTextView.text,
            !address.isEmpty,
            address.isValidatedAddress() else {
            displaySimpleAlertWith(title: "title-error".localized, message: "watch-account-error-address".localized)
            return
        }
        
        if session?.account(from: address) != nil {
            displaySimpleAlertWith(title: "title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
            return
        }
        
        view.endEditing(true)
        let account = createAccount(from: address, with: address.shortAddressDisplay())
        log(RegistrationEvent(type: .watch))
        openSuccessModal(for: account)
    }
    
    private func createAccount(from address: String, with name: String) -> AccountInformation {
        let account = AccountInformation(address: address, name: name, type: .watch)
        let user: User
        
        if let authenticatedUser = session?.authenticatedUser {
            user = authenticatedUser
            if session?.authenticatedUser?.account(address: address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }
        } else {
            user = User(accounts: [account])
        }
        
        session?.addAccount(Account(accountInformation: account))
        session?.authenticatedUser = user
        return account
    }
    
    private func openSuccessModal(for account: AccountInformation) {
        let configurator = BottomInformationBundle(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("img-green-checkmark"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.launchHome(with: account)
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
    
    private func launchHome(with account: AccountInformation) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                case .none:
                    break
                }
            }
        }
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
        
        watchAccountAdditionView.addressInputView.value = qrText.qrText()
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
        if watchAccountAdditionView.nextButton.frame.contains(point) ||
            watchAccountAdditionView.addressInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
