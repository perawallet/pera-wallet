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

//   UndoRekeyFlowCoordinator.swift

import Foundation
import UIKit

final class UndoRekeyFlowCoordinator {
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

extension UndoRekeyFlowCoordinator {
    func launch(_ sourceAccount: Account) {
        openUndoRekeyConfirmationIfPossible(sourceAccount)
    }

    private func openUndoRekeyConfirmationIfPossible(_ sourceAccount: Account) {
        let authAccount = sharedDataController.authAccount(of: sourceAccount)
        guard let authAccount else {
            assertionFailure("Auth account shouldn't be nil.")
            return
        }

        let undoRekeyScreen = presentingScreen.open(
            .undoRekey(
                sourceAccount: sourceAccount,
                authAccount: authAccount.value
            ),
            by: .present
        ) as? UndoRekeyScreen
        undoRekeyScreen?.eventHandler = {
            [weak self, weak undoRekeyScreen] event in
            guard let self,
                  let undoRekeyScreen else {
                return
            }

            switch event {
            case .didUndoRekey:
                self.openUndoRekeySuccessScreen(
                    sourceAccount: sourceAccount,
                    screen: undoRekeyScreen
                )
            }
        }
    }

    private func openUndoRekeySuccessScreen(
        sourceAccount: Account,
        screen: UIViewController
    ) {
        let eventHandler: UndoRekeySuccessScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .performPrimaryAction:
                self.presentingScreen.dismiss(animated: true)
            case .performCloseAction:
                self.presentingScreen.dismiss(animated: true)
            }
        }
        let screen = screen.open(
            .undoRekeySuccess(
                sourceAccount: sourceAccount,
                eventHandler: eventHandler
            ),
            by: .push
        ) as? UndoRekeySuccessScreen
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
