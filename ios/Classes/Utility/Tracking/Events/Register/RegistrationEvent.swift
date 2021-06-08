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
//  RegistrationEvent.swift

import Foundation

struct RegistrationEvent: AnalyticsEvent {
    let type: RegistrationType
    
    let key: AnalyticsEventKey = .register
    
    var params: AnalyticsParameters? {
        return [.type: type.rawValue]
    }
}

extension RegistrationEvent {
    enum RegistrationType: String {
        case create = "create"
        case ledger = "ledger"
        case recover = "recover"
        case rekeyed = "rekeyed"
        case watch = "watch"
    }
}
