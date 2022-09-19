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
    private var account: Account?
    private var asset: Asset?

    private unowned let presentingScreen: UIViewController

    private let sharedDataController: SharedDataController

    init(
        presentingScreen: UIViewController,
        sharedDataController: SharedDataController,
        account: Account? = nil,
        asset: Asset? = nil
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
        self.account = account
        self.asset = asset

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
            navigateToSelectAccount()
            return
        }

        guard let asset = asset else {
            navigateToSelectAsset(account: account)
            return
        }

        navigateToSendTransaction(
            account: account,
            asset: asset
        )
    }

    private func navigateToSelectAccount() {
        let draft = SelectAccountDraft(
            transactionAction: .send,
            requiresAssetSelection: true
        )

        presentingScreen.open(
            .accountSelection(draft: draft, delegate: self),
            by: .present
        )
    }

    private func navigateToSelectAsset(
        account: Account,
        on screen: UIViewController? = nil
    ) {
        let assetSelectionScreen: Screen = .assetSelection(account: account)

        if let screen = screen {
            screen.open(
                assetSelectionScreen,
                by: .push
            )
        } else {
            presentingScreen.open(
                assetSelectionScreen,
                by: .present
            )
        }
    }

    private func navigateToSendTransaction(
        account: Account,
        asset: Asset,
        on screen: UIViewController? = nil
    ) {
        let draft: SendTransactionDraft
        if asset.isAlgo {
            draft = SendTransactionDraft(from: account, transactionMode: .algo)
        } else {
            draft = SendTransactionDraft(from: account, transactionMode: .asset(asset))
        }

        let sendTransactionScreen = Screen.sendTransaction(draft: draft)

        if let screen = screen {
            screen.open(
                sendTransactionScreen,
                by: .push
            )
        } else {
            presentingScreen.open(
                sendTransactionScreen,
                by: .present
            )
        }
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

        navigateToSelectAsset(
            account: account,
            on: selectAccountViewController
        )
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
                let updatedAccount = updatedAccountHandle.value
                self.account = updatedAccount

                self.updateAssetIfNeeded(updatedAccount, on: sharedDataController)
            }
        default:
            break
        }
    }

    private func updateAssetIfNeeded(_ account: Account, on sharedDataController: SharedDataController) {
        guard let asset = asset, let newAsset = account[asset.id] else {
            return
        }

        guard isAssetUpdated(newAsset),
              let assetDetail = sharedDataController.assetDetailCollection[asset.id] else {
            return
        }

        let algAsset = ALGAsset(asset: newAsset)
        self.asset = StandardAsset(asset: algAsset, decoration: assetDetail)
    }

    private func isAssetUpdated(_ newAsset: Asset) -> Bool {
        guard let asset = asset else {
            return false
        }

        return asset.decimalAmount != newAsset.decimalAmount ||
            asset.usdValue != newAsset.usdValue
    }
}
