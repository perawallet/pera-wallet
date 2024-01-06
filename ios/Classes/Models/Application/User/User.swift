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
//  User.swift

import UIKit

final class User: Codable {
    private(set) var accounts: [AccountInformation] = []
    private(set) var defaultNode: String?

    private var deviceIDOnMainnet: String?
    private var deviceIDOnTestnet: String?
    
    private enum CodingKeys:
        String,
        CodingKey {
        case accounts
        case defaultNode
        case legacyDeviceID = "deviceId"
        case deviceIDOnMainnet
        case deviceIDOnTestnet
    }
    init() {}

    init(
        accounts: [AccountInformation]
    ) {
        self.accounts = accounts
    }
    
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accounts = try container.decodeIfPresent([AccountInformation].self, forKey: .accounts) ?? []
        
        let defaultNode = try container.decodeIfPresent(String.self, forKey: .defaultNode)
        self.defaultNode = defaultNode
        
        let legacyDeviceID = try container.decodeIfPresent(String.self, forKey: .legacyDeviceID)
        let network = User.makeNetwork(from: defaultNode)
        
        if let deviceID = try container.decodeIfPresent(String.self, forKey: .deviceIDOnMainnet) {
            self.deviceIDOnMainnet = deviceID
        } else if network == .mainnet {
            self.deviceIDOnMainnet = legacyDeviceID
        }
        
        if let deviceID = try container.decodeIfPresent(String.self, forKey: .deviceIDOnTestnet) {
            self.deviceIDOnTestnet = deviceID
        } else if network == .testnet {
            self.deviceIDOnTestnet = legacyDeviceID
        }
    }
    
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encodeIfPresent(defaultNode, forKey: .defaultNode)
        try container.encodeIfPresent(deviceIDOnMainnet, forKey: .deviceIDOnMainnet)
        try container.encodeIfPresent(deviceIDOnTestnet, forKey: .deviceIDOnTestnet)
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension User {
    var hasReachedTotalAccountLimit: Bool {
        let limit = 50
        return accounts.count == limit
    }
}

extension User {
    func addAccount(_ account: AccountInformation) {
        accounts.append(account)
        syncronize()
    }

    func addAccounts(_ accounts: [AccountInformation]) {
        self.accounts.append(contentsOf: accounts)
        syncronize()
    }
    
    func removeAccount(_ account: AccountInformation) {
        guard let index = index(of: account) else {
            return
        }
        
        removeBackup(from: account.address)
        accounts.remove(at: index)
        syncronize()
    }
    
    func index(of account: AccountInformation) -> Int? {
        guard let index = accounts.firstIndex(of: account) else {
            return nil
        }
        
        return index
    }
    
    func account(at index: Int) -> AccountInformation? {
        guard index < accounts.count else {
            return nil
        }
        
        return accounts[index]
    }
    
    func updateAccount(_ account: AccountInformation) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts[index].updateName(account.name)
        accounts[index].isWatchAccount = account.isWatchAccount
        accounts[index].ledgerDetail = account.ledgerDetail
        accounts[index].receivesNotification = account.receivesNotification
        accounts[index].rekeyDetail = account.rekeyDetail
        accounts[index].preferredOrder = account.preferredOrder
        accounts[index].isBackedUp = account.isBackedUp
        
        syncronize()
    }

    func updateLocalAccount(
        _ updatedAccount: Account,
        syncChangesImmediately: Bool = true
    ) {
        guard let localAccountIndex = indexOfAccount(updatedAccount.address) else {
            return
        }

        accounts[localAccountIndex].updateName(updatedAccount.name ?? "")
        accounts[localAccountIndex].isWatchAccount = updatedAccount.isWatchAccount
        accounts[localAccountIndex].ledgerDetail = updatedAccount.ledgerDetail
        accounts[localAccountIndex].receivesNotification = updatedAccount.receivesNotification
        accounts[localAccountIndex].rekeyDetail = updatedAccount.rekeyDetail
        accounts[localAccountIndex].preferredOrder = updatedAccount.preferredOrder
        accounts[localAccountIndex].isBackedUp = updatedAccount.isBackedUp

        if syncChangesImmediately {
            syncronize()
        }
    }

    func syncronize() {
        guard UIApplication.shared.appConfiguration?.session.authenticatedUser != nil else {
            return
        }
        
        UIApplication.shared.appConfiguration?.session.authenticatedUser = self
    }
    
    func setDefaultNode(_ node: AlgorandNode?) {
        defaultNode = node?.network.rawValue
        syncronize()
    }
    
    func preferredAlgorandNetwork() -> ALGAPI.Network? {
        return User.makeNetwork(from: defaultNode)
    }
    
    func account(address: String) -> AccountInformation? {
        return accountFrom(address: address)
    }

    func indexOfAccount(_ address: String) -> Int? {
        return accounts.firstIndex(where: { $0.address == address })
    }
}

extension User {
    private func accountFrom(address: String) -> AccountInformation? {
        return accounts.first { $0.address == address }
    }

    private func removeBackup(from address: String) {
        UIApplication.shared.appConfiguration?.session.backups[address] = nil
    }
}

extension User {
    func getDeviceId(
        on network: ALGAPI.Network
    ) -> String? {
        switch network {
        case .mainnet: return deviceIDOnMainnet
        case .testnet: return deviceIDOnTestnet
        }
    }
    
    func setDeviceID(
        _ deviceID: String?,
        on network: ALGAPI.Network
    ) {
        switch network {
        case .mainnet: deviceIDOnMainnet = deviceID
        case .testnet: deviceIDOnTestnet = deviceID
        }
        
        NotificationCenter.default.post(
            name: .DeviceIDDidSet,
            object: nil
        )

        syncronize()
    }
}

extension User {
    private static func makeNetwork(
        from rawValue: String?
    ) -> ALGAPI.Network? {
        return rawValue.unwrap(ALGAPI.Network.init(rawValue:))
    }
}
