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
//  UIViewController+Analytics.swift

import UIKit

extension UIViewController {
    func track(_ screen: AnalyticsScreen) {
        UIApplication.shared.firebaseAnalytics?.track(screen)
    }
    
    func log(_ event: AnalyticsEvent) {
        UIApplication.shared.firebaseAnalytics?.log(event)
    }
    
    func record(_ log: AnalyticsLog) {
        UIApplication.shared.firebaseAnalytics?.record(log)
    }
}
