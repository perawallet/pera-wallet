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

//   AccountInformationFlowCoordinator.swift

import Foundation
import UIKit

final class AccountInformationFlowCoordinator  {
    private unowned let presentingScreen: UIViewController
    private let sharedDataController: SharedDataController

    private lazy var transitionToAccountInformation = BottomSheetTransition(presentingViewController: presentingScreen)

    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )

    init(
        presentingScreen: UIViewController,
        sharedDataController: SharedDataController
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
    }
}

extension AccountInformationFlowCoordinator {
    func launch(_ sourceAccount: Account) {
        let authorization = sourceAccount.authorization

        if authorization.isStandard {
            openAccountInformationForStandardAccount(sourceAccount)
            return
        }

        if authorization.isWatch {
            openAccountInformationForWatchAccount(sourceAccount)
            return
        }

        if authorization.isLedger {
            openAccountInformationForLedgerAccount(sourceAccount)
            return
        }

        if authorization.isNoAuth {
            openAccountInformationForNoAuthInLocal(sourceAccount)
            return
        }

        if authorization.isRekeyed,
           let authAccount = sharedDataController.authAccount(of: sourceAccount) {
            openAccountInformationForRekeyedAccount(
                sourceAccount: sourceAccount,
                authAccount: authAccount
            )
            return
        }
    }
}

extension AccountInformationFlowCoordinator {
    private func openAccountInformationForStandardAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(
            .standardAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        ) as? StandardAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            }
        }
    }

    private func openAccountInformationForWatchAccount(_ sourceAccount: Account) {
        transitionToAccountInformation.perform(
            .watchAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        )
    }

    private func openAccountInformationForLedgerAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(
            .ledgerAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        ) as? LedgerAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            }
        }
    }

    private func openAccountInformationForRekeyedAccount(
        sourceAccount: Account,
        authAccount: AccountHandle
    ) {
        let screen = transitionToAccountInformation.perform(
            .rekeyedAccountInformation(
                sourceAccount: sourceAccount,
                authAccount: authAccount.value
            ),
            by: .presentWithoutNavigationController
        ) as? RekeyedAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            case .performUndoRekey:
                self.openUndoRekey(sourceAccount)
            }
        }
    }

    private func openAccountInformationForNoAuthInLocal(_ sourceAccount: Account) {
        let authorization = sourceAccount.authorization

        if authorization.isRekeyedToNoAuthInLocal {
            transitionToAccountInformation.perform(
                .anyToNoAuthRekeyedAccountInformation(account: sourceAccount),
                by: .presentWithoutNavigationController
            )
            return
        }

        transitionToAccountInformation.perform(
            .noAuthAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountInformationFlowCoordinator {
    private func openRekeyToStandardAccount(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
        }
    }

    private func openRekeyToLedgerAccount(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
        }
    }

    private func openUndoRekey(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            undoRekeyFlowCoordinator.launch(sourceAccount)
        }
    }
}
