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

//
//   SharedDataController.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo
import MagpieExceptions

protocol SharedDataController: AnyObject {
    var assetDetailCollection: AssetDetailCollection { get set }
    /// <todo>
    /// There is no need to define selected sorting algorithms as optional because they are not.
    var selectedAccountSortingAlgorithm: AccountSortingAlgorithm? { get set }
    var accountSortingAlgorithms: [AccountSortingAlgorithm] { get }

    var selectedAccountAssetSortingAlgorithm: AccountAssetSortingAlgorithm? { get set }
    var accountAssetSortingAlgorithms: [AccountAssetSortingAlgorithm] { get }
    var selectedCollectibleSortingAlgorithm: CollectibleSortingAlgorithm? { get set }
    var collectibleSortingAlgorithms: [CollectibleSortingAlgorithm] { get }

    var accountCollection: AccountCollection { get }

    var currency: CurrencyProvider { get }

    var blockchainUpdatesMonitor: BlockchainUpdatesMonitor { get }
    
    /// <note>
    /// Returns true if the shared data is ready to use.
    var isAvailable: Bool { get }
    
    /// <note>
    /// Returns true if there is any local account.
    var isPollingAvailable: Bool { get }
    
    func startPolling()
    func stopPolling()
    func resetPolling()
    func resetPollingAfterRemoving(
        _ account: Account
    )
    func resetPollingAfterPreferredCurrencyWasChanged()

    func getPreferredOrderForNewAccount() -> Int

    func hasOptedIn(
        assetID: AssetID,
        for account: Account
    ) -> OptInStatus
    func hasOptedOut(
        assetID: AssetID,
        for account: Account
    ) -> OptOutStatus
    
    func add(
        _ observer: SharedDataControllerObserver
    )
    func remove(
        _ observer: SharedDataControllerObserver
    )
    func getTransactionParams(
        isCacheEnabled: Bool,
        _ handler: @escaping (Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void
    )
    func getTransactionParams(
        _ handler: @escaping (Result<TransactionParams, HIPNetworkError<NoAPIModel>>) -> Void
    )
    
    func rekeyedAccounts(
        of account: Account
    ) -> [AccountHandle]
    func authAccount(
        of account: Account
    ) -> AccountHandle?

    func determineAccountAuthorization(
        of account: Account
    ) -> AccountAuthorization
}

extension SharedDataController {
    func sortedAccounts() -> [AccountHandle] {
        if let selectedAccountSortingAlgorithm = selectedAccountSortingAlgorithm {
            return accountCollection.sorted(selectedAccountSortingAlgorithm)
        }

        /// <todo>
        /// We should convert it to keep the order from the local accounts.
        return accountCollection.sorted {
            $0.value.address > $1.value.address
        }
    }
}

/// <todo>
/// Can this approach move to 'Macaroon' library???
///
/// <note>
/// Observers will be notified on the main thread.
protocol SharedDataControllerObserver: AnyObject {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    )
}

enum SharedDataControllerEvent {
    case didBecomeIdle
    case didStartRunning(first: Bool)
    case didFinishRunning
}

enum OptInStatus {
    case pending
    case optedIn
    case rejected
}

enum OptOutStatus {
    case pending
    case optedOut
    case rejected
}
