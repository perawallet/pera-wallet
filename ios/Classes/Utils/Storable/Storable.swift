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
//  Storable.swift

import Foundation
import KeychainAccess

enum StoreKeys: String {
    case appPassword = "com.algorand.algorand.app.password"
}

enum StorableKeys: String {
    case storage = "com.algorand.algorand.storage"
    case localAuthenticationStatus = "com.algorand.algorand.local.authentication.status"
}

enum Store {
    case defaults
    case keychain
}

protocol Storable {
    associatedtype Object
    
    func save(_ string: String, for key: String, to store: Store)
    func save(_ data: Data, for key: String, to store: Store)
    func save(_ bool: Bool, for key: String, to store: Store)
    
    func object(with key: String, to store: Store) -> Object?
    func string(with key: String, to store: Store) -> String?
    func data(with key: String, to store: Store) -> Data?
    func bool(with key: String, to store: Store) -> Bool
    
    func remove(with key: String, from store: Store)
    func clear(_ store: Store)
}

extension Storable {
    
    var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    var keychain: KeychainAccess.Keychain {
        return KeychainAccess.Keychain(
            service: StorableKeys.storage.rawValue)
            .accessibility(.always)
    }
    
    func save(_ string: String, for key: String, to store: Store) {
        switch store {
        case .defaults:
            userDefaults.set(string, for: key)
        case .keychain:
            keychain.set(string, for: key)
        }
    }
    
    func save(_ data: Data, for key: String, to store: Store) {
        switch store {
        case .defaults:
            userDefaults.set(data, for: key)
        case .keychain:
            keychain.set(data, for: key)
        }
    }
    
    func save(_ bool: Bool, for key: String, to store: Store) {
        switch store {
        case .defaults:
            userDefaults.set(bool, for: key)
        case .keychain:
            keychain.set(bool ? "1" : "0", for: key)
        }
    }
    
    func bool(with key: String, to store: Store) -> Bool {
        switch store {
        case .defaults:
            return userDefaults.bool(forKey: key)
        case .keychain:
            guard let string = keychain.string(for: key), string == "1" else {
                return false
            }
            return true
        }
    }
    
    func object(with key: String, to store: Store) -> Object? {
        return nil
    }
    
    func string(with key: String, to store: Store) -> String? {
        switch store {
        case .defaults:
            return userDefaults.string(forKey: key)
        case .keychain:
            return keychain.string(for: key)
        }
    }
    
    func data(with key: String, to store: Store) -> Data? {
        switch store {
        case .defaults:
            return userDefaults.data(forKey: key)
        case .keychain:
            return keychain.data(for: key)
        }
    }
    
    func remove(with key: String, from store: Store) {
        switch store {
        case .defaults:
            userDefaults.remove(for: key)
        case .keychain:
            keychain.remove(for: key)
        }
    }
    
    func clear(_ store: Store) {
        switch store {
        case .defaults:
            userDefaults.clear()
        case .keychain:
            keychain.clear()
        }
    }
}
