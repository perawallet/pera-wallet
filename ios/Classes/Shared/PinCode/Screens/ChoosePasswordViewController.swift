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
//  ChoosePasswordViewController.swift

import UIKit
import AVFoundation

/// <todo>
/// Refactor
final class ChoosePasswordViewController: BaseViewController {
    private let viewModel: ChoosePasswordViewModel
    private let accountSetupFlow: AccountSetupFlow?
    private let mode: Mode

    private lazy var choosePasswordView = ChoosePasswordView()
    private lazy var theme = Theme()
    
    private lazy var localAuthenticator = LocalAuthenticator(session: session!)
    
    private var pinLimitStore = PinLimitStore()

    weak var delegate: ChoosePasswordViewControllerDelegate?
    
    init(mode: Mode, accountSetupFlow: AccountSetupFlow?, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.accountSetupFlow = accountSetupFlow
        self.viewModel = ChoosePasswordViewModel(mode)
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPinLimitScreenIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkLoginFlow()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        if case .login = mode {
            hidesCloseBarButtonItem = true
            return
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupChoosePasswordViewLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        choosePasswordView.linkInteractors()
        choosePasswordView.delegate = self
    }

    override func bindData() {
        super.bindData()
        viewModel.configure(choosePasswordView)
    }
}

extension ChoosePasswordViewController {
    private func setupChoosePasswordViewLayout() {
        choosePasswordView.customize(theme.choosePasswordViewTheme)

        view.addSubview(choosePasswordView)
        choosePasswordView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ChoosePasswordViewController {
    private func displayPinLimitScreenIfNeeded() {
        if shouldDisplayPinLimitScreen(isFirstLaunch: true), case .login = mode {
            displayPinLimitScreen()
        }
    }

    private func checkLoginFlow() {
        if case let .login(flow) = mode {
            if localAuthenticator.hasAuthentication() {
                do {
                    try localAuthenticator.authenticate()

                    switch flow {
                    case .app:
                        self.launchHome()
                    case .feature:
                        self.delegate?.choosePasswordViewController(self, didConfirmPassword: true)
                    }
                } catch {}
                return
            }
        }
    }
    
    private func launchHome() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            self.launchMainAfterAuthorization(presented: self)
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
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadButton.NumpadKey) {
        switch mode {
        case .setup:
            openVerifyPassword(with: value)
        case let .verify(previousPassword):
            verifyPassword(with: value, and: previousPassword)
        case .login(let flow):
            login(with: value, flow: flow)
        case .deletePassword:
            deletePassword(with: value)
        case .resetPassword(let flow):
            openResetVerify(with: value, flow: flow)
        case let .resetVerify(previousPassword, flow):
            verifyResettedPassword(with: value, and: previousPassword, flow: flow)
        case .confirm:
            confirmPassword(with: value)
        case .verifyOld:
            openResetPassword(with: value)
        }
    }
}

extension ChoosePasswordViewController {
    private func openVerifyPassword(with value: NumpadButton.NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .verify(password: password), flow: accountSetupFlow), by: .push)
        }
    }

    private func openResetPassword(with value: NumpadButton.NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                open(.choosePassword(mode: .resetPassword(flow: .fromVerifyOld), flow: nil), by: .push)
            } else {
                handleInvalidPassword()
            }
        }
    }
    
    private func verifyPassword(with value: NumpadButton.NumpadKey, and previousPassword: String) {
        guard let flow = accountSetupFlow else {
            return
        }
        
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                handleInvalidPassword()
                return
            }
            configuration.session?.savePassword(password)
            self.analytics.track(.onboardSetPinCode(type: .verify))
            let controller = open(
                .tutorial(flow: flow, tutorial: .localAuthentication),
                by: .push
            ) as? TutorialViewController
            controller?.uiHandlers.didTapSecondaryActionButton = { tutorialViewController in
                switch flow {
                case .initializeAccount:
                    tutorialViewController.open(
                        .tutorial(flow: .none, tutorial: .accountVerified(flow: flow)),
                        by: .push
                    )
                    return
                default:
                    break
                }
                
                if case .none = flow {
                    tutorialViewController.dismissScreen()
                } else {
                    tutorialViewController.launchMain()
                }
            }
        }
    }

    private func login(with value: NumpadButton.NumpadKey, flow: Mode.LoginFlow) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                choosePasswordView.numpadView.isUserInteractionEnabled = false
                pinLimitStore.resetPinAttemptCount()

                switch flow {
                case .app:
                    launchHome()
                case .feature:
                    delegate?.choosePasswordViewController(self, didConfirmPassword: true)
                }
            } else {
                pinLimitStore.increasePinAttemptCount()
                handleInvalidPassword()

                let (attemptCount, _) = pinLimitStore.attemptCount.quotientAndRemainder(
                    dividingBy: pinLimitStore.allowedAttemptLimitCount
                )
                if shouldDisplayPinLimitScreen(isFirstLaunch: false) {
                    // Pin limit waiting time increases exponentially with respect to attempt count and 30 seconds.
                    let newRemainingTime = 30 * (pow(2, attemptCount - 1) as NSDecimalNumber).intValue
                    pinLimitStore.setRemainingTime(newRemainingTime)
                    displayPinLimitScreen()
                }
            }
        }
    }
    
    private func openResetVerify(with value: NumpadButton.NumpadKey, flow: Mode.ResetFlow) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .resetVerify(password: password, flow: flow), flow: nil), by: .push)
        }
    }
    
    private func verifyResettedPassword(with value: NumpadButton.NumpadKey, and previousPassword: String, flow: Mode.ResetFlow) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                handleInvalidPassword()
                return
            }

            configuration.session?.savePassword(password)

            guard let navigationController = navigationController else {
                return
            }


            var viewControllers = navigationController.viewControllers

            switch flow {
            case .initial:
                viewControllers.removeLast(2)
            case .fromVerifyOld:
                viewControllers.removeLast(3)
            }

            navigationController.setViewControllers(viewControllers, animated: true)
        }
    }

    private func confirmPassword(with value: NumpadButton.NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                delegate?.choosePasswordViewController(self, didConfirmPassword: true)
            } else {
                handleInvalidPassword()
            }
        }
    }
    
    private func deletePassword(with value: NumpadButton.NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                session?.deletePassword()
                popScreen()
            } else {
                handleInvalidPassword()
            }
        }
    }

    private func handleInvalidPassword() {
        choosePasswordView.changeStateTo(.error)
        choosePasswordView.shake {
            self.viewModel.reset()
            self.choosePasswordView.changeStateTo(.empty)
            self.choosePasswordView.toggleDeleteButtonVisibility(for: true)
        }
    }
}

