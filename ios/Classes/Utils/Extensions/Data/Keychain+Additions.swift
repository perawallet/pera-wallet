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
//  Keychain+Additions.swift

import Foundation
import KeychainAccess

extension KeychainAccess.Keychain {
    
    func clear() {
        try? self.removeAll()
    }
    
    func remove(for key: String) {
        try? self.remove(key)
    }
    
    func data(for key: String) -> Data? {
        guard let data = ((try? self.getData(key)) as Data??) else {
            return nil
        }
        
        return data
    }
    
    func set(_ data: Data?, for key: String) {
        guard let data = data else {
            return
        }
        
        try? self.set(data, key: key)
    }
    
    func string(for key: String) -> String? {
        do {
            return try self.getString(key)
        } catch {
            return nil
        }
    }
    
    func set(_ string: String?, for key: String) {
        guard let value = string else {
            return
        }
        
        do {
            try self.set(value, key: key)
        } catch {
            return
        }
    }
}
