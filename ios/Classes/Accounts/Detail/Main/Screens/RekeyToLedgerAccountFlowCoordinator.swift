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

//   RekeyToLedgerAccountFlowCoordinator.swift

import Foundation
import UIKit

final class RekeyToLedgerAccountFlowCoordinator {
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

extension RekeyToLedgerAccountFlowCoordinator {
    func launch(_ sourceAccount: Account) {
        openInstructionsScreen(sourceAccount)
    }

    private func openInstructionsScreen(_ sourceAccount: Account) {
        let screen = presentingScreen.open(
            .rekeyToLedgerAccountInstructions(sourceAccount: sourceAccount),
            by: .present
        ) as? RekeyInstructionsScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else { return }

            switch event {
            case .performPrimaryAction:
                openLedgerDeviceList(
                    sourceAccount: sourceAccount,
                    screen: screen
                )
            case .performCloseAction:
                presentingScreen.dismiss(animated: true)
            }
        }
    }

    private func openLedgerDeviceList(
        sourceAccount: Account,
        screen: UIViewController
    ) {
        screen.open(
            .ledgerDeviceList(
                flow: .addNewAccount(mode: .rekey(account: sourceAccount))
            ),
            by: .push
        )
    }
}
