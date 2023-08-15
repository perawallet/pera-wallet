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

    private let flow: AccountSetupFlow
    private let tutorial: Tutorial

    private let localAuthenticator = LocalAuthenticator()

    init(flow: AccountSetupFlow, tutorial: Tutorial, configuration: ViewControllerConfiguration) {
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
        case .backUp:
            analytics.track(.onboardCreateAccountPassphrase(type: .understand))
            open(.tutorial(flow: flow, tutorial: .writePassphrase), by: .push)
        case .writePassphrase:
            analytics.track(.onboardCreateAccountPassphrase(type: .begin))
            open(.passphraseView(flow: flow, address: "temp"), by: .push)
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
            open(.accountNameSetup(flow: flow, mode: .add(type: .create), accountAddress: account.address), by: .push)
        case .accountVerified(let flow):
            analytics.track(.onboardCreateAccountVerified(type: .buyAlgo))
            routeBuyAlgo(for: flow)
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
        case .accountVerified(let flow):
            if case .initializeAccount(mode: .add(type: .watch)) = flow {
                analytics.track(.onboardWatchAccount(type: .verified))
            } else if case .addNewAccount(mode: .add(type: .watch)) = flow {
                analytics.track(.onboardWatchAccount(type: .verified))
            } else {
                analytics.track(.onboardCreateAccountVerified(type: .start))
            }

            launchMain()
        case .ledgerSuccessfullyConnected:
            uiHandlers.didTapSecondaryActionButton?(self)
        default:
            break
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
        if localAuthenticator.isLocalAuthenticationAvailable {
            localAuthenticator.authenticate { error in
                guard error == nil else {
                    return
                }
                self.localAuthenticator.localAuthenticationStatus = .allowed
                self.openModalWhenAuthenticationUpdatesCompleted()
            }
            return
        }

        presentDisabledLocalAuthenticationAlert()
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
    
    private func routeBuyAlgo(for flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .add(type: .watch)) = flow {
            launchMain()
            return
        } else if case .addNewAccount(mode: .add(type: .watch)) = flow {
            launchMain()
            return
        }
        
        launchMain {
            [weak self] in
            guard let self = self else { return }
            self.launchBuyAlgoWithMoonPay()
        }
    }
}

struct TutorialViewControllerUIHandlers {
    var didTapDontAskAgain: ((TutorialViewController) -> Void)?
    var didTapButtonPrimaryActionButton: ((TutorialViewController) -> Void)?
    var didTapSecondaryActionButton: ((TutorialViewController) -> Void)?
}

enum Tutorial: Equatable {
    case backUp
    case writePassphrase
    case watchAccount
    case recoverWithPassphrase
    case passcode
    case localAuthentication
    case biometricAuthenticationEnabled
    case passphraseVerified(account: AccountInformation)
    case accountVerified(flow: AccountSetupFlow)
    case recoverWithLedger
    case ledgerSuccessfullyConnected(flow: AccountSetupFlow)
    case failedToImportLedgerAccounts
    case collectibleTransferConfirmed
}
