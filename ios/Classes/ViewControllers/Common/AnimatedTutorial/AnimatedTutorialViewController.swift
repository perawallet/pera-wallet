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
//  AnimatedTutorialViewController.swift

import UIKit

class AnimatedTutorialViewController: BaseScrollViewController {

    override var hidesCloseBarButtonItem: Bool {
        return tutorial == .localAuthentication
    }

    weak var delegate: AnimatedTutorialViewControllerDelegate?

    private let flow: AccountSetupFlow
    private let tutorial: AnimatedTutorial
    private let isActionable: Bool

    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 358.0))
    )

    private let localAuthenticator = LocalAuthenticator()

    private lazy var animatedTutorialView = AnimatedTutorialView(isActionable: isActionable)

    init(flow: AccountSetupFlow, tutorial: AnimatedTutorial, isActionable: Bool, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.tutorial = tutorial
        self.isActionable = isActionable
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatedTutorialView.startAnimating(with: LottieConfiguration())
        setPopGestureEnabledInLocalAuthenticationTutorial(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatedTutorialView.stopAnimating()
        setPopGestureEnabledInLocalAuthenticationTutorial(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        setTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        animatedTutorialView.bind(AnimatedTutorialViewModel(tutorial: tutorial))
    }

    override func linkInteractors() {
        super.linkInteractors()
        animatedTutorialView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupAnimatedTutorialViewLayout()
    }
}

extension AnimatedTutorialViewController {
    private func setupAnimatedTutorialViewLayout() {
        contentView.addSubview(animatedTutorialView)
        animatedTutorialView.pinToSuperview()
    }
}

extension AnimatedTutorialViewController {
    private func addBarButtons() {
        switch tutorial {
        case .recover,
             .backUp,
             .watchAccount:
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

    private func openWalletSupport() {
        switch tutorial {
        case .backUp:
            if let url = AlgorandWeb.backUpSupport.link {
                open(url)
            }
        case .recover:
            if let url = AlgorandWeb.recoverSupport.link {
                open(url)
            }
        case .watchAccount:
            if let url = AlgorandWeb.watchAccountSupport.link {
                open(url)
            }
        default:
            break
        }
    }

    private func addDontAskAgainBarButton() {
        let dontAskAgainBarButtonItem = ALGBarButtonItem(kind: .dontAskAgain) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.animatedTutorialViewControllerDidTapDontAskAgain(self)
        }

        rightBarButtonItems = [dontAskAgainBarButtonItem]
    }
}

extension AnimatedTutorialViewController: AnimatedTutorialViewDelegate {
    func animatedTutorialViewDidApproveTutorial(_ animatedTutorialView: AnimatedTutorialView) {
        switch tutorial {
        case .backUp:
            open(.animatedTutorial(flow: flow, tutorial: .writePassphrase, isActionable: false), by: .push)
        case .writePassphrase:
            open(.passphraseView(address: "temp"), by: .push)
        case .watchAccount:
            open(.watchAccountAddition(flow: flow), by: .push)
        case .recover:
            open(.accountRecover(flow: flow), by: .push)
        case .passcode:
            open(.choosePassword(mode: .setup, flow: flow, route: nil), by: .push)
        case .localAuthentication:
            askLocalAuthentication()
        }
    }

    func animatedTutorialViewDidTakeAction(_ animatedTutorialView: AnimatedTutorialView) {
        switch tutorial {
        case .passcode:
            dismissScreen()
        case .localAuthentication:
            dismissScreen()
        default:
            break
        }
    }
}

extension AnimatedTutorialViewController {
    private func setPopGestureEnabledInLocalAuthenticationTutorial(_ isEnabled: Bool) {
        if tutorial == .localAuthentication {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
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
        let configurator = BottomInformationBundle(
            title: "local-authentication-enabled-title".localized,
            image: img("img-green-checkmark"),
            explanation: "local-authentication-enabled-subtitle".localized,
            actionTitle: "title-go-to-accounts".localized,
            actionImage: img("bg-main-button")) {
                self.dismissScreen()
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
}

protocol AnimatedTutorialViewControllerDelegate: AnyObject {
    func animatedTutorialViewControllerDidTapDontAskAgain(_ animatedTutorialViewController: AnimatedTutorialViewController)
}

enum AnimatedTutorial {
    case backUp
    case writePassphrase
    case watchAccount
    case recover
    case passcode
    case localAuthentication
}
