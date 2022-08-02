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

//   SendTransactionCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class SendTransactionFlowCoordinator: SelectAccountViewControllerDelegate {
    private unowned let presentingScreen: UIViewController
    private let sharedDataController: SharedDataController
    private var account: Account?

    init(
        presentingScreen: UIViewController,
        sharedDataController: SharedDataController,
        account: Account? = nil
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
        self.account = account

        guard account != nil else {
            return
        }

        sharedDataController.add(self)
    }


    deinit {
        sharedDataController.remove(self)
    }
}

extension SendTransactionFlowCoordinator {
    func launch() {
        guard let account = account else {
            openAccountSelection()
            return
        }

        openAssetSelection(with: account)
    }

    private func openAccountSelection() {
        let draft = SelectAccountDraft(
            transactionAction: .send,
            requiresAssetSelection: true
        )

        presentingScreen.open(
            .accountSelection(draft: draft, delegate: self),
            by: .present
        )
    }

    private func openAssetSelection(with account: Account, on screen: UIViewController? = nil) {
        let assetSelectionScreen: Screen = .assetSelection(
            filter: nil,
            account: account
        )

        guard let screen = screen else {
            presentingScreen.open(
                assetSelectionScreen,
                by: .present
            )
            return
        }

        screen.open(
            assetSelectionScreen,
            by: .push
        )
    }
}

/// <mark>
/// SelectAccountViewControllerDelegate
extension SendTransactionFlowCoordinator {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        if draft.transactionAction != .send {
            return
        }

        openAssetSelection(with: account, on: selectAccountViewController)
    }
}

/// <mark>
/// SharedDataController
extension SendTransactionFlowCoordinator: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            guard let address = account?.address else {
                return
            }

            if let updatedAccountHandle = sharedDataController.accountCollection[address] {
                self.account = updatedAccountHandle.value
            }
        default:
            break
        }
    }
}
