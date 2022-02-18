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

class FirebaseAnalytics: NSObject {
    
    func initialize() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
    }
}

extension FirebaseAnalytics: AnalyticsTracker {
    func track(_ screen: AnalyticsScreen) {
        if let name = screen.name,
           isTrackable {
            Analytics.logEvent(name.rawValue, parameters: screen.params?.transformToAnalyticsFormat())
        }
    }
    
    func log(_ event: AnalyticsEvent) {
        if !isTrackable {
            return
        }
        
        Analytics.logEvent(event.key.rawValue, parameters: event.params?.transformToAnalyticsFormat())
    }
    
    func record(_ log: AnalyticsLog) {
        let error = NSError(domain: log.name.rawValue, code: log.id, userInfo: log.params.transformToAnalyticsFormat())
        Crashlytics.crashlytics().record(error: error)
    }
}
