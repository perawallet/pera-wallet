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

//   AccountImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils


final class AccountImportFlowCoordinator {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private unowned let presentingScreen: UIViewController

    init(presentingScreen: UIViewController) {
        self.presentingScreen = presentingScreen
    }
}

extension AccountImportFlowCoordinator {
    func launch(qrBackupParameters: QRBackupParameters?) {
        guard let qrBackupParameters else {
            continueIntroductionScreen()
            return
        }

        continueToImportAccountAfterLaunch(parameters: qrBackupParameters, from: presentingScreen)
    }

    private func continueIntroductionScreen() {
        let introductionScreen = Screen.importAccountIntroduction { [weak self] event, introductionScreen in
            guard let self else {
                return
            }

            switch event {
            case .didStart:
                self.continueQRScannerScreen(from: introductionScreen)
            }
        }
        presentingScreen.open(introductionScreen, by: .push)
    }

    private func continueToImportAccountAfterLaunch(
        parameters: QRBackupParameters,
        from sourceScreen: UIViewController
    ) {
        let importAccountScreen = makeImportAccountScreen(with: parameters)
        sourceScreen.open(importAccountScreen, by: .present)
    }

    private func continueToImportAccountAfterQR(
        parameters: QRBackupParameters,
        from sourceScreen: UIViewController
    ) {
        let importAccountScreen = makeImportAccountScreen(with: parameters)
        sourceScreen.open(importAccountScreen, by: .push)
    }

    private func continueQRScannerScreen(from screen: UIViewController) {
        let qrScannerScreen = Screen.importAccountQRScanner { [weak self] event, qrScannerScreen in
            guard let self else {
                return
            }

            switch event {
            case .didReadBackup(let parameters):
                if !parameters.isSupported() {
                    self.continueErrorScreen(error: .unsupportedVersion(version: parameters.version), from: qrScannerScreen)
                } else {
                    self.continueToImportAccountAfterQR(parameters: parameters, from: qrScannerScreen)
                }

            case .didReadUnsupportedAction(let parameters):
                if !parameters.isSupported() {
                    self.continueErrorScreen(error: .unsupportedVersion(version: parameters.version), from: qrScannerScreen)
                } else {
                    self.continueErrorScreen(error: .unsupportedAction, from: qrScannerScreen)
                }
            }
        }
        screen.open(qrScannerScreen, by: .push)
    }

    private func continueSuccessScreen(
        result: ImportAccountScreen.Result,
        from screen: UIViewController
    ) {
        let successScreen = Screen.importAccountSuccess(
            result: result
        ) { [weak self] event, successScreen in
            guard let self else {
                return
            }

            switch event {
            case .didGoToHome:
                self.finish(from: successScreen)
            }
        }

        screen.open(successScreen, by: .push)
    }

    private func continueErrorScreen(
        error: ImportAccountScreenError,
        from screen: UIViewController
    ) {
        let errorScreen = Screen.importAccountError(error) { [weak self] event, errorScreen in
            guard let self else {
                return
            }

            self.finish(from: errorScreen)
        }

        screen.open(errorScreen, by: .push)
    }

    private func finish(from screen: UIViewController) {
        screen.dismiss(animated: true)
        eventHandler?(.didFinish)
    }
}

extension AccountImportFlowCoordinator {
    private func makeImportAccountScreen(with parameters: QRBackupParameters) -> Screen {
        Screen.importAccount(parameters) { [weak self] event, importAccountScreen in
            guard let self else {
                return
            }

            switch event {
            case let .didCompleteImport(result):
                let importedAccounts = result.importedAccounts
                
                if importedAccounts.isEmpty {
                    self.continueErrorScreen(error: .notImportableAccountFound, from: importAccountScreen)
                    return
                }

                self.continueSuccessScreen(
                    result: result,
                    from: importAccountScreen
                )
            case .didFailToImport(let error):
                self.continueErrorScreen(error: error, from: importAccountScreen)
            }
        }
    }
}

extension AccountImportFlowCoordinator {
    enum Event {
        case didFinish
    }
}
