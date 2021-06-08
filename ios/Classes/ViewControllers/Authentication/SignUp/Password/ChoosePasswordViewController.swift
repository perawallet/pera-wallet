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
//  ChoosePasswordViewController.swift

import UIKit
import AVFoundation
import SVProgressHUD

protocol ChoosePasswordViewControllerDelegate: class {
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool)
}

class ChoosePasswordViewController: BaseViewController {
    
    private lazy var choosePasswordView = ChoosePasswordView(mode: mode)
    
    private let viewModel: ChoosePasswordViewModel
    private let accountSetupFlow: AccountSetupFlow?
    private let mode: Mode
    private var route: Screen?
    
    private let localAuthenticator = LocalAuthenticator()
    
    private var pinLimitStore = PinLimitStore()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api,
            mode == .login else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    weak var delegate: ChoosePasswordViewControllerDelegate?
    
    init(mode: Mode, accountSetupFlow: AccountSetupFlow?, route: Screen?, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.accountSetupFlow = accountSetupFlow
        self.route = route
        self.viewModel = ChoosePasswordViewModel(mode: mode)
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTertiaryBackgroundColor()
        displayPinLimitScreenIfNeeded()
    }
    
    override func configureNavigationBarAppearance() {
        switch mode {
        case .confirm,
             .resetPassword:
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                self.dismissScreen()
            }
            leftBarButtonItems = [closeBarButtonItem]
        default:
            break
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.tertiary
        setTitle()
        viewModel.configure(choosePasswordView)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupChoosePasswordViewLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        choosePasswordView.delegate = self
    }
}

extension ChoosePasswordViewController {
    private func setupChoosePasswordViewLayout() {
        view.addSubview(choosePasswordView)
        
        choosePasswordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ChoosePasswordViewController {
    private func displayPinLimitScreenIfNeeded() {
        if shouldDisplayPinLimitScreen(isFirstLaunch: true) && mode == .login {
            displayPinLimitScreen()
        } else {
            checkLoginFlow()
        }
    }
    
    private func setTitle() {
        switch mode {
        case .setup:
            title = "choose-password-title".localized
        case .verify:
            title = "password-verify-title".localized
        case .resetPassword, .resetVerify:
            title = "password-change-title".localized
        case let .confirm(viewTitle):
            title = viewTitle
        default:
            return
        }
    }
    
    private func checkLoginFlow() {
        if mode == .login {
            if localAuthenticator.localAuthenticationStatus == .allowed {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        return
                    }
                    self.launchHome()
                }
            }
            return
        }
    }
    
    private func launchHome() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            self.setupRouteFromNotification()
            DispatchQueue.main.async {
                UIApplication.shared.rootViewController()?.tabBarViewController.route = self.route
            }
            
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                DispatchQueue.main.async {
                    self.dismiss(animated: false) {
                        UIApplication.shared.rootViewController()?.setupTabBarController()
                    }
                }
            }
        }
    }
    
    private func setupRouteFromNotification() {
        guard let navigationRoute = route else {
            return
        }
        
        switch navigationRoute {
        case let .assetDetailNotification(address, assetId):
            guard let account = session?.account(from: address) else {
                return
            }
            
            var assetDetail: AssetDetail?
            
            if let assetId = assetId {
                assetDetail = account.assetDetails.first { $0.id == assetId }
            }
            
            route = .assetDetail(account: account, assetDetail: assetDetail)
        case let .assetActionConfirmationNotification(address, assetId):
            guard let account = session?.account(from: address),
                let assetId = assetId else {
                return
            }
            
            let draft = AssetAlertDraft(
                account: account,
                assetIndex: assetId,
                assetDetail: nil,
                title: "asset-support-add-title".localized,
                detail: String(
                    format: "asset-support-add-message".localized,
                    "\(account.name ?? "")"
                ),
                actionTitle: "title-ok".localized
            )
            
            route = .assetActionConfirmation(assetAlertDraft: draft)
        default:
            break
        }
    }
    
    private func displayPinLimitScreen() {
        let controller = open(
            .pinLimit,
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? PinLimitViewController
        controller?.delegate = self
    }
    
    private func shouldDisplayPinLimitScreen(isFirstLaunch: Bool) -> Bool {
        let (attemptCount, remainder) = pinLimitStore.attemptCount.quotientAndRemainder(dividingBy: pinLimitStore.allowedAttemptLimitCount)
        if isFirstLaunch {
            return attemptCount > 0 && remainder == 0 && pinLimitStore.remainingTime != 0
        }
        return attemptCount > 0 && remainder == 0
    }
}

extension ChoosePasswordViewController: ChoosePasswordViewDelegate {
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadKey) {
        switch mode {
        case .setup:
            openVerifyPassword(with: value)
        case let .verify(previousPassword):
            verifyPassword(with: value, and: previousPassword)
        case .login:
            login(with: value)
        case .resetPassword:
            openResetVerify(with: value)
        case let .resetVerify(previousPassword):
            verifyResettedPassword(with: value, and: previousPassword)
        case .confirm:
            confirmPassword(with: value)
        }
    }
}

extension ChoosePasswordViewController {
    private func openVerifyPassword(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .verify(password), flow: accountSetupFlow, route: nil), by: .push)
        }
    }
    
    private func verifyPassword(with value: NumpadKey, and previousPassword: String) {
        guard let flow = accountSetupFlow else {
            return
        }
        
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                viewModel.reset(choosePasswordView)
                return
            }
            configuration.session?.savePassword(password)
            open(.animatedTutorial(flow: flow, tutorial: .localAuthentication, isActionable: true), by: .push)
        }
    }

    private func login(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                choosePasswordView.numpadView.isUserInteractionEnabled = false
                pinLimitStore.resetPinAttemptCount()
                launchHome()
            } else {
                pinLimitStore.increasePinAttemptCount()
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                viewModel.displayWrongPasswordState(choosePasswordView)
                let (attemptCount, _) = pinLimitStore.attemptCount.quotientAndRemainder(dividingBy: pinLimitStore.allowedAttemptLimitCount)
                if shouldDisplayPinLimitScreen(isFirstLaunch: false) {
                    // Pin limit waiting time increases exponentially with respect to attempt count and 30 seconds.
                    let newRemainingTime = 30 * (pow(2, attemptCount - 1) as NSDecimalNumber).intValue
                    pinLimitStore.setRemainingTime(newRemainingTime)
                    displayPinLimitScreen()
                }
            }
        }
    }
    
    private func openResetVerify(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .resetVerify(password), flow: nil, route: nil), by: .push)
        }
    }
    
    private func verifyResettedPassword(with value: NumpadKey, and previousPassword: String) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                self.viewModel.reset(choosePasswordView)
                return
            }
            configuration.session?.savePassword(password)
            dismissScreen()
        }
    }
    
    private func confirmPassword(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            dismissScreen()
            if session?.isPasswordMatching(with: password) ?? false {
                delegate?.choosePasswordViewController(self, didConfirmPassword: true)
            } else {
                delegate?.choosePasswordViewController(self, didConfirmPassword: false)
            }
        }
    }
}

extension ChoosePasswordViewController: PinLimitViewControllerDelegate {
    func pinLimitViewControllerDidResetAllData(_ pinLimitViewController: PinLimitViewController) {
        UIApplication.shared.rootViewController()?.deleteAllData()
        open(.introduction(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
    }
}

extension ChoosePasswordViewController {
    enum Mode: Equatable {
        case setup
        case verify(String)
        case login
        case resetPassword
        case resetVerify(String)
        case confirm(String)
    }
}
