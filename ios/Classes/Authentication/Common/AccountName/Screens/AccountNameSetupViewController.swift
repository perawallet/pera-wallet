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
import MacaroonForm

final class AccountNameSetupViewController:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource {
    private lazy var theme = AccountNameSetupViewControllerTheme()

    private lazy var titleView = UILabel()
    private lazy var descriptionView = UILabel()
    private lazy var nameInputView = FloatingTextInputFieldView()
    private lazy var actionView = MacaroonUIKit.Button()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let flow: AccountSetupFlow
    private let mode: AccountSetupMode
    private let nameServiceName: String?
    private let accountAddress: PublicKey

    init(
        flow: AccountSetupFlow,
        mode: AccountSetupMode,
        nameServiceName: String?,
        accountAddress: PublicKey,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.mode = mode
        self.nameServiceName = nameServiceName
        self.accountAddress = accountAddress

        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameInputView.beginEditing()
    }

    override func prepareLayout() {
        super.prepareLayout()

        scrollView.keyboardDismissMode = .onDrag

        addUI()
    }

    override func configureAppearance() {
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        let baseGradientColor = Colors.Defaults.background.uiColor
        backgroundGradient.colors = [
            baseGradientColor.withAlphaComponent(0),
            baseGradientColor
        ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension AccountNameSetupViewController {
    private func addUI() {
        addBackground()
        addTitle()
        addDescription()
        addNameInput()
        addAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addNameInput() {
        nameInputView.customize(theme.nameInput)

        contentView.addSubview(nameInputView)
        nameInputView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingBetweenDescriptionAndNameInput
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.greaterThanHeight(theme.nameInputMinHeight)
        }

        nameInputView.delegate = self

        bindNameInput()
    }

    private func addAction() {
        actionView.customizeAppearance(theme.action)

        footerView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.snp.makeConstraints {
            $0.top == theme.actionContentEdgeInsets.top
            $0.leading == theme.actionContentEdgeInsets.leading
            $0.trailing == theme.actionContentEdgeInsets.trailing
            $0.bottom == theme.actionContentEdgeInsets.bottom
        }

        actionView.addTouch(
            target: self,
            action: #selector(setupAccountName)
        )
    }
}

extension AccountNameSetupViewController: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        setupAccountName()
        return true
    }
}

extension AccountNameSetupViewController {
    private func bindNameInput() {
        let name = nameServiceName.unwrap(or: accountAddress.shortAddressDisplay)
        nameInputView.text = name
    }
}

extension AccountNameSetupViewController {
    @objc
    private func setupAccountName() {
        nameInputView.endEditing()

        analytics.track(.onboardWatchAccount(type: .create))

        let accountName: String
        if let nameInput = nameInputView.text,
           !nameInput.isEmpty {
            accountName = nameInput
        } else {
            let name = nameServiceName.unwrap(or: accountAddress.shortAddressDisplay)
            accountName = name
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
            .tutorial(
                flow: flow,
                tutorial: .accountVerified(
                    flow: flow,
                    address: accountAddress
                )
            ),
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

            if self.mode == .watch {
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
            
            if self.mode == .watch {
                self.openAccountVerifiedTutorial()
                return
            }

            self.launchMain()
        }
    }
}

extension AccountNameSetupViewController {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return nameInputView.frame
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        if let keyboard = keyboardController.keyboard {
            footerBackgroundView.snp.updateConstraints {
                $0.bottom == keyboard.height
            }

            let animator = UIViewPropertyAnimator(
                duration: keyboard.animationDuration,
                curve: keyboard.animationCurve
            ) {
                [unowned self] in
                view.layoutIfNeeded()
            }
            animator.startAnimation()
        }

        return spacingBetweenContentAndKeyboard()
    }

    private func spacingBetweenContentAndKeyboard() -> LayoutMetric {
        return footerView.frame.height
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return scrollView.contentInset.bottom
        }

        footerBackgroundView.snp.updateConstraints {
            $0.bottom == 0
        }

        let animator = UIViewPropertyAnimator(
            duration:  0.25,
            curve: .easeOut
        ) {
            [unowned self] in
            view.layoutIfNeeded()
        }
        animator.startAnimation()

        return .zero
    }
}