extension ChoosePasswordViewController: PinLimitViewControllerDelegate {
    func pinLimitViewControllerDidResetAllData(_ pinLimitViewController: PinLimitViewController) {
        guard let rootViewContorller = UIApplication.shared.rootViewController() else {
            return
        }

        rootViewContorller.deleteAllData { [weak self] isCompleted in
            guard let self = self else {
                return
            }

            if isCompleted {
                AppDelegate.shared?.launchOnboarding()
                return
            }

            self.bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "pass-phrase-verify-sdk-error".localized
            )
        }
    }
}

extension ChoosePasswordViewController {
    enum Mode: Equatable {
        case setup
        case verify(password: String)
        case login(flow: LoginFlow)
        case deletePassword
        case verifyOld
        case resetPassword(flow: ResetFlow)
        case resetVerify(password: String, flow: ResetFlow)
        case confirm(flow: ConfirmFlow)

        /// <todo>: Will be changed when this screen refactored
        /// LoginFlow is created for separating launch logics
        /// For some features, we should ask the authorization to user but it shouldn't invoke the launch operation
        /// If developer use feature-specific login, feature case should be used.
        enum LoginFlow {
            case app
            case feature
        }

        enum ResetFlow {
            case fromVerifyOld
            case initial
        }

        enum ConfirmFlow {
            case settings
            case viewPassphrase
        }
    }
}

protocol ChoosePasswordViewControllerDelegate: AnyObject {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    )
}
