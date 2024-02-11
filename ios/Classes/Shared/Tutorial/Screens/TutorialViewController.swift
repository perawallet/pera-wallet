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
//  TutorialViewController.swift

import UIKit

final class TutorialViewController: BaseScrollViewController {
    lazy var uiHandlers = TutorialViewControllerUIHandlers()

    private lazy var tutorialView = TutorialView()
    private lazy var theme = Theme()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )
    
    private let flow: AccountSetupFlow
    private let tutorial: Tutorial

    private lazy var localAuthenticator = LocalAuthenticator(session: session!)

    init(
        flow: AccountSetupFlow,
        tutorial: Tutorial,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.tutorial = tutorial
        super.init(configuration: configuration)

        switch tutorial {
        case .passphraseVerified,
             .localAuthentication,
             .accountVerified,
             .biometricAuthenticationEnabled,
             .collectibleTransferConfirmed,
             .ledgerSuccessfullyConnected,
             .failedToImportLedgerAccounts:
            hidesCloseBarButtonItem = true
        default: break
        }
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setPopGestureEnabledInLocalAuthenticationTutorial(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabledInLocalAuthenticationTutorial(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        tutorialView.bindData(
            TutorialViewModel(tutorial, theme: theme.tutorialViewTheme)
        )
    }

    override func setListeners() {
        super.setListeners()
        tutorialView.delegate = self
        tutorialView.setListeners()
    }

    override func prepareLayout() {
        super.prepareLayout()
        tutorialView.customize(theme.tutorialViewTheme)

        contentView.addSubview(tutorialView)
        tutorialView.pinToSuperview()
    }
}

extension TutorialViewController {
    private func addBarButtons() {
        switch tutorial {
        case .recoverWithPassphrase,
             .backUp,
             .watchAccount,
             .recoverWithLedger:
            addInfoBarButton()
        case .passcode:
            addDontAskAgainBarButton()
        default:
            break
        }
    }

    private func addInfoBarButton() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.openWalletSupport()
        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    private func addDontAskAgainBarButton() {
        let dontAskAgainBarButtonItem = ALGBarButtonItem(kind: .dontAskAgain) { [weak self] in
            guard let self = self else {
                return
            }

            self.uiHandlers.didTapDontAskAgain?(self)
        }

        rightBarButtonItems = [dontAskAgainBarButtonItem]
    }

    private func openWalletSupport() {
        switch tutorial {
        case .backUp:
            open(AlgorandWeb.backUpSupport.link)
        case .recoverWithPassphrase:
            open(AlgorandWeb.recoverSupport.link)
        case .watchAccount:
            open(AlgorandWeb.watchAccountSupport.link)
        case .recoverWithLedger:
            open(AlgorandWeb.ledgerSupport.link)
        default:
            break
        }
    }
}

extension TutorialViewController: TutorialViewDelegate {
    func tutorialViewDidTapPrimaryActionButton(_ tutorialView: TutorialView) {
        switch tutorial {
        case .backUp(let flow, let address):
            analytics.track(.onboardCreateAccountPassphrase(type: .understand))

            if case .backUpAccount(let needsAccountSelection) = flow,
               needsAccountSelection {
                openAccountSelectionForBackingUp(flow: flow)
                return
            }

            guard let address else { return }
            
            open(
                .tutorial(
                    flow: flow,
                    tutorial: .writePassphrase(
                        flow: flow,
                        address: address
                    )
                ),
                by: .push
            )
        case .writePassphrase(let flow, let address):
            analytics.track(.onboardCreateAccountPassphrase(type: .begin))
            open(.passphraseView(flow: flow, address: address), by: .push)
        case .watchAccount:
            open(.watchAccountAddition(flow: flow), by: .push)
        case .recoverWithPassphrase:
            open(.accountRecover(flow: flow), by: .push)
        case .passcode:
            analytics.track(.onboardSetPinCode(type: .create))
            open(.choosePassword(mode: .setup, flow: flow), by: .push)
        case .localAuthentication:
            askLocalAuthentication()
        case .biometricAuthenticationEnabled:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        case let .passphraseVerified(account):
            analytics.track(.onboardCreateAccountPassphrase(type: .verify))

            if case .backUpAccount = flow {
                backUpAccount(account)
                return
            }

            open(
                .accountNameSetup(
                    flow: flow,
                    mode: .add,
                    accountAddress: account.address
                ),
                by: .push
            )
        case .accountVerified(let flow, let address):
            analytics.track(.onboardCreateAccountVerified(type: .buyAlgo))
           
            routeBuyAlgo(
                flow: flow,
                address: address
            )
        case .ledgerSuccessfullyConnected:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        case .failedToImportLedgerAccounts:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        case .recoverWithLedger:
            open(.ledgerDeviceList(flow: flow), by: .push)
        case .collectibleTransferConfirmed:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        }
    }

    func tutorialViewDidTapSecondaryActionButton(_ tutorialView: TutorialView) {
        switch tutorial {
        case .passcode:
            uiHandlers.didTapSecondaryActionButton?(self)
        case .localAuthentication:
            uiHandlers.didTapSecondaryActionButton?(self)
        case .recoverWithLedger:
            open(
                .ledgerTutorial(
                    flow: .addNewAccount(mode: .recover(type: .ledger))
                ),
                by: .present
            )
        case .backUp,
             .writePassphrase:
            guard let newAccount = createAccount() else {
                return
            }

            let screen = open(
                .accountNameSetup(
                    flow: flow,
                    mode: .add,
                    accountAddress: newAccount.address
                ),
                by: .push
            ) as? AccountNameSetupViewController
            screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            screen?.hidesCloseBarButtonItem = true
        case .ledgerSuccessfullyConnected:
            uiHandlers.didTapSecondaryActionButton?(self)
        case .accountVerified(let flow, _):
            if case .initializeAccount(mode: .watch) = flow {
                analytics.track(.onboardWatchAccount(type: .verified))
            } else if case .addNewAccount(mode: .watch) = flow {
                analytics.track(.onboardWatchAccount(type: .verified))
            } else {
                analytics.track(.onboardCreateAccountVerified(type: .start))
            }

            launchMain()
        default:
            break
        }
    }

    private func routeBuyAlgo(
        flow: AccountSetupFlow,
        address: PublicKey?
    ) {
        if case .initializeAccount(mode: .watch) = flow {
            launchMain()
            return
        } else if case .addNewAccount(mode: .watch) = flow {
            launchMain()
            return
        }

        launchMain {
            [weak self] in
            guard let self = self else { return }
            
            let draft = MeldDraft(address: address)
            self.launchBuyAlgoWithMeld(draft: draft)
        }
    }
}

extension TutorialViewController {
    private func openAccountSelectionForBackingUp(flow: AccountSetupFlow) {
        let accountSelectionScreen = Screen.backUpAccountSelection {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let account):
                open(
                    .tutorial(
                        flow: flow,
                        tutorial: .writePassphrase(
                            flow: flow,
                            address: account.value.address
                        )
                    ),
                    by: .push
                )
            default: break
            }
        }

        open(
            accountSelectionScreen,
            by: .push
        )
    }

    private func backUpAccount(_ account: AccountInformation) {
        if let localAccount = session?.accountInformation(from: account.address) {
            localAccount.isBackedUp = true
            session?.authenticatedUser?.updateAccount(localAccount)
        }

        if let cachedAccount = sharedDataController.accountCollection[account.address]?.value {
            cachedAccount.isBackedUp = true

            NotificationCenter.default.post(
                name: BackUpAccountFlowCoordinator.didBackupAccount,
                object: nil,
                userInfo: [
                    BackUpAccountFlowCoordinator.didBackUpAccountNotificationAccountKey: cachedAccount
                ]
            )
        }
    }
}

