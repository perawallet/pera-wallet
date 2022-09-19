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

//   OnboardSetPinCodeEvent.swift

import Foundation
import MacaroonVendors

struct OnboardSetPinCodeEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension OnboardSetPinCodeEvent {
    enum `Type` {
        case create
        case verify

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .create:
                return .onboardVerifiedSetPinCode
            case .verify:
                return .onboardVerifiedSetPinCodeCompleted
            }
        }
    }
}

extension AnalyticsEvent where Self == OnboardSetPinCodeEvent {
    static func onboardSetPinCode(
        type: OnboardSetPinCodeEvent.`Type`
    ) -> Self {
        return OnboardSetPinCodeEvent(type: type)
    }
}
