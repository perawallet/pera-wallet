// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RemoveAccountFlowCoordinator.swift

import Foundation
import UIKit

final class RemoveAccountFlowCoordinator {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private unowned let presentingScreen: UIViewController

    private let sharedDataController: SharedDataController
    private let bannerController: BannerController

    private lazy var transitionToBackUpBeforeRemovingAccountWarning = BottomSheetTransition(presentingViewController: presentingScreen)
    private lazy var transitionToRemoveAccount = BottomSheetTransition(presentingViewController: presentingScreen)

    init(
        presentingScreen: UIViewController,
        sharedDataController: SharedDataController,
        bannerController: BannerController
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
    }
}

extension RemoveAccountFlowCoordinator {
    func launch(_ account: Account) {
        openRemoveAccountIfPossible(account)
    }
}

extension RemoveAccountFlowCoordinator {
    private func openRemoveAccountIfPossible(_ account: Account) {
        let result = validateRemoval(of: account)
        switch result {
        case .granted:
            openBackUpBeforeRemovingAccountWarning(account)
        case .denied(let error):
            presentError(error)
        }
    }

    private func validateRemoval(of account: Account) -> RemoveAccountAuthorizationResult {
        let validator = RemoveAuthAccountAuthorizationValidator(sharedDataContoller: sharedDataController)
        return validator.validate(account)
    }

    private func openBackUpBeforeRemovingAccountWarning(_ account: Account) {
        let eventHandler: BackUpBeforeRemovingAccountWarningSheet.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didConfirm:
                self.presentingScreen.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openRemoveAccount(account)
                }
            case .didCancel:
                self.presentingScreen.dismiss(animated: true)
            }
        }
        transitionToBackUpBeforeRemovingAccountWarning.perform(
            .backUpBeforeRemovingAccountWarning(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openRemoveAccount(_ account: Account) {
        let eventHandler: RemoveAccountSheet.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didRemoveAccount:
                self.presentingScreen.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.eventHandler?(.didRemoveAccount)
                }
            case .didCancel:
                self.presentingScreen.dismiss(animated: true)
            }
        }
        transitionToRemoveAccount.perform(
            .removeAccount(
                account: account,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func presentError(_ error: RemoveAccountErrorDisplayable) {
        bannerController.present(error)
    }
}

extension RemoveAccountFlowCoordinator {
    enum Event {
        case didRemoveAccount
    }
}

private extension BannerController {
    func present(_ error: RemoveAccountErrorDisplayable) {
        presentErrorBanner(
            title: error.message,
            message: ""
        )
    }
}
