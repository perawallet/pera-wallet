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
//  FirebaseAnalytics.swift

import Firebase
import FirebaseAnalytics
import MacaroonUtils
import MacaroonVendors

final class FirebaseAnalyticsProvider: ALGAnalyticsProvider {
    private typealias instance = FirebaseAnalytics.Analytics

    private var crashlyticsInstance: Crashlytics {
        return Crashlytics.crashlytics()
    }

    func setup() {
        FirebaseApp.configure()
        instance.setAnalyticsCollectionEnabled(true)
    }

    func identify<T: AnalyticsUser>(
        _ user: T
    ) {}

    func update<T: AnalyticsUser>(
        _ user: T
    ) {}

    func canTrack<T: AnalyticsScreen>(
        _ screen: T
    ) -> Bool {
        return true
    }

    func track<T: AnalyticsScreen>(
        _ screen: T
    ) {
        let parameters = Self.transformMetadataToFirebaseParameters(screen.metadata)
        instance.logEvent(
            screen.name,
            parameters: parameters
        )
    }

    func canTrack<T: AnalyticsEvent>(
        _ event: T
    ) -> Bool {
        return true
    }

    func track<T: AnalyticsEvent>(
        _ event: T
    ) {
        asyncMain {
            let parameters = Self.transformMetadataToFirebaseParameters(event.metadata)
            instance.logEvent(
                event.name.rawValue,
                parameters: parameters
            )
        }
    }

    func canRecord(
        _ log: ALGAnalyticsLog
    ) -> Bool {
        return true
    }

    func record(
        _ log: ALGAnalyticsLog
    ) {
        let parameters = Self.transformMetadataToFirebaseParameters(log.metadata)
        let error = NSError(
            domain: log.name.rawValue,
            code: log.name.code,
            userInfo: parameters
        )
        crashlyticsInstance.record(error: error)
    }

    func reset() {
        instance.resetAnalyticsData()
    }
}

extension FirebaseAnalyticsProvider {
    typealias Parameters = [String: Any]

    static func transformMetadataToFirebaseParameters<T: AnalyticsMetadata>(
        _ metadata: T
    ) -> Parameters {
        return metadata.reduce(into: [:] as Parameters) {
            partialResult, elem in
            partialResult[elem.key.rawValue] = elem.value
        }
    }
}
