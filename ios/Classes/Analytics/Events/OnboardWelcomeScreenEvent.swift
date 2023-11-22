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

//   OnboardWelcomeScreenEvent.swift

import Foundation
import MacaroonVendors

struct OnboardWelcomeScreenEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension OnboardWelcomeScreenEvent {
    enum `Type` {
        case create
        case recover
        case watch

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .recover:
                return .onboardWelcomeScreenAccountRecover
            case .create:
                return .onboardWelcomeScreenAccountCreate
            case .watch:
                return .onboardWatchAccountCreate
            }
        }
    }
}

extension AnalyticsEvent where Self == OnboardWelcomeScreenEvent {
    static func onboardWelcomeScreen(
        type: OnboardWelcomeScreenEvent.`Type`
    ) -> Self {
        return OnboardWelcomeScreenEvent(type: type)
    }
}
