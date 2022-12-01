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

//   RecordHomeScreenEvent.swift

import Foundation
import MacaroonVendors

struct RecordHomeScreenEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension RecordHomeScreenEvent {
    enum `Type` {
        case addAccount
        case qrScan
        case qrScanConnected
        case buyAlgo
        case swap
        case tapAccounts
        case visitGovernance

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .addAccount:
                return .createAccountInHomeScreen
            case .qrScan:
                return .tapQRInHome
            case .qrScanConnected:
                return .qrConnectedInHome
            case .buyAlgo:
                return .tapBuyAlgoInHome
            case .swap:
                return .tapSwapInHome
            case .tapAccounts:
                return .createAccountInHomeScreen /// <todo>: It will be replaced the actual event when event created
            case .visitGovernance:
                return .tapGovernanceBanner
            }
        }
    }
}

extension AnalyticsEvent where Self == RecordHomeScreenEvent {
    static func recordHomeScreen(
        type: RecordHomeScreenEvent.`Type`
    ) -> Self {
        return RecordHomeScreenEvent(type: type)
    }
}
