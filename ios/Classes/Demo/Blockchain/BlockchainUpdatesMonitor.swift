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
    func filterOptedInAssetUpdates() -> [OptInBlockchainUpdate] {
        return table.reduce(into: [OptInBlockchainUpdate]()) {
            $0 += $1.value.filterOptedInAssetUpdates().values
        }
    }

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

    func stopMonitoringOptInUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptInUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func finishMonitoringOptInUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        finishMonitoringOptInUpdates(
            forAssetID: assetID,
            forAccountAddress: account.address
        )
    }

    func finishMonitoringOptInUpdates(associatedWith update: OptInBlockchainUpdate) {
        finishMonitoringOptInUpdates(
            forAssetID: update.assetID,
            forAccountAddress: update.accountAddress
        )
    }

    private func finishMonitoringOptInUpdates(
        forAssetID assetID: AssetID,
        forAccountAddress address: String
    ) {
        guard var monitor = table[address] else { return }

        monitor.finishMonitoringOptInUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    func filterOptedOutAssetUpdates() -> [OptOutBlockchainUpdate] {
        return table.reduce(into: [OptOutBlockchainUpdate]()) {
            $0 += $1.value.filterOptedOutAssetUpdates().values
        }
    }

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

    func stopMonitoringOptOutUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringOptOutUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func finishMonitoringOptOutUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        finishMonitoringOptOutUpdates(
            forAssetID: assetID,
            forAccountAddress: account.address
        )
    }

    func finishMonitoringOptOutUpdates(associatedWith update: OptOutBlockchainUpdate) {
        finishMonitoringOptOutUpdates(
            forAssetID: update.assetID,
            forAccountAddress: update.accountAddress
        )
    }

    private func finishMonitoringOptOutUpdates(
        forAssetID assetID: AssetID,
        forAccountAddress address: String
    ) {
        guard var monitor = table[address] else { return }

        monitor.finishMonitoringOptOutUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    func filterSentPureCollectibleAssetUpdates() -> [SendPureCollectibleAssetBlockchainUpdate] {
        return table.reduce(into: [SendPureCollectibleAssetBlockchainUpdate]()) {
            $0 += $1.value.filterSentPureCollectibleAssetUpdates().values
        }
    }

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

    func stopMonitoringSendPureCollectibleAssetUpdates(
        forAssetID assetID: AssetID,
        for account: Account
    ) {
        let address = account.address

        guard var monitor = table[address] else { return }

        monitor.stopMonitoringSendPureCollectibleAssetUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }

    func finishMonitoringSendPureCollectibleAssetUpdates(associatedWith update: SendPureCollectibleAssetBlockchainUpdate) {
        finishMonitoringSendPureCollectibleAssetUpdates(
            forAssetID: update.assetID,
            forAccountAddress: update.accountAddress
        )
    }

    private func finishMonitoringSendPureCollectibleAssetUpdates(
        forAssetID assetID: AssetID,
        forAccountAddress address: String
    ) {
        guard var monitor = table[address] else { return }

        monitor.stopMonitoringSendPureCollectibleAssetUpdates(forAssetID: assetID)

        $table.mutate { $0[address] = monitor }
    }
}

extension BlockchainUpdatesMonitor {
    func removeUnmonitoredUpdates() {
        $table.mutate {
            var newTable: Table = [:]
            for (address, monitor) in $0 {
                var mMonitor = monitor
                mMonitor.removeUnmonitoredUpdates()

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
