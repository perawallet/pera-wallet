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

//   RekeyToStandardAccountFlowCoordinator.swift

import Foundation
import UIKit

final class RekeyToStandardAccountFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private let sharedDataController: SharedDataController

    private lazy var transitionToAccountInformation = BottomSheetTransition(presentingViewController: presentingScreen)

    init(
        presentingScreen: UIViewController,
        sharedDataController: SharedDataController
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
    }
}

extension RekeyToStandardAccountFlowCoordinator {
    func launch(_ sourceAccount: Account) {
        openInstructionsScreen(sourceAccount)
    }

    private func openInstructionsScreen(_ sourceAccount: Account) {
        let screen = presentingScreen.open(
            .rekeyToStandardAccountInstructions(sourceAccount: sourceAccount),
            by: .present
        ) as? RekeyInstructionsScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else { return }

            switch event {
            case .performPrimaryAction:
                self.openSelectAccountScreen(
                    sourceAccount: sourceAccount,
                    screen: screen
                )
            case .performCloseAction:
                self.presentingScreen.dismiss(animated: true)
            }
        }
    }

    private func openSelectAccountScreen(
        sourceAccount: Account,
        screen: UIViewController
    ) {
        let eventHandler: AccountSelectionListScreen<RekeyAccountSelectionListLocalDataController>.EventHandler = {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let newAuthAccount):
                openRekeyConfirmation(
                    sourceAccount: sourceAccount,
                    newAuthAccount: newAuthAccount,
                    screen: screen
                )
            default:
                break
            }
        }
        screen.open(
            .rekeyAccountSelection(
                eventHandler: eventHandler,
                account: sourceAccount
            ),
            by: .push
        )
    }

    private func openRekeyConfirmation(
        sourceAccount: Account,
        newAuthAccount: AccountHandle,
        screen: UIViewController
    ) {
        let authAccount = sharedDataController.authAccount(of: sourceAccount)
        let rekeyConfirmationScreen = screen.open(
            .rekeyConfirmation(
                sourceAccount: sourceAccount,
                authAccount: authAccount?.value,
                newAuthAccount: newAuthAccount.value
            ),
            by: .push
        ) as? RekeyConfirmationScreen
        rekeyConfirmationScreen?.eventHandler = {
            [weak self, weak rekeyConfirmationScreen] event in
            guard let self,
                  let rekeyConfirmationScreen else {
                return
            }

            switch event {
            case .didRekey:
                self.openRekeySuccessScreen(
                    sourceAccount: sourceAccount,
                    screen: rekeyConfirmationScreen
                )
            }
        }
    }

    private func openRekeySuccessScreen(
        sourceAccount: Account,
        screen: UIViewController
    ) {
        let eventHandler: RekeySuccessScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .performPrimaryAction:
                self.presentingScreen.dismiss(animated: true)
            case .performCloseAction:
                self.presentingScreen.dismiss(animated: true)
            }
        }
        let rekeySuccessSceeen = screen.open(
            .rekeySuccess(
                sourceAccount: sourceAccount,
                eventHandler: eventHandler
            ),
            by: .push
        ) as? RekeySuccessScreen
        rekeySuccessSceeen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