extension TutorialViewController {
    private func setPopGestureEnabledInLocalAuthenticationTutorial(_ isEnabled: Bool) {
        switch tutorial {
        case .localAuthentication,
                .accountVerified,
                .passphraseVerified:
            navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        default:
            break
        }
    }

    private func askLocalAuthentication() {
        do {
            try localAuthenticator.setBiometricPassword()
            openModalWhenAuthenticationUpdatesCompleted()
        } catch {
            presentDisabledLocalAuthenticationAlert()
        }
    }

    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func openModalWhenAuthenticationUpdatesCompleted() {
        let controller = open(
            .tutorial(
                flow: flow,
                tutorial: .biometricAuthenticationEnabled
            ),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        ) as? TutorialViewController

        controller?.uiHandlers.didTapButtonPrimaryActionButton = { [weak self] tutorialViewController in
            guard let self = self else {
                return
            }

            if case .none = self.flow {
                self.dismissScreen()
            } else {
                tutorialViewController.launchMain()
            }
        }
    }
}

struct TutorialViewControllerUIHandlers {
    var didTapDontAskAgain: ((TutorialViewController) -> Void)?
    var didTapButtonPrimaryActionButton: ((TutorialViewController) -> Void)?
    var didTapSecondaryActionButton: ((TutorialViewController) -> Void)?
}

enum Tutorial: Equatable {
    case backUp(flow: AccountSetupFlow, address: String?)
    case writePassphrase(flow: AccountSetupFlow, address: String)
    case watchAccount
    case recoverWithPassphrase
    case passcode
    case localAuthentication
    case biometricAuthenticationEnabled
    case passphraseVerified(account: AccountInformation)
    case accountVerified(flow: AccountSetupFlow, address: String? = nil)
    case recoverWithLedger
    case ledgerSuccessfullyConnected(flow: AccountSetupFlow)
    case failedToImportLedgerAccounts
    case collectibleTransferConfirmed
}

extension TutorialViewController {
    private func createAccount() -> AccountInformation? {
        generatePrivateKey()

        guard 
            let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp")
        else {
            return nil
        }

        analytics.track(.registerAccount(registrationType: .create))

        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false
        )
        session?.savePrivate(tempPrivateKey, for: account.address)
        session?.removePrivateData(for: "temp")

        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }

        return account
    }

    private func generatePrivateKey() {
        guard let session = session,
              let privateKey = session.generatePrivateKey() else {
            return
        }

        session.savePrivate(privateKey, for: "temp")
    }
}
