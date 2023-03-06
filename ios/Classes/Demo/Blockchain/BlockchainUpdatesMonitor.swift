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

//   BlockchainUpdatesMonitor.swift

import Foundation
import MacaroonUtils

struct BlockchainUpdatesMonitor: Printable {
    typealias AccountAddress = String

    var debugDescription: String {
        return table.debugDescription
    }

    private typealias Table = [AccountAddress: BlockchainAccountUpdatesMonitor]

    @Atomic(identifier: "blockchainMonitor.table")
    private var table: Table = [:]
}

extension BlockchainUpdatesMonitor {
    func filterPendingOptInAssetUpdates() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterPendingOptInAssetUpdates().values
        }
    }

    func filterPendingOptInAssetUpdates(for account: Account) -> [AssetID : OptInBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingOptInAssetUpdates() ?? [:]
    }

    func filterOptedInAssetUpdates() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterOptedInAssetUpdates().values
        }
    }

    func filterOptedInAssetUpdatesForNotification() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterOptedInAssetUpdatesForNotification().values
        }
    }

    func filterOptedInAssetUpdates(for account: Account) -> [AssetID : OptInBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterOptedInAssetUpdates() ?? [:]
    }
}

extension BlockchainUpdatesMonitor {
    func hasAnyPendingOptInRequest(for account: Account) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasAnyPendingOptInRequest() ?? false
    }

    func hasPendingOptInRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingOptInRequest(assetID: assetID) ?? false
    }

    func startMonitoringOptInUpdates(_ request: OptInBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringOptInUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    func markOptInUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markOptInUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func stopMonitoringOptInUpdates(associatedWith update: OptInBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptInUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    func cancelMonitoringOptInUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.cancelMonitoringOptInUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    func filterPendingOptOutAssetUpdates() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterPendingOptOutAssetUpdates().values
        }
    }

    func filterPendingOptOutAssetUpdates(for account: Account) -> [AssetID : OptOutBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingOptOutAssetUpdates() ?? [:]
    }

    func filterOptedOutAssetUpdates() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterOptedOutAssetUpdates().values
        }
    }

    func filterOptedOutAssetUpdatesForNotification() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterOptedOutAssetUpdatesForNotification().values
        }
    }

    func filterOptedOutAssetUpdates(for account: Account) -> [AssetID: OptOutBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterOptedOutAssetUpdates() ?? [:]
    }
}

extension BlockchainUpdatesMonitor {
    func hasAnyPendingOptOutRequest(for account: Account) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasAnyPendingOptOutRequest() ?? false
    }

    func hasPendingOptOutRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingOptOutRequest(assetID: assetID) ?? false
    }

    func startMonitoringOptOutUpdates(_ request: OptOutBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringOptOutUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    func markOptOutUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markOptOutUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func stopMonitoringOptOutUpdates(associatedWith update: OptOutBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptOutUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    func cancelMonitoringOptOutUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.cancelMonitoringOptOutUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    /// <todo>
    /// We may change the naming to pending send to pending transfer. It fits better.
    func filterPendingSendPureCollectibleAssetUpdates() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterPendingSendPureCollectibleAssetUpdates().values
        }
    }

    func filterPendingSendPureCollectibleAssetUpdates(for account: Account) -> [AssetID : SendPureCollectibleAssetBlockchainUpdate] {
        let address = account.address
        let monitor = table[address]
        return monitor?.filterPendingSendPureCollectibleAssetUpdates() ?? [:]
    }

    func filterSentPureCollectibleAssetUpdates() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterSentPureCollectibleAssetUpdates().values
        }
    }

    func filterSentPureCollectibleAssetUpdatesForNotification() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterSentPureCollectibleAssetUpdatesForNotification().values
        }
    }
}

extension BlockchainUpdatesMonitor {
    func hasPendingSendPureCollectibleAssetRequest(
        assetID: AssetID,
        for account: Account
    ) -> Bool {
        let address = account.address
        let monitor = table[address]
        return monitor?.hasPendingSendPureCollectibleAssetRequest(assetID: assetID) ?? false
    }

    func startMonitoringSendPureCollectibleAssetUpdates(_ request: SendPureCollectibleAssetBlockchainRequest) {
        let address = request.accountAddress

        var monitor = table[address] ?? .init(accountAddress: address)
        monitor.startMonitoringSendPureCollectibleAssetUpdates(request)

        $table.mutate { $0[address] = monitor }
    }

    func markSendPureCollectibleAssetUpdatesForNotification(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markSendPureCollectibleAssetUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func stopMonitoringSendPureCollectibleAssetUpdates(associatedWith update: SendPureCollectibleAssetBlockchainUpdate) {
        let address = update.accountAddress

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringSendPureCollectibleAssetUpdates(forAssetID: update.assetID)

        $table.mutate { $0[address] = monitor }
    }

    private func cancelMonitoringSendPureCollectibleAssetUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.markSendPureCollectibleAssetUpdatesForNotification(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    func removeCompletedUpdates() {
        $table.mutate {
            var newTable: Table = [:]
            for (address, monitor) in $0 {
                var mMonitor = monitor
                mMonitor.removeCompletedUpdates()

                if mMonitor.hasMonitoringUpdates() {
                    newTable[address] = mMonitor
                }
            }

            $0 = newTable
        }
    }
}

extension BlockchainUpdatesMonitor {
    func makeBatchRequest() -> BlockchainBatchRequest {
        return table.mapValues { $0.makeBatchRequest() }
    }
}
