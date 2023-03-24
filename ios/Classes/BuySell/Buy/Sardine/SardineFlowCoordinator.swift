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

//   SardineFlowCoordinator.swift

import Foundation
import UIKit

final class SardineFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private let api: ALGAPI

    init(
        presentingScreen: UIViewController,
        api: ALGAPI
    ) {
        self.presentingScreen = presentingScreen
        self.api =  api
    }
}

extension SardineFlowCoordinator {
    /// When an account is not passed to the function, the account selection flow is triggered within the overall flow.
    func launch(_ account: AccountHandle? = nil) {
        openIntroduction(account)
    }
}

extension SardineFlowCoordinator {
    private func openIntroduction(_ account: AccountHandle? = nil) {
        let screen = presentingScreen.open(
            .sardineIntroduction,
            by: .present
        ) as? SardineIntroductionScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else { return }

            switch event {
            case .performCloseAction:
                self.presentingScreen.dismiss(animated: true)
            case .performPrimaryAction:
                guard self.isAvailable else {
                    self.presentNotAvailableAlert(on: screen)
                    return
                }

                if let account {
                    self.openDappDetail(
                        with: account,
                        from: screen
                    )
                    return
                }

                self.openAccountSelection(from: screen)
            }
        }
    }
}

extension SardineFlowCoordinator {
    private func openAccountSelection(from screen: UIViewController) {
        let accountSelectionScreen = Screen.sardineAccountSelection {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let account):
                self.openDappDetail(
                    with: account,
                    from: screen
                )
            default: break
            }
        }

        screen.open(
            accountSelectionScreen,
            by: .push
        )
    }
}

extension SardineFlowCoordinator {
    private func openDappDetail(
        with account: AccountHandle,
        from screen: UIViewController
    ) {
        screen.open(
            .sardineDappDetail(account: account),
            by: .push
        )
    }
}

extension SardineFlowCoordinator {
    /// <note>
    /// In staging app, the Sardine is always enabled, but in store app, it is enabled only
    /// on mainnet.
    private var isAvailable: Bool {
        return !ALGAppTarget.current.isProduction || !api.isTestNet
    }

    private func presentNotAvailableAlert(on screen: UIViewController) {
        screen.displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "sardine-not-available-description".localized
        )
    }
}
