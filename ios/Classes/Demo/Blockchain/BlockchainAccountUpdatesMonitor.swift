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

//   BlockchainAccountUpdatesMonitor.swift

import Foundation

struct BlockchainAccountUpdatesMonitor {
    let accountAddress: String

    private var optInUpdates: [AssetID: OptInBlockchainUpdate] = [:]
    private var optOutUpdates: [AssetID: OptOutBlockchainUpdate] = [:]
    private var sentPureCollectibleAssetUpdates: [AssetID: SendPureCollectibleAssetBlockchainUpdate] = [:]

    init(accountAddress: String) {
        self.accountAddress = accountAddress
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasMonitoringUpdates() -> Bool {
        return !optInUpdates.isEmpty || !optOutUpdates.isEmpty || !sentPureCollectibleAssetUpdates.isEmpty
    }
}

extension BlockchainAccountUpdatesMonitor {
    func filterPendingOptInAssetUpdates() -> [AssetID : OptInBlockchainUpdate] {
        return optInUpdates.filter { $0.value.status == .pending }
    }

    func filterOptedInAssetUpdatesForNotification() -> [AssetID : OptInBlockchainUpdate] {
        return optInUpdates.filter { $0.value.status == .waitingForNotification }
    }

    func filterOptedInAssetUpdates() -> [AssetID : OptInBlockchainUpdate] {
        return optInUpdates.filter { $0.value.status != .pending }
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasAnyPendingOptInRequest() -> Bool {
        return optInUpdates.contains { $0.value.status == .pending }
    }

    func hasPendingOptInRequest(assetID: AssetID) -> Bool {
        let update = optInUpdates[assetID]
        return update?.status == .pending
    }

    mutating func startMonitoringOptInUpdates(_ request: OptInBlockchainRequest) {
        let update = OptInBlockchainUpdate(request: request)
        optInUpdates[update.assetID] = update
    }

    mutating func markOptInUpdatesForNotification(forAssetID assetID: AssetID) {
        guard let pendingUpdate = optInUpdates[assetID] else { return }

        let waitingUpdate = OptInBlockchainUpdate(
            update: pendingUpdate,
            status: .waitingForNotification
        )
        optInUpdates[assetID] = waitingUpdate
    }

    mutating func stopMonitoringOptInUpdates(forAssetID assetID: AssetID) {
        guard let waitingUpdate = optInUpdates[assetID] else { return }

        let completedUpdate = OptInBlockchainUpdate(
            update: waitingUpdate,
            status: .completed
        )
        optInUpdates[assetID] = completedUpdate
    }

    mutating func cancelMonitoringOptInUpdates(forAssetID assetID: AssetID) {
        optInUpdates[assetID] = nil
    }
}

extension BlockchainAccountUpdatesMonitor {
    func filterPendingOptOutAssetUpdates() -> [AssetID: OptOutBlockchainUpdate] {
        return optOutUpdates.filter { $0.value.status == .pending }
    }

    func filterOptedOutAssetUpdatesForNotification() -> [AssetID : OptOutBlockchainUpdate] {
        return optOutUpdates.filter { $0.value.status == .waitingForNotification }
    }

    func filterOptedOutAssetUpdates() -> [AssetID: OptOutBlockchainUpdate] {
        return optOutUpdates.filter { $0.value.status != .pending }
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasAnyPendingOptOutRequest() -> Bool {
        return optOutUpdates.contains { $0.value.status == .pending }
    }

    func hasPendingOptOutRequest(assetID: AssetID) -> Bool {
        let update = optOutUpdates[assetID]
        return update?.status == .pending
    }

    mutating func startMonitoringOptOutUpdates(_ request: OptOutBlockchainRequest) {
        let update = OptOutBlockchainUpdate(request: request)
        optOutUpdates[update.assetID] = update
    }

    mutating func markOptOutUpdatesForNotification(forAssetID assetID: AssetID) {
        guard let pendingUpdate = optOutUpdates[assetID] else { return }

        let waitingUpdate = OptOutBlockchainUpdate(
            update: pendingUpdate,
            status: .waitingForNotification
        )
        optOutUpdates[assetID] = waitingUpdate
    }

    mutating func stopMonitoringOptOutUpdates(forAssetID assetID: AssetID) {
        guard let waitingUpdate = optOutUpdates[assetID] else { return }

        let completedUpdate = OptOutBlockchainUpdate(
            update: waitingUpdate,
            status: .completed
        )
        optOutUpdates[assetID] = completedUpdate
    }

    mutating func cancelMonitoringOptOutUpdates(forAssetID assetID: AssetID) {
        optOutUpdates[assetID] = nil
    }
}

extension BlockchainAccountUpdatesMonitor {
    func filterPendingSendPureCollectibleAssetUpdates() -> [AssetID: SendPureCollectibleAssetBlockchainUpdate] {
        return sentPureCollectibleAssetUpdates.filter { $0.value.status == .pending }
    }

