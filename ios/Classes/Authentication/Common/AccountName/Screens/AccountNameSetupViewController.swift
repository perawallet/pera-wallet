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
//  AccountNameSettingViewController.swift

import UIKit
import MacaroonUIKit

final class AccountNameSetupViewController: BaseScrollViewController {
    private lazy var accountNameSetupView = AccountNameSetupView()
    private lazy var theme = Theme()
    
    private var keyboardController = KeyboardController()

    private let flow: AccountSetupFlow
    private let mode: AccountSetupMode
    private let accountAddress: PublicKey

    init(
        flow: AccountSetupFlow,
        mode: AccountSetupMode,
        accountAddress: PublicKey,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.mode = mode
        self.accountAddress = accountAddress
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
        accountNameSetupView.setListeners()
    }
    
    override func linkInteractors() {
        accountNameSetupView.linkInteractors()
        (scrollView as? TouchDetectingScrollView)?.touchDetectingDelegate = self
        keyboardController.dataSource = self
        accountNameSetupView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addAccountNameSetupView()
    }

    override func bindData() {
        super.bindData()
        accountNameSetupView.bindData(accountAddress.shortAddressDisplay)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountNameSetupView.beginEditing()
    }
}

extension AccountNameSetupViewController {
    private func addAccountNameSetupView() {
        accountNameSetupView.customize(theme.accountNameSetupViewViewTheme)

        contentView.addSubview(accountNameSetupView)
        accountNameSetupView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AccountNameSetupViewController: AccountNameSetupViewDelegate {
    func accountNameSetupViewDidFinishAccountCreation(_ accountNameSetupView: AccountNameSetupView) {
        analytics.track(.onboardWatchAccount(type: .create))
        setupAccountName()
    }
    
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView) {}
}

extension AccountNameSetupViewController {
    private func setupAccountName() {
        let accountName: String
        if let nameInput = accountNameSetupView.accountNameInputView.text,
           !nameInput.isEmpty {
            accountName = nameInput
        } else {
            accountName = accountAddress.shortAddressDisplay
        }

        session?.updateName(accountName, for: accountAddress)

        switch flow {
        case .initializeAccount:
            openPasscode()
        case .addNewAccount:
            openAccountVerifiedTutorial()
        default:
            break
        }
    }

    private func openAccountVerifiedTutorial() {
        open(
            .tutorial(flow: flow, tutorial: .accountVerified(flow: flow)),
            by: .push
        )
    }

    private func openPasscode() {
        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()

        let controller = open(
            .tutorial(flow: flow, tutorial: .passcode),
            by: .push
        ) as? TutorialViewController

        controller?.uiHandlers.didTapDontAskAgain = { [weak self] tutorialViewController in
            guard let self = self else {
                return
            }

            passcodeSettingDisplayStore.disableAskingPasscode()
            
            switch self.flow {
            case .initializeAccount:
                self.openAccountVerifiedTutorial()
                return
            default:
                break
            }

            if case .add(type: .watch) = self.mode {
                self.openAccountVerifiedTutorial()
                return
            }

            self.launchMain()
        }

        controller?.uiHandlers.didTapSecondaryActionButton = { [weak self] tutorialViewController in
            guard let self = self else {
                return
            }
            
            switch self.flow {
            case .initializeAccount:
                self.openAccountVerifiedTutorial()
                return
            default:
                break
            }
            
            if case .add(type: .watch) = self.mode {
                self.openAccountVerifiedTutorial()
                return
            }

            self.launchMain()
        }
    }
}

extension AccountNameSetupViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 20
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountNameSetupView.accountNameInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 20
    }
}

extension AccountNameSetupViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if accountNameSetupView.nextButton.frame.contains(point) ||
            accountNameSetupView.accountNameInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}
