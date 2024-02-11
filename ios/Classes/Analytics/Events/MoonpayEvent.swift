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

//   MoonPayEvent.swift

import Foundation
import MacaroonVendors

struct MeldEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init() {
        self.name = .tapBuyAlgoInMeld
        self.metadata = [:]
    }
}

extension AnalyticsEvent where Self == MeldEvent {
    static func meld() -> Self {
        return MeldEvent()
    }
}

struct MoonPayEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension MoonPayEvent {
    enum `Type` {
        case tapBuy
        case completed
        case tapBottomsheetBuy

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .tapBuy:
                return .tapBuyAlgoInMoonPay
            case .completed:
                return .buyAlgoFromMoonPayCompleted
            case .tapBottomsheetBuy:
                return .tapBuyAlgoInBottomsheet
            }
        }
    }
}

extension AnalyticsEvent where Self == MoonPayEvent {
    static func moonPay(
        type: MoonPayEvent.`Type`
    ) -> Self {
        return MoonPayEvent(type: type)
    }
}
