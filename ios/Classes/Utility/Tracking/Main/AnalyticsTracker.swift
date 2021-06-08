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
//  AnalyticsTracker.swift

import Foundation
import UIKit

protocol AnalyticsTracker {
    func track(_ screen: AnalyticsScreen)
    func log(_ event: AnalyticsEvent)
    func record(_ log: AnalyticsLog)
}

extension AnalyticsTracker {
    /// Screen and event trackings should not be completed on TestNet.
    var isTrackable: Bool {
        return !(UIApplication.shared.appConfiguration?.api.isTestNet ?? false)
    }
}
