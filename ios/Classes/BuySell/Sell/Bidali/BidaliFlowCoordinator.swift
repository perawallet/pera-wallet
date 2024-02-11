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

//   BidaliFlowCoordinator.swift

import Foundation
import UIKit

final class BidaliFlowCoordinator {
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

extension BidaliFlowCoordinator {
    /// When an account is not passed to the function, the account selection flow is triggered within the overall flow.
    func launch(_ account: AccountHandle? = nil) {
        openIntroduction(account)
    }
}

extension BidaliFlowCoordinator {
    private func openIntroduction(_ account: AccountHandle? = nil) {
        let screen = presentingScreen.open(
            .bidaliIntroduction,
            by: .present
        ) as? BidaliIntroductionScreen
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

extension BidaliFlowCoordinator {
    private func openAccountSelection(from screen: UIViewController) {
        let accountSelectionScreen = Screen.bidaliAccountSelection {
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

extension BidaliFlowCoordinator {
    private func openDappDetail(
        with account: AccountHandle,
        from screen: UIViewController
    ) {
        let dAppDetail = screen.open(
            .bidaliDappDetail(account: account),
            by: .push
        ) as? BidaliDappDetailScreen
        dAppDetail?.eventHandler = { 
            [weak dAppDetail] event in
            switch event {
            case .goBack:
                dAppDetail?.dismiss(animated: true)
            default: break
            }
        }
    }
}

extension BidaliFlowCoordinator {
    /// <note>
    /// In staging app, the Bidali is always enabled, but in store app, it is enabled only
    /// on mainnet.
    private var isAvailable: Bool {
        return !ALGAppTarget.current.isProduction || !api.isTestNet
    }

    private func presentNotAvailableAlert(on screen: UIViewController) {
        screen.displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "bidali-not-available-description".localized
        )
    }
}
