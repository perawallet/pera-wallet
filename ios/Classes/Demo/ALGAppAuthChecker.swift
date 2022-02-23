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

//   ALGAppAuthChecker.swift

import Foundation
import SwiftDate

final class ALGAppAuthChecker: AppAuthChecker {
    private(set) var status: AppAuthStatus
    
    private var lastActiveDate: Date?

    private let session: Session
    
    init(
        session: Session
    ) {
        self.status = .requiresAuthentication
        self.session = session
    }
}

extension ALGAppAuthChecker {
    func launch() {
        if !session.hasAuthentication() {
            status = .requiresAuthentication
            return
        }
        
        if session.hasPassword() {
            status = .requiresAuthorization
            return
        }
        
        status = .ready
    }
    
    func authorize() {
        lastActiveDate = nil
        status = .ready
    }
    
    func becomeActive() {
        if status != .ready {
            return
        }
        
        if !session.hasPassword() {
            return
        }
        
        if !hasSessionExpired() {
            lastActiveDate = nil
            return
        }
        
        status = .requiresAuthorization
    }
    
    func resignActive() {
        if status != .ready {
            return
        }
        
        if !session.hasPassword() {
            return
        }

        lastActiveDate = Date()
    }
}

extension ALGAppAuthChecker {
    private func hasSessionExpired() -> Bool {
        guard let lastActiveDate = lastActiveDate else {
            return false
        }
        
        let expireDate = lastActiveDate + inactiveSessionExpirationDuration
        return Date.now().isAfterDate(
            expireDate,
            granularity: .second
        )
    }
}
