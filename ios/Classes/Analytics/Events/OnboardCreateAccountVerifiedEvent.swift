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

//   OnboardCreateAccountVerifiedEvent.swift

import Foundation
import MacaroonVendors

struct OnboardCreateAccountVerifiedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension OnboardCreateAccountVerifiedEvent {
    enum `Type` {
        case start
        case buyAlgo

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .start:
                return .onboardCreateAccountVerifiedStart
            case .buyAlgo:
                return .onboardCreateAccountVerifiedBuyAlgo
            }
        }
    }
}

extension AnalyticsEvent where Self == OnboardCreateAccountVerifiedEvent {
    static func onboardCreateAccountVerified(
        type: OnboardCreateAccountVerifiedEvent.`Type`
    ) -> Self {
        return OnboardCreateAccountVerifiedEvent(type: type)
    }
}
