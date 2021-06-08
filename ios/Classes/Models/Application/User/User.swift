// Copyright 2019 Algorand, Inc.

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

import Magpie

class User: Model {
    private(set) var accounts: [AccountInformation] = []
    private(set) var defaultNode: String?
    private(set) var deviceId: String?
    
    init(accounts: [AccountInformation]) {
        self.accounts = accounts
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension User {
    func addAccount(_ account: AccountInformation) {
        accounts.append(account)
        syncronize()
    }
    
    func removeAccount(_ account: AccountInformation) {
        guard let index = index(of: account) else {
            return
        }
        
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
        accounts[index].type = account.type
        accounts[index].ledgerDetail = account.ledgerDetail
        accounts[index].receivesNotification = account.receivesNotification
        accounts[index].rekeyDetail = account.rekeyDetail
        syncronize()
    }
    
    private func syncronize() {
        guard UIApplication.shared.appConfiguration?.session.authenticatedUser != nil else {
            return
        }
        
        UIApplication.shared.appConfiguration?.session.authenticatedUser = self
    }
    
    func setDefaultNode(_ node: AlgorandNode?) {
        defer {
            syncronize()
        }
        
        guard let selectedNode = node else {
            self.defaultNode = nil
            return
        }
        
        self.defaultNode = selectedNode.network.rawValue
    }
    
    func preferredAlgorandNetwork() -> AlgorandAPI.BaseNetwork? {
        guard let defaultNode = defaultNode else {
            return nil
        }
        
        if defaultNode == AlgorandAPI.BaseNetwork.mainnet.rawValue {
            return .mainnet
        } else if defaultNode == AlgorandAPI.BaseNetwork.testnet.rawValue {
            return .testnet
        } else {
            return nil
        }
    }
    
    func setDeviceId(_ id: String?) {
        deviceId = id
        NotificationCenter.default.post(name: .DeviceIDDidSet, object: nil)
        syncronize()
    }
    
    func account(address: String) -> AccountInformation? {
        return accountFrom(address: address)
    }
}

extension User {
    private func accountFrom(address: String) -> AccountInformation? {
        return accounts.first { $0.address == address }
    }
}

extension User: Encodable { }
