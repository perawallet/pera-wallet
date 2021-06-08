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
//  LocalAuthenticator.swift

import LocalAuthentication

class LocalAuthenticator {

    private var context = LAContext()
    
    var authenticationError: NSError?

    var isLocalAuthenticationAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
    }
    
    var localAuthenticationStatus: Status {
        get {
            guard let status = string(with: StorableKeys.localAuthenticationStatus.rawValue, to: .defaults),
                let localAuthenticationStatus = Status(rawValue: status) else {
                    return .none
            }
            
            return localAuthenticationStatus
        }
        
        set {
            self.save(newValue.rawValue, for: StorableKeys.localAuthenticationStatus.rawValue, to: .defaults)
        }
    }
    
    var localAuthenticationType: Type {
        if !isLocalAuthenticationAvailable {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    init() {
        awakeLocalAuthenticationStatusFromStorage()
    }
    
    private func awakeLocalAuthenticationStatusFromStorage() {
        guard let status = string(with: StorableKeys.localAuthenticationStatus.rawValue, to: .defaults),
            let localAuthenticationStatus = Status(rawValue: status) else {
            return
        }
        
        self.localAuthenticationStatus = localAuthenticationStatus
    }
    
    func authenticate(then handler: @escaping (_ error: Error?) -> Void) {
        if !isLocalAuthenticationAvailable {
            return
        }
        
        let reasonMessage: String
        
        if localAuthenticationType == .faceID {
            reasonMessage = "local-authentication-reason-face-id-title".localized
        } else {
            reasonMessage = "local-authentication-reason-touch-id-title".localized
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonMessage) { success, error in
            if success {
                DispatchQueue.main.async {
                    handler(nil)
                }
            } else {
                DispatchQueue.main.async {
                    handler(error)
                }
            }
        }
    }

    func reset() {
        context = LAContext()
    }
}

extension LocalAuthenticator {
    
    enum `Type` {
        case none
        case touchID
        case faceID
    }
}

extension LocalAuthenticator: Storable {
    
    enum Status: String {
        case allowed = "enabled"
        case notAllowed = "disabled"
        case none = "none"
    }
    
    typealias Object = String
}
