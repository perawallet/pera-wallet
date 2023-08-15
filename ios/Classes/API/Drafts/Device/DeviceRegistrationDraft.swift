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
//  DeviceRegistrationDraft.swift

import Foundation
import UIKit
import MagpieCore

struct DeviceRegistrationDraft: JSONObjectBody {
    let pushToken: String?
    let app: ALGAppTarget.App
    let platform = "ios"
    let model = UIDevice.current.model
    let locale = Locale.current.languageCode ?? "en"
    var accounts: [String] = []
    
    var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.app, app.rawValue))
        params.append(.init(.platform, platform))
        params.append(.init(.model, model))
        params.append(.init(.locale, locale))
        params.append(.init(.accounts, accounts))
        params.append(.init(.pushToken, pushToken.someString))
        return params
    }
}