    func filterSentPureCollectibleAssetUpdatesForNotification() -> [AssetID : SendPureCollectibleAssetBlockchainUpdate] {
        return sentPureCollectibleAssetUpdates.filter { $0.value.status == .waitingForNotification }
    }

    func filterSentPureCollectibleAssetUpdates() -> [AssetID: SendPureCollectibleAssetBlockchainUpdate] {
        return sentPureCollectibleAssetUpdates.filter { $0.value.status != .pending }
    }
}

extension BlockchainAccountUpdatesMonitor {
    func hasPendingSendPureCollectibleAssetRequest(assetID: AssetID) -> Bool {
        let update = sentPureCollectibleAssetUpdates[assetID]
        return update?.status == .pending
    }

    mutating func startMonitoringSendPureCollectibleAssetUpdates(_ request: SendPureCollectibleAssetBlockchainRequest) {
        let update = SendPureCollectibleAssetBlockchainUpdate(request: request)
        sentPureCollectibleAssetUpdates[update.assetID] = update
    }

    mutating func markSendPureCollectibleAssetUpdatesForNotification(forAssetID assetID: AssetID) {
        guard let pendingUpdate = sentPureCollectibleAssetUpdates[assetID] else { return }

        let waitingUpdate = SendPureCollectibleAssetBlockchainUpdate(
            update: pendingUpdate,
            status: .waitingForNotification
        )
        sentPureCollectibleAssetUpdates[assetID] = waitingUpdate
    }

    mutating func stopMonitoringSendPureCollectibleAssetUpdates(forAssetID assetID: AssetID) {
        guard let waitingUpdate = sentPureCollectibleAssetUpdates[assetID] else { return }

        let completedUpdate = SendPureCollectibleAssetBlockchainUpdate(
            update: waitingUpdate,
            status: .completed
        )
        sentPureCollectibleAssetUpdates[assetID] = completedUpdate
    }

    mutating func cancelMonitoringSendPureCollectibleAssetUpdates(forAssetID assetID: AssetID) {
        sentPureCollectibleAssetUpdates[assetID] = nil
    }
}

extension BlockchainAccountUpdatesMonitor {
    mutating func removeCompletedUpdates() {
        optInUpdates = optInUpdates.filter { $0.value.status != .completed }
        optOutUpdates = optOutUpdates.filter { $0.value.status != .completed }
        sentPureCollectibleAssetUpdates = sentPureCollectibleAssetUpdates.filter { $0.value.status != .completed }
    }
}

extension BlockchainAccountUpdatesMonitor {
    func makeBatchRequest() -> BlockchainAccountBatchRequest {
        var pendingOptInUpdates: [AssetID : Any] = [:]
        for update in optInUpdates where update.value.status == .pending {
            pendingOptInUpdates[update.key] = true
        }

        var pendingOptOutUpdates: [AssetID : Any] = [:]
        for update in optOutUpdates where update.value.status == .pending {
            pendingOptOutUpdates[update.key] = true
        }

        var pendingSendPureColllectibleAssetUpdates: [AssetID : Any] = [:]
        for update in sentPureCollectibleAssetUpdates where update.value.status == .pending {
            pendingSendPureColllectibleAssetUpdates[update.key] = true
        }

        var batchRequest = BlockchainAccountBatchRequest()
        batchRequest.optInAssets = pendingOptInUpdates
        batchRequest.optOutAssets = pendingOptOutUpdates
        batchRequest.sendPureCollectibleAssets = pendingSendPureColllectibleAssetUpdates
        return batchRequest
    }
}
