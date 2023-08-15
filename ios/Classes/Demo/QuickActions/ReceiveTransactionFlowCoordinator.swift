// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ReceiveTransactionQuickActionCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class ReceiveTransactionFlowCoordinator: SelectAccountViewControllerDelegate {
    private unowned let presentingScreen: UIViewController

    init(presentingScreen: UIViewController) {
        self.presentingScreen = presentingScreen
    }
}

extension ReceiveTransactionFlowCoordinator {
    func launch(_ account: Account? = nil) {
        guard let account = account else {
            openAccountSelection()
            return
        }

        openQRGenerator(with: account)
    }

    private func openAccountSelection() {
        let draft = SelectAccountDraft(
            transactionAction: .receive,
            requiresAssetSelection: false
        )

        presentingScreen.open(
            .accountSelection(draft: draft, delegate: self),
            by: .present
        )
    }

    private func openQRGenerator(with account: Account, on screen: UIViewController? = nil) {
        let accountName = account.primaryDisplayName
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: accountName
        )
        let qrGeneratorScreen: Screen = .qrGenerator(
            title: accountName,
            draft: draft,
            isTrackable: true
        )

        guard let screen = screen else {
            presentingScreen.open(
                qrGeneratorScreen,
                by: .present
            )
            return
        }

        screen.open(
            qrGeneratorScreen,
            by: .push
        )
    }
}

/// <mark>
/// SelectAccountViewControllerDelegate
extension ReceiveTransactionFlowCoordinator {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        if draft.transactionAction != .receive {
            return
        }

        openQRGenerator(with: account, on: selectAccountViewController)
    }
}
