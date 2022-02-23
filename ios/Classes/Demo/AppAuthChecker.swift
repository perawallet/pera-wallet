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

//   AppAuthChecker.swift

import Foundation
import SwiftDate

protocol AppAuthChecker {
    var status: AppAuthStatus { get }
    
    func launch()
    func authorize()
    func becomeActive()
    func resignActive()
}

extension AppAuthChecker {
    var inactiveSessionExpirationDuration: DateComponents {
        return 60.seconds
    }
}

enum AppAuthStatus {
    case requiresAuthentication /// No authenticated user
    case requiresAuthorization /// Passcode
    case ready
}
