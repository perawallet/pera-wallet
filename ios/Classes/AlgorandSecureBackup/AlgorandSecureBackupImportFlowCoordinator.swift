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

//   AlgorandSecureBackupImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class AlgorandSecureBackupImportFlowCoordinator {
    private unowned let presentingScreen: UIViewController

    init(presentingScreen: UIViewController) {
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    func launch() {
        openImportBackup()
    }

    private func openImportBackup() {
        let screen: Screen = .algorandSecureBackupImportBackup { [weak self] event, screen in
            guard let self else { return }
            switch event {
            case .backupSelected(let file):
                self.openImportMnemonic(with: file, from: screen)
            }
        }
        presentingScreen.open(screen, by: .push)
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    private func openImportMnemonic(with backup: SecureBackup, from viewController: UIViewController) {
        let screen: Screen = .algorandSecureBackupRecoverMnemonic(backup: backup) { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .decryptedBackup(let backupParameters):
                self.openRestoreAccountListScreen(with: backupParameters.accounts, from: screen)
            }
        }

        viewController.open(screen, by: .push)
    }

    private func openSuccessScreen(
        accountImportParameters: [AccountImportParameters],
        selectedAccounts: [Account],
        from viewController: UIViewController
    ) {
        let screen: Screen = .algorandSecureBackupImportSuccess(
            accountImportParameters: accountImportParameters,
            selectedAccounts: selectedAccounts
        ) { event, screen in
            switch event {
            case .didGoToHome:
                asyncMain {
                    AppDelegate.shared?.launchMain()
                }
            }
        }

        viewController.open(screen, by: .push)
    }

    private func openRestoreAccountListScreen(
        with importedAccounts: [AccountImportParameters],
        from viewController: UIViewController
    ) {
        let screen: Screen = .algorandSecureBackupRestoreAccountList(
            accountImportParameters: importedAccounts
        ) { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .performContinue(let accounts):
                self.openSuccessScreen(
                    accountImportParameters: importedAccounts,
                    selectedAccounts: accounts,
                    from: screen
                )
            }
        }

        viewController.open(screen, by: .push)
    }
}
